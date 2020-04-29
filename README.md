# udpipe.bab

This repository contains an R package for doing Parts of Speech tagging and Lemmatisation on 18th-19th century Dutch texts.

- The package contains an UDPipe model 
- The model was trained on the Brieven als Buit corpus https://ivdnt.org/downloads/taalmaterialen/tstc-bab-gouden-standaard
- Code used to construct the training dataset and the code used to train the model is available in the inst/train/src folder. The data which was used to train the model is not distributed in this package.

### Installation

- For installing the package: `remotes::install_github("DIGI-VUB/udpipe.bab", build_vignettes = TRUE)`

Look to the vignette and the documentation of the functions

```
vignette("bab", package = "udpipe.bab")
help(package = "udpipe.bab")
```

### Example

```
library(udpipe.bab)
x <- data.frame(doc_id = c("doc1", "doc2"),
                text = c("Alswanneer den claegher hem seijde dat hij sulcke raillarie niet meer in het toecommende en wilde hooren, anderssints dat den claegher hem op sijn bacchuijs soude ghelapt hebben dat was hij een eerlick man",
                "Philippe Boudens seght ter  presentie van L'ardenoy, als dat  L'ardenoij Maijens op straete heeft  afgewacht, ende dat hij Maijens  uytcommende heeft toegeschoten  ende aengevat, waer op hij Boudens  alsdan is in huijs gegaen."),
                stringsAsFactors = FALSE)
anno <- udpipe_bab(x, tokenizer = "generic", trace = TRUE)
anno <- udpipe_bab(x, tokenizer = "basic", split = " ", trace = TRUE)
```

### License

The package and model is distributed under the CC-BY-NC-SA license (https://creativecommons.org/licenses/by-nc-sa/4.0)

- Brieven als Buit - Gouden Standaard (Version 2.0) (2013) [Data set]. Available at the Dutch Language Institute: http://hdl.handle.net/10032/Tm-a2-a7

### Python

- If you prefer to use the model with Python
- Grab the model and use ufal.udpipe to do the tagging and lemmatisation

```
>>> from ufal.udpipe import Model, Pipeline, ProcessingError
>>> error = ProcessingError()
>>> model = Model.load('inst/models/dutch-bab-20200428.udpipe')
>>> pipeline = Pipeline(model, 'vertical', Pipeline.DEFAULT, 'none', 'conllu')
>>> tokenized_sentence = '\n'.join(['Alswanneer', 'den', 'claegher', 'hem', 'seijde', 'dat', 'hij', 'sulcke']) 
>>> print(pipeline.process(tokenized_sentence, error))
```

### Future

- Model is subject to possible change in the future when hyperparameters will be tuned further 


### DIGI

By DIGI: Brussels Platform for Digital Humanities: https://digi.research.vub.be

![](vignettes/logo.png)
