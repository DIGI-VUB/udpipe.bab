library(udpipe)
library(data.table)
library(xml2)
library(zoo)

# if(FALSE){
#   ##
#   ## Function to read in Brieven als Buit plain text file which looks like a XML file but is not
#   ##
#   read_content <- function(filename){
#     ## These XML files are really no xml files
#     #f <- read_xml(filename)
#     #x <- xml_find_all(f, "//doc") %>% xml_contents %>% as.character
#     content <- readLines(filename, encoding = "UTF-8")
#     content <- iconv(content, from = "UTF-8", to = "ASCII//TRANSLIT")
#     content <- content[!grepl(content, pattern = "doc>|file>")]
#     x <- paste(content, collapse = "\n")
#     x <- strsplit(x, "\n")
#     x <- unlist(x)
#     x <- x[x != ""]
#     x <- strsplit(x, "\t")
#     x <- data.frame(doc_id = basename(filename), 
#                     token = sapply(x, FUN=function(x) x[1]),
#                     xpos = sapply(x, FUN=function(x) x[2]),
#                     lemma = sapply(x, FUN=function(x) x[3]), stringsAsFactors = FALSE)
#     x
#   }
#   
#   ##
#   ## Read in the annotated text of each document
#   ##
#   filenames <- list.files("data/BaB2.0", pattern = ".xml$", full.names = TRUE)
#   bab <- list()
#   for(f in filenames){
#     cat(sprintf("%s %s", Sys.time(), f), sep = "\n")
#     bab[[f]] <- read_content(f)
#   }
#   bab <- rbindlist(bab)
#   bab <- setDT(bab)
# }

##
## Function to read in Brieven als Buit plain XML file
##
read_content <- function(filename){
  f <- read_xml(filename)
  z <- xml_find_all(f, "//body") 
  z <- xml_contents(z)
  z <- xml_children(z)
  z <- xml_children(z)
  z <- lapply(z, FUN=function(x){
    token <- xml_text(x)
    names(token) <- "token"
    x <- xml_attrs(x) 
    x <- c(x, token)
    data.frame(t(x), stringsAsFactors = F)
  })
  z <- data.table::rbindlist(z, fill = T)
  z <- subset(z, !is.na(token) & nchar(trimws(token)) > 0)
  ## field used for multi-word expressions
  if(!"n" %in% colnames(z)){
    z$n <- NA
  }
  x <- data.frame(doc_id = basename(filename), 
                  token = z$token,
                  xpos = z$type,
                  lemma = z$lemma, 
                  mwe_id = z$n,
                  stringsAsFactors = FALSE)
  x
}
filenames <- list.files("inst/train/data/BaBXMLv2.0", pattern = ".xml$", full.names = TRUE)
bab <- list()
for(f in filenames){
  cat(sprintf("%s %s", Sys.time(), f), sep = "\n")
  bab[[f]] <- read_content(f)
}
bab <- rbindlist(bab)
bab <- setDT(bab)
Encoding(bab$token) <- "UTF-8"
Encoding(bab$lemma) <- "UTF-8"
saveRDS(bab, file = "inst/train/data/bab.rds")

################################################################################
## Add some fields which are needed for UDPipe
##
bab <- readRDS(file = "inst/train/data/bab.rds")
cleaner <- function(x){
  #gsub("[^A-Za-z0-9 ]", "", x)
  gsub("[^A-Za-z0-9]", "", x)
}
x <- as.data.table(bab)
x$token <- trimws(x$token)
x$token <- ifelse(x$token == "", NA, x$token)
x$lemma <- trimws(x$lemma)
x$lemma <- ifelse(x$lemma == "", NA, x$lemma)
x$lemma <- ifelse(grepl(x$lemma, pattern = "uncertain|unresolved", ignore.case = TRUE), NA, x$lemma)
x <- subset(x, !is.na(token))
x <- subset(x, !grepl(token, pattern = "uncertain|unresolved", ignore.case = TRUE))
x <- x[, sentence_id := 1L, by = list(doc_id)]
x <- x[, sentence := paste(token, collapse = " "), by = list(doc_id)]
x <- x[, sentence := "", by = list(doc_id)]
x <- x[, token_id := seq_len(.N), by = list(doc_id)]
## multi-word expressions together
x <- x[, token_id_mwe := mapply(mwe_id = .SD$mwe_id, row_i = seq_len(nrow(.SD)), FUN = function(mwe_id, row_i, n = 5, fulldata){
  if(is.na(mwe_id)){
    return(NA_character_)
  }else{
    from <- row_i - n
    from <- ifelse(from < 1, 1, from)
    to   <- row_i + n
    to   <- ifelse(to > nrow(fulldata), nrow(fulldata), to)
    rows <- fulldata[seq(from = from, to = to, by = 1), ]
    ids  <- rows$token_id[rows$mwe_id %in% mwe_id]
    ## this is a bit risky as some multi-word-expressions can have a non-mwe token in between, consider these as part of the mwe
    ids  <- range(ids)
    return(paste(ids, collapse = "-"))
  }
}, MoreArgs = list(fulldata = .SD)), by = list(doc_id)]
mwe <- x[!is.na(token_id_mwe), list(token = paste(token, collapse = " "),
                                    lemma = head(lemma, 1),
                                    xpos = head(xpos, 1)), by = list(doc_id, sentence_id, sentence, token_id = token_id_mwe)]
