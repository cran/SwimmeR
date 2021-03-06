% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dive_place.R
\name{dive_place}
\alias{dive_place}
\title{Adds places to diving results}
\usage{
dive_place(df, max_place)
}
\arguments{
\item{df}{a data frame with results from \code{swim_parse}, including only
diving results (not swimming)}

\item{max_place}{highest place value that scores}
}
\value{
data frame modified so that places have been appended based on diving
  score
}
\description{
Places are awarded on the basis of score, with highest score winning.  Ties
are placed as ties (both athletes get 2nd etc.)
}
\seealso{
\code{dive_place} is a helper function used inside of
  \code{results_score}
}
