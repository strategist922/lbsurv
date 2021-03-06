#' Common time to event end-points calculator
#' 
#' This function calculates common oncology time to event end-points (Overall
#' Survival, Progression Free Survival, Time to Relapse).
#'
#' Overall survival (OS) is computed as time from \code{start_date} to
#' \code{death_date}. Time of patients who did not experienced the event
#' (with missing \code{death_date}) is censored at the time of last follow
#' up (\code{last_fup}).
#'
#' Progression free survival (PFS) is calculated as time from
#' \code{start_date} to \code{prog_date} or \code{death_date}, whichever
#' comes first. Time of patients who did not experienced any event (missing
#' both \code{prog_date} and \code{death_date}) is censored at the time of
#' last follow up (\code{last_fup}).
#'
#' Time to progression (TTP) is computed as time from \code{start_date} to
#' \code{prog_date}. Time of patients who did not experienced the event
#' (missing \code{prog_date}) is censored at the time of last follow up
#' (\code{last_fup}) or death (\code{death_date}) whichever comes first.
#' 
#' @param start_date Date: starting follow up date
#' @param prog_date Date: progression date
#' @param death_date Date: death date
#' @param last_fup Date: last follow up date
#' @param ep character: which end points to calculate, default to \code{c("os","pfs","ttp")}
#' @return a \code{data.frame} to be used with \code{\link{cbind}}.
#' @examples
#' db <- data.frame(start_date = as.Date(c("1900-01-01", "1900-01-01", "1900-01-01",
#'                                         "1900-01-01", NA, "1900-01-01", NA)),
#'                  prog_date  = as.Date(c("1900-03-01", "1900-03-01", NA, NA, NA, NA, NA)),
#'                  death_date = as.Date(c("1900-06-01", NA, "1900-06-01", NA, NA, NA, NA)),
#'                  last_fup   = as.Date(c("1900-06-01", "1900-12-31", "1900-06-01",
#'                                         "1900-12-31", "1900-12-31", NA, NA)))
#' db
#' with(db, tteep(start_date, prog_date, death_date, last_fup))
#' db2 <- data.frame(start_date = c(0,  0,  0,  0, NA,  0, NA),
#'                   prog_date  = c(3,  3, NA, NA, NA, NA, NA),
#'                   death_date = c(6, NA,  6, NA, NA, NA, NA),
#'                   last_fup   = c(6, 12,  6, 12, 12, NA, NA))
#' with(db2, tteep(start_date, prog_date, death_date, last_fup))
#' @references
#' Guidance for Industry, Clinical Trial Endpoints for the approval of
#' cancer drugs and biologics, FDA, May 2007
#' @export
tteep <- function(start_date = NULL,
                  prog_date  = NULL,
                  death_date = NULL,
                  last_fup   = NULL,
                  ep = c("os", "pfs", "ttp"))
{

    ## Input check
    if( is.null(start_date) || (! (inherits(start_date, 'Date') || (is.numeric(start_date)))))
        stop('start_date must be date or a numeric')

    if( is.null(last_fup) || (! (inherits(last_fup, 'Date') || (is.numeric(last_fup)))))
        stop('last_fup must be date or a numeric')
    
    if( (!is.null(prog_date)) && (!inherits(prog_date, 'Date')) && (!is.numeric(prog_date)))
        stop('prog_date must be NULL, a Date or a numeric')
    
    if( (!is.null(death_date)) && (!inherits(death_date, 'Date')) && (!is.numeric(death_date)))
        stop('death_date must be NULL, a Date or a numeric')

    if( !is.character(ep) )
        stop('ep must be a character')
    
    ## Create indicator variables if missing
    prog <- if (is.null(prog_date)) rep(NA, length(prog_date)) else !is.na(prog_date)
    death <- if(is.null(death_date)) rep(NA, length(death_date)) else !is.na(death_date)
    
    ## argument preprocessing
    start_date <- as.numeric(start_date)
    prog_date <- as.numeric(prog_date)
    death_date <- as.numeric(death_date)
    last_fup <- as.numeric(last_fup)
    ep <- gsub(' ', '', tolower(ep))

    ## Return value
    rval <- list()
    
    ## Overall survival
    if ("os" %in% ep) { 
        rval$os_status <- os_status <- as.integer(death)
        os_last_date <- ifelse(os_status, death_date, last_fup)
        rval$os_time <- os_last_date - start_date
    } 
    ## Progression Free Survival
    if ("pfs" %in% ep) { 
        rval$pfs_status <- pfs_status <- as.integer(death | prog)
        min_prog_death <- suppressWarnings(
            apply(cbind(death_date, prog_date), 1, min, na.rm = TRUE))
        ## line that follows is to fix when death_date and prog_date are both
        ## NA (default min returns Inf when na.rm = TRUE)
        min_prog_death[!is.finite(min_prog_death)] <- NA
        pfs_last_date <- ifelse(pfs_status, min_prog_death, last_fup)
        rval$pfs_time <- pfs_last_date - start_date
    } 
    ## Time to progression
    if ("ttp" %in% ep) {
        rval$ttp_status <- ttp_status <- as.integer(prog)
        min_death_lfup <- suppressWarnings(
            apply(cbind(death_date, last_fup), 1, min, na.rm = TRUE))
        ## The same as above
        min_death_lfup[!is.finite(min_death_lfup)] <- NA
        ttp_last_date <- ifelse(ttp_status, prog_date, min_death_lfup)
        rval$ttp_time <- ttp_last_date - start_date
    } 

    as.data.frame(rval)[paste(rep(ep, each = 2), c("time", "status"), sep = "_")]

}