x <- setDF(x)
x <- rbind(mwe[, c("doc_id", "sentence_id", "sentence", "token_id", "token", "lemma", "xpos")], 
           x[, c("doc_id", "sentence_id", "sentence", "token_id", "token", "lemma", "xpos")])
x <- x[order(x$doc_id, x$sentence_id, as.integer(sapply(strsplit(x$token_id, "-"), head, 1)), decreasing = FALSE), ]

################################################################################################
## POS TAGS USED IN CORPUS
# VRB: verb
# NOU: noun
# NEPER: person name
# NEORG: organisation name, e.g. VOC
# NELOC: location name. e.g. street name, city, region, country
# NEOTHER: other named entities, e.g. name of a ship
# ADJ: adjective
# ADP: adposition
# ADV: adverb
# ART: article
# NUM: numeral
# PRN: pronoun/determiner
# CON: conjunction
# INT: interjection
# RES: residual, e.g. abbreviations
# UNRESOLVED: lemma or part of speech unclear
################################################################################################
x$xpos <- gsub("\\?", "", x$xpos)
x$xpos <- gsub("\\]", "", x$xpos)
x$xpos <- strsplit(x$xpos, split = "\\||_")
textplot_bar(sort(table(unlist(x$xpos)), decreasing = TRUE))
x$xpos <- sapply(x$xpos, FUN=function(x){
  x <- unique(x)
  if(length(x) > 1 || length(x) == 0) return(NA) else return(x)
})
x$xpos <- ifelse(x$xpos %in% c("FOREIGN", "NEORG", "UNRESOLVED", "NEOTHER", 
                               "RES", "INT", "NELOC", "NUM", "NEPER", "ART", "ADJ", "CON", "ADP", 
                               "ADV", "NOU", "PRN", "VRB"), x$xpos, NA)
x$upos <- ifelse(x$xpos %in% "UNRESOLVED", NA, x$xpos)
x$upos  <- txt_recode(x$upos, 
                      from = c("VRB", "NOU", "NEPER", "NEORG", "NELOC", "NEOTHER", "ADJ", "ADP", "ADV", "ART", "NUM", "PRN", "CON", "INT", 
                               "RES", "FOREIGN"),
                      to = c("VERB", "NOUN", "PROPN", "PROPN", "PROPN", "PROPN", "ADJ", "ADP", "ADV", "DET", "NUM", "PRON", "CCONJ", "INTJ", 
                             "X", "X"))
table(x$upos, x$xpos, exclude = c())
saveRDS(x, file = "inst/train/data/bab_conllu.rds")
x <- readRDS(file = "inst/train/data/bab_conllu.rds")

##
## Create training (70%) / test (15%) / dev (15%) dataset in conllu format
##
set.seed(123456789)
docs <- unique(x$doc_id)
docs_training <- sample(docs, size = round(length(docs) * 0.7), replace = FALSE)
docs_dev      <- setdiff(docs, docs_training)
docs_test     <- sample(docs_dev, size = round(length(docs_dev) / 2))
docs_dev      <- setdiff(docs_dev, docs_test)
txt <- as_conllu(subset(x, doc_id %in% docs_training))
cat(txt, file = file("inst/train/data/bab-ud-train.conllu", encoding = "UTF-8"))
txt <- as_conllu(subset(x, doc_id %in% docs_dev))
cat(txt, file = file("inst/train/data/bab-ud-dev.conllu", encoding = "UTF-8"))
txt <- as_conllu(subset(x, doc_id %in% docs_test))
cat(txt, file = file("inst/train/data/bab-ud-test.conllu", encoding = "UTF-8"))
