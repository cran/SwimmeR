% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/place.R
\name{place}
\alias{place}
\title{Add places to results}
\usage{
place(
  df,
  result_col = Finals,
  max_place = NULL,
  event_type = "ind",
  max_relays_per_team = 1,
  keep_nonscoring = TRUE,
  verbose = TRUE
)
}
\arguments{
\item{df}{a data frame with results from \code{swim_parse}, including
swimming and/or diving results.  \code{df} must contain a column called
\code{Event}}

\item{result_col}{the name of a column in \code{df} containing times and/or
scores on which to place (order) performances.  Default is \code{Finals}}

\item{max_place}{highest place value that scores}

\item{event_type}{either \code{"ind"} for individual or \code{"relay"} for
relays}

\item{max_relays_per_team}{an integer value denoting the number of relays a
team may score (usually 1)}

\item{keep_nonscoring}{are athletes in places greater than \code{max_place}
be retained in the data frame.  Either \code{TRUE} or \code{FALSE}}

\item{verbose}{should warning messages be posted.  Default is \code{TRUE} and
should rarely be changed.}
}
\value{
a data frame modified so that places have been appended based on
  swimming time and/or diving score
}
\description{
Places are awarded on the basis of time, with fastest (lowest) time winning.
For diving places are awarded on the basis of score, with the highest score
winning.
Ties are placed as ties (both athletes get 2nd etc.)
}
\examples{
  df <- data.frame( Place = c(1, 1, 1, 1, 1, 1), Name = c("Sally Swimfast",
  "Bonnie Bubbles", "Kylie Kicker", "Riley Ripit", "Nathan Nosplash", "Tim
  Tuck"), Team = c("KVAC", "UBAM", "MERC", "Upstate Diving", "Nickel City
  Splash", "Finger Lakes Diving"), Event = c(rep("Women 200 Freestyle", 3),
  rep("Boys 1 mtr Diving", 3)), Prelims = c("2:00.00", "1:59.99", "2:01.50",
  "300.00", "305.00", "200.00"), Finals = c("1:58.00", "1:59.50", "2:00.50",
  "310.00", "307.00", "220.00"), Meet = c("Summer 2021", "Fall 2020", "Champs
  2020","Regional Champs 2021", "Other Regional Champs 2021", "City Champs
  2021" ))

df \%>\%
  place() \%>\%
  dplyr::arrange(Event)

df \%>\%
  place(result_col = Prelims) \%>\%
  dplyr::arrange(Event)

df \%>\%
  place(result_col = "Prelims") \%>\%
  dplyr::arrange(Event)

}
\seealso{
\code{swim_place} is a helper function used inside of
  \code{results_score}
}
