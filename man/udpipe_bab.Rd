% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pkg.R
\name{udpipe_bab}
\alias{udpipe_bab}
\title{Perform Parts of Speech tagging and Lemmatisation on 18th-19th century Dutch texts}
\usage{
udpipe_bab(x, tokenizer = c("generic", "basic"), trace = FALSE, ...)
}
\arguments{
\item{x}{a data.frame with columns doc_id and text}

\item{tokenizer}{either 'generic' to use a generic tokenizer provided by R package udpipe or 'basic' to split based on spaces}

\item{trace}{argument passed on to \code{\link[udpipe]{udpipe_annotate}}}

\item{...}{passed on to \code{\link{tokenize_simple}}}
}
\value{
a data.frame with tokenised and parts of speech tags and lemma's with columns
doc_id, sentence_id, token, lemma, upos, xpos, token_id, term_id, start, end.
Note that columns start and end will be all NA values if the 'basic' tokenizer is used
}
\description{
Perform Parts of Speech tagging and Lemmatisation on 18th-19th century Dutch texts
}
\examples{
x <- data.frame(doc_id = c("a", "b"), 
                text = c("Desen brief sal men bstelen an Janetie Alberts woont in fredrickstadt", 
                         "dit kan Ul op vaders rekeningh setten ende senden"), 
                stringsAsFactors = FALSE)
anno <- udpipe_bab(x, tokenizer = "generic")
anno
anno <- udpipe_bab(x, tokenizer = "basic")
anno
}
\seealso{
\code{\link{tokenize_simple}}, \code{\link[udpipe]{udpipe_annotate}}
}
