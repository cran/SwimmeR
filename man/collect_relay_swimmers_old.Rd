% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/deprec_collect_relay_swimmers.R
\name{collect_relay_swimmers_old}
\alias{collect_relay_swimmers_old}
\title{Collects relay swimmers as a data frame within \code{swim_parse_old}}
\usage{
collect_relay_swimmers_old(x, typo_2 = typo, replacement_2 = replacement)
}
\arguments{
\item{x}{output from \code{read_results} followed by \code{add_row_numbers}}

\item{typo_2}{list of typos from \code{swim_parse}}

\item{replacement_2}{list of replacements for typos from \code{swim_parse}}
}
\value{
returns a data frame of relay swimmers and the associated performance row number
}
\description{
Depreciated version associated with depreciated version of \code{swim_parse_old}
}
\seealso{
\code{collect_relay_swimmers} runs inside of \code{swim_parse}
}
