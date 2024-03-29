% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_event_dummy_row.R
\name{add_event_dummy_row}
\alias{add_event_dummy_row}
\title{Add dummy entry rows}
\usage{
add_event_dummy_row(x)
}
\arguments{
\item{x}{a list of data frames containing event results that need dummy
entries added}
}
\value{
returns a list of data frames each with a dummy entry row added
}
\description{
If a team does not have a full compliment, defined by \code{max_entries}, of
athletes in a given event then dummy rows containing blank entries need to be
added to that event
}
