% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tteep.R
\name{tteep}
\alias{tteep}
\title{Common time to event end-points calculator}
\usage{
tteep(start_date = NULL, prog_date = NULL, death_date = NULL,
  last_fup = NULL, ep = c("os", "pfs", "ttp"))
}
\arguments{
\item{start_date}{Date: starting follow up date}

\item{prog_date}{Date: progression date}

\item{death_date}{Date: death date}

\item{last_fup}{Date: last follow up date}

\item{ep}{character: which end points to calculate, default to \code{c("os","pfs","ttp")}}
}
\value{
a \code{data.frame} to be used with \code{\link{cbind}}.
}
\description{
This function calculates common oncology time to event end-points (Overall
Survival, Progression Free Survival, Time to Relapse).
}
\details{
Overall survival (OS) is computed as time from \code{start_date} to
\code{death_date}. Time of patients who did not experienced the event
(with missing \code{death_date}) is censored at the time of last follow
up (\code{last_fup}).

Progression free survival (PFS) is calculated as time from
\code{start_date} to \code{prog_date} or \code{death_date}, whichever
comes first. Time of patients who did not experienced any event (missing
both \code{prog_date} and \code{death_date}) is censored at the time of
last follow up (\code{last_fup}).

Time to progression (TTP) is computed as time from \code{start_date} to
\code{prog_date}. Time of patients who did not experienced the event
(missing \code{prog_date}) is censored at the time of last follow up
(\code{last_fup}) or death (\code{death_date}) whichever comes first.
}
\examples{
db <- data.frame(start_date = as.Date(c("1900-01-01", "1900-01-01", "1900-01-01",
                                        "1900-01-01", NA, "1900-01-01", NA)),
                 prog_date  = as.Date(c("1900-03-01", "1900-03-01", NA, NA, NA, NA, NA)),
                 death_date = as.Date(c("1900-06-01", NA, "1900-06-01", NA, NA, NA, NA)),
                 last_fup   = as.Date(c("1900-06-01", "1900-12-31", "1900-06-01",
                                        "1900-12-31", "1900-12-31", NA, NA)))
db
with(db, tteep(start_date, prog_date, death_date, last_fup))
db2 <- data.frame(start_date = c(0,  0,  0,  0, NA,  0, NA),
                  prog_date  = c(3,  3, NA, NA, NA, NA, NA),
                  death_date = c(6, NA,  6, NA, NA, NA, NA),
                  last_fup   = c(6, 12,  6, 12, 12, NA, NA))
with(db2, tteep(start_date, prog_date, death_date, last_fup))
}
\references{
Guidance for Industry, Clinical Trial Endpoints for the approval of
cancer drugs and biologics, FDA, May 2007
}
