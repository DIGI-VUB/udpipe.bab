#' @importFrom udpipe udpipe_annotate udpipe_load_model
NULL

nlp <- new.env()


.onLoad <- function(libname, pkgname) {
    path <- system.file(package = "udpipe.bab", "models", "dutch-bab.udpipe")
    path <- system.file(package = "udpipe.bab", "models", "dutch-bab-20200428.udpipe")
    nlp$model <- udpipe::udpipe_load_model(path)
}

#' @title Perform Parts of Speech tagging and Lemmatisation on 18th-19th century Dutch texts 
#' @description Perform Parts of Speech tagging and Lemmatisation on 18th-19th century Dutch texts 
#' @param x a data.frame with columns doc_id and text
#' @param tokenizer either 'generic' to use a generic tokenizer provided by R package udpipe or 'basic' to split based on spaces 
#' @param trace argument passed on to \code{\link[udpipe]{udpipe_annotate}}
#' @param ... passed on to \code{\link{tokenize_simple}} 
#' @return a data.frame with tokenised and parts of speech tags and lemma's with columns
#' doc_id, sentence_id, token, lemma, upos, xpos, token_id, term_id, start, end.
#' Note that columns start and end will be all NA values if the 'basic' tokenizer is used
#' @seealso \code{\link{tokenize_simple}}, \code{\link[udpipe]{udpipe_annotate}}
#' @export
#' @examples
#' x <- data.frame(doc_id = c("a", "b"), 
#'                 text = c("Desen brief sal men bstelen an Janetie Alberts woont in fredrickstadt", 
#'                          "dit kan Ul op vaders rekeningh setten ende senden"), 
#'                 stringsAsFactors = FALSE)
#' anno <- udpipe_bab(x, tokenizer = "generic")
#' anno
#' anno <- udpipe_bab(x, tokenizer = "basic")
#' anno
udpipe_bab <- function(x, tokenizer = c("generic", "basic"), trace=FALSE, ...){
    stopifnot(is.data.frame(x))
    stopifnot(all(c("doc_id", "text") %in% colnames(x)))
    tokenizer <- match.arg(tokenizer)
    if(tokenizer == "basic"){
        x <- split(x$text, x$doc_id)
        x <- lapply(x, FUN = tokenize_simple, ...)
        x <- sapply(x, FUN = function(x) paste(x, collapse = "\n"))
        x <- udpipe::udpipe_annotate(nlp$model, x = x, tokenizer = "vertical", tagger = "default", parser = "none", trace = trace)
        x <- as.data.frame(x, detailed = TRUE)   
        x <- x[, intersect(c("doc_id", "sentence_id", "token", "lemma", "upos", "xpos", "token_id", "term_id"), colnames(x))]
    }else if(tokenizer == "generic"){
        x <- udpipe::udpipe_annotate(nlp$model, x = x$text, doc_id = x$doc_id, tokenizer = "generic_tokenizer", tagger = "default", parser = "none", trace = trace)
        x <- as.data.frame(x, detailed = TRUE) 
        x <- x[, intersect(c("doc_id", "sentence_id", "token", "lemma", "upos", "xpos", "token_id", "term_id", "start", "end"), colnames(x))]
    }
    x
}



#' @title Tokenise text into a sequence of words
#' @description Tokenise text into a sequence of words. The function uses \code{\link{strsplit}} to split text into words
#' by using the [:space:] character classes.
#' @param x a character string of length 1
#' @param split passed on to \code{\link{strsplit}}
#' @return a character vector with the sequence of words in \code{x}
#' @seealso \code{\link{strsplit}}
#' @export
#' @examples
#' tokenize_simple("This just splits. Text.alongside\nspaces right?")
#' tokenize_simple("Also .. multiple punctuations or ??marks")
#' tokenize_simple("Joske  Vermeulen")
tokenize_simple <- function(x, split = "[[:space:]]+"){
    if(length(x) != 1){
        stop("requires x to be of length 1")
    }
    x <- strsplit(x, split = split)
    x <- unlist(x, recursive = FALSE) 
    x
}

