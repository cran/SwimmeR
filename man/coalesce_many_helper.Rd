% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/coalesce_many.R
\name{coalesce_many_helper}
\alias{coalesce_many_helper}
\title{Combined paired sets of columns following a join operation}
\usage{
coalesce_many_helper(df, new_split_names, i)
}
\arguments{
\item{df}{a data frame following a join and thereby containing paired columns
of the form Col_1.x, Col_1.y}

\item{new_split_names}{a list of desired column names, e.g. Col_1, Col_2}

\item{i}{a number between 1 and the length of \code{new_split_names}}
}
\value{
returns a data frame with one set of paired columns combined into a
  single column and named based on \code{new_split_names}
}
\description{
This function is intended to be mapped over a sequence \code{i} inside the
function \code{\link{coalesce_many}}
}
\seealso{
\code{coalesce_many_helper} runs inside
  \code{\link{coalesce_many}}
}
