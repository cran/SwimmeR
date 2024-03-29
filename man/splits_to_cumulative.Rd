% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/splits_to_cumulative.R
\name{splits_to_cumulative}
\alias{splits_to_cumulative}
\title{Converts splits from lap to cumulative format}
\usage{
splits_to_cumulative(df, threshold = Inf)
}
\arguments{
\item{df}{a data frame containing results with splits in lap format.  Must
be formatted in a "normal" SwimmeR fashion - see vignette}

\item{threshold}{a numeric value above which a split is taken to be
cumulative.  Default is \code{Inf}}
}
\value{
a data frame with all splits in lap form
}
\description{
Cumulative splits are when each split is the total elapsed time at a given
distance.  For example, if an athlete swims the first 50 of a 200 yard race
in 25.00 seconds (lap and cumulative split), and the second 50 (i.e. the 100
lap split) in 30.00 seconds the cumulative 100 split is 25.00 + 30.00 =
55.00.  Some swimming results are reported with lap splits (preferred), but
others use cumulative splits.  This function converts lap splits to
cumulative splits.
}
\examples{
\dontrun{
df <- data.frame(Place = rep(1, 2),
                Name = c("Lenore Lap", "Casey Cumulative"),
                Team = rep("KVAC", 2),
                Event = rep("Womens 200 Freestyle", 2),
                Finals = rep("1:58.00", 2),
                Split_50 = rep("28.00", 2),
                Split_100 = c("31.00", "59.00"),
                Split_150 = c("30.00", "1:29.00"),
                Split_200 = c("29.00", "1:58.00")
               )

 # since one entry is in lap time and the other is cumulative, need to
 # set threshold value

 # not setting threshold will produce bad results by attempting to convert
 # Casey Cumulative's splits, which are already in cumulative
 # format, into cumulative format again

 df \%>\%
   splits_to_cumulative()

 df \%>\%
   splits_to_cumulative(threshold = 20)

 }
}
\seealso{
\code{splits_to_cumulative} is the reverse of
  \code{\link{splits_to_lap}}
}
