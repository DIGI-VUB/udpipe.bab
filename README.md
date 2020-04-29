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
x <- data.frame(doc_id = c("a", "b"), 
                text = c("Desen brief sal men bstelen an Janetie Alberts woont in fredrickstadt", 
                         "dit kan Ul op vaders rekeningh setten ende senden"), 
                stringsAsFactors = FALSE)
anno <- udpipe_bab(x, tokenizer = "basic", split = " ", trace = TRUE)
anno <- udpipe_bab(x, tokenizer = "generic")
anno
 doc_id sentence_id         token         lemma  upos  xpos token_id term_id start end
      a           1         Desen          deze  PRON   PRN        1       1     1   5
      a           1         brief         brief  NOUN   NOU        2       2     7  11
      a           1           sal        zullen  VERB   VRB        3       3    13  15
      a           1           men           men  PRON   PRN        4       4    17  19
      a           1       bstelen     bestellen  VERB   VRB        5       5    21  27
      a           1            an           aan   ADP   ADP        6       6    29  30
      a           1       Janetie       Janetje PROPN NEPER        7       7    32  38
      a           1       Alberts       Alberts PROPN NEPER        8       8    40  46
      a           1         woont         wonen  VERB   VRB        9       9    48  52
      a           1            in            in   ADP   ADP       10      10    54  55
      a           1 fredrickstadt Frederiksstad PROPN NELOC       11      11    57  69
      b           1           dit           dit  PRON   PRN        1       1     1   3
      b           1           kan        kunnen  VERB   VRB        2       2     5   7
      b           1            Ul            ul  PRON   PRN        3       3     9  10
      b           1            op            op   ADV   ADV        4       4    12  13
      b           1        vaders         vader  NOUN   NOU        5       5    15  20
      b           1     rekeningh      rekening  NOUN   NOU        6       6    22  30
      b           1        setten        zetten  VERB   VRB        7       7    32  37
      b           1          ende            en CCONJ   CON        8       8    39  42
      b           1        senden        zenden  VERB   VRB        9       9    44  49
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
