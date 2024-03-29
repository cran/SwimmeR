% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/splash_list_sorters.R
\name{splash_length_7_sort}
\alias{splash_length_7_sort}
\title{Sort data in lists of length 7 within \code{spash_swim_parse}}
\usage{
splash_length_7_sort(
  x,
  time_score_string = Time_Score_String,
  time_score_specials_string = Time_Score_Specials_String
)
}
\arguments{
\item{x}{a list of lists with all sub-lists having length 7}

\item{time_score_string}{a regex string for matching results (times and
scores) but not special strings like DQ}

\item{time_score_specials_string}{a regex string for matching results - i.e.
times, diving scores and 'specials' like DQ}
}
\value{
returns a formatted data frame to be combined with others to make the
  output of \code{splash_swim_parse}
}
\description{
Sort data in lists of length 7 within \code{spash_swim_parse}
}
