library(utils)
library(udpipe)
library(crfsuite)
options(echo = TRUE)
#setwd("C:/Users/Jan/Dropbox/Work/RForgeBNOSAC/VUB/udpipe.bab")
settings <- list()
settings$date <- as.Date("2020-04-29")
settings$date <- Sys.Date()
settings$modelname <- sprintf("dutch-bab-%s.udpipe", format(settings$date, "%Y%m%d"))
settings$modeloutput <- file.path(getwd(), "inst", "train", "models", settings$modelname)
settings$modeldata <- file.path(getwd(), "inst", "train", "data", "modeldata.rds")
print(settings)


## Train the model
set.seed(123456789)
print(Sys.time())
m <- udpipe_train(file = settings$modeloutput, 
                  files_conllu_training = "inst/train/data/bab-ud-train.conllu", 
                  files_conllu_holdout  = "inst/train/data/bab-ud-dev.conllu",
                  #annotation_tokenizer = list(dimension = 24, epochs = 100, initialization_range = 0.1, batch_size = 100, learning_rate = 0.005, dropout = 0.1, early_stopping = 1),
                  annotation_tokenizer = "none",
                  annotation_tagger = list(models = 2,
                                           templates_1 = "tagger",
                                           iterations_1 = 20,
                                           guesser_suffix_rules_1 = 8, guesser_enrich_dictionary_1 = 6, guesser_prefixes_max_1 = 0,
                                           use_lemma_1 = 0, use_xpostag_1 = 1, use_feats_1 = 1,
                                           provide_lemma_1 = 0, provide_xpostag_1 = 1, provide_feats_1 = 0, prune_features_1 = 0,
                                           templates_2 = "lemmatizer",
                                           iterations_2 = 20,
                                           guesser_suffix_rules_2 = 6, guesser_enrich_dictionary_2 = 4, guesser_prefixes_max_2 = 4,
                                           use_lemma_2 = 1, use_xpostag_2 = 0, use_feats_2 = 0,
                                           provide_lemma_2 = 1, provide_xpostag_2 = 0, provide_feats_2 = 0, prune_features_2 = 0),
                  annotation_parser = "none")
print(Sys.time())

## Evaluate the accuracy
model <- udpipe_load_model(settings$modeloutput)
goodness_of_fit <- udpipe_accuracy(model, "inst/train/data/bab-ud-test.conllu", tokenizer = "none", tagger = "default", parser = "none")
cat(goodness_of_fit$accuracy, sep = "\n")

## Evaluate the model using crfsuite
modeldata <- readRDS(file = settings$modeldata)
modeldata <- subset(modeldata, type == "test")
pred <- udpipe_annotate(model, 
                        x = sapply(split(modeldata$token, modeldata$doc_id), FUN=function(x) paste(x, collapse = "\n")), 
                        tokenizer = "vertical", parser = "none", trace = 100)
pred <- as.data.frame(pred)

crf_evaluation(pred = pred$upos, obs = modeldata$upos)
crf_evaluation(pred = pred$xpos, obs = modeldata$xpos)
prop.table(table(pred$lemma == modeldata$lemma))
prop.table(table(modeldata$xpos, pred$lemma == modeldata$lemma), margin = 1)
