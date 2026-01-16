# 202601 Salmonella Enteritidis cluster
# Author: Alana Little, NEPHU (alana.little@austin.org.au)
# Version 1.0

# PHAR check for Salmonella cases

# Version history --------------------------------------------------------------
# v1.0: First version

# Packages ---------------------------------------------------------------------
# Install the pacman package if you don't already have it
if (!require("pacman")) install.packages("pacman")

pacman::p_load(tidyverse,
               odbc,
               DBI,
               glue)

# Define constants -------------------------------------------------------------
# Start and end dates for one month lookback
date_start <- lubridate::ymd(Sys.Date() - months(1) + days(1))
date_end   <- lubridate::ymd(Sys.Date())

# Connect to PHAR and run queries ----------------------------------------------
con <- DBI::dbConnect(odbc::odbc(), "PHAR", useProxy = 0)

salmonella <- DBI::dbGetQuery(con,
                              glue::glue("SELECT * FROM dh_public_health.phess_release.caseevents_nrt
                                          WHERE CONDITION = 'Salmonellosis' 
                                          AND EVENT_CLASSIFICATION IN ('Confirmed', 'Probable')
                                          AND EVENT_DATE >= DATE '{date_start}'
                                          AND EVENT_DATE <= DATE '{date_end}'"))

salmonella_spp <- salmonella %>%
  janitor::clean_names() %>% 
  #
  dplyr::filter(organism_cause == "Salmonella") %>% 
  #
  dplyr::filter(lphu == "NEPHU")

salmonella_enter <- salmonella %>% 
  janitor::clean_names() %>% 
  #
  dplyr::filter(organism_cause == "Salmonella Enteritidis") %>% 
  #
  dplyr::filter(lphu == "NEPHU")

salmonella_pcr <- salmonella %>% 
  janitor::clean_names() %>% 
  #
  dplyr::filter(organism_cause == "Salmonella by PCR") %>% 
  #
  dplyr::filter(lphu == "NEPHU")

# Close the connection to PHAR -------------------------------------------------
DBI::dbDisconnect(con)

