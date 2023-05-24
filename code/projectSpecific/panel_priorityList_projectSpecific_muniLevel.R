
# > PROJECT INFO
# NAME: PRIORITY MUNICIPALITIES AMAZON - EXAMPLE
# LEAD: JOAO VIEIRA
#
# > THIS SCRIPT
# AIM: ADD AMAZON PRIORITY LIST DATA TO MUNI LEVEL PANEL SAMPLE
# AUTHOR: JOAO VIEIRA
#
# > NOTES
# 1: -




# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIMER
tictoc::tic(msg = "panel_priorityList_projectSpecific_muniLevel.R script", log = T)





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# PANEL MUNI LEVEL SAMPLE
panel.sample.muniLevel <- readRDS(file = here::here("data/projectSpecific/muniLevel/panel_sample_muniLevel.rds"))


# AMAZON PRIORITY LIST
clean.priorityList <- readRDS(file = here::here("data/raw2clean/priorityList_mma/output", "clean_priorityList.rds"))





# DATA MANIPULATION ----------------------------------------------------------------------------------------------------------------------------------

# MERGE PRIORITY LIST WITH PANEL SAMPLE
# check if all municipalities in the list are contained in the muni sample (as they should)
if(sum(unique(paste(clean.priorityList$muni_name, clean.priorityList$state_uf)) %in% unique(paste(panel.sample.muniLevel$muni_name, panel.sample.muniLevel$state_uf))) != length(unique(paste(clean.priorityList$muni_name, clean.priorityList$state_uf)))) {
  warning("Not all municipalities in the priority list are contained in the muni sample")
}

# merge
panel.priorityList.muniLevel <-
  panel.sample.muniLevel %>%
  dplyr::left_join(clean.priorityList, by = c("muni_name", "state_uf"))

# check if the number of rows for the panel sample is the same after the merge (as it should)
if(nrow(panel.sample.muniLevel) != nrow(panel.sample.muniLevel)) {
  warning("Different number of rows after merge. Check duplicates!")
}

# PRODES YEAR ADJUSTMENT
# based on the month of each priority list we can adjust the entry and exit years to the PRODES format (Aug/t-1 to Jul/t)
panel.priorityList.muniLevel <-
  panel.priorityList.muniLevel %>%
  dplyr::mutate(priorityList_entryYear_prodes = dplyr::if_else(priorityList_entryYear %in%  c(2012, 2017),
                                                priorityList_entryYear + 1,
                                                priorityList_entryYear), # 2012 and 2017 lists were published in the 2nd semester so they belong to the following PRODES year
         priorityList_exitYear_prodes  = dplyr::if_else(priorityList_exitLawOrdinance  %in% c("Portaria n 324/2012", "Portaria n 412/2013", "Portaria n 362/2017"),
                                                priorityList_exitYear  + 1,
                                                priorityList_exitYear )) # one list from 2012, 2013 and 2017 exit lists were published in the 2nd semester so they belong to the following PRODES year


# VARIABLE CONSTRUCTION: PRIORITY LIST ANNUAL STATUS INDICATOR (ACTIVE) AND CROSS-SECTION HISTORY INDICATOR (EVER)
# /!\ classification criteria: priorityList_active == 1 if year >= priorityList_entryYear and year < priorityList_exitYear, == 0 otherwise
panel.priorityList.muniLevel <-
  panel.priorityList.muniLevel %>%
  dplyr::mutate(priorityList_active = dplyr::if_else(year >= priorityList_entryYear & !is.na(priorityList_entryYear) &
                                                       (year < priorityList_exitYear | is.na(priorityList_exitYear)),
                                                     1, 0)) %>% # active status indicator creation
  dplyr::mutate(priorityList_active_prodes = dplyr::if_else(year >= priorityList_entryYear_prodes & !is.na(priorityList_entryYear_prodes) &
                                                              (year < priorityList_exitYear_prodes | is.na(priorityList_exitYear_prodes)),
                                                     1, 0)) %>% # active status indicator creation (prodes)
  dplyr::group_by(muni_code) %>% # group by muni-level
  dplyr::mutate(priorityList_ever = if_else(any(priorityList_active == 1), 1, 0)) %>% # ever status indicator creation
  dplyr::ungroup() # remove grouping


# SELECT COLUMNS OF INTEREST AND ORDER VARIABLES
panel.priorityList.muniLevel <-
  panel.priorityList.muniLevel %>%
  dplyr::select(muni_code, year, starts_with("priorityList"), -ends_with("LawOrdinance")) %>%
  dplyr::arrange(muni_code, year)





# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
# check existing labels
sjlabelled::get_label(panel.priorityList.muniLevel)

# add labels when missing
sjlabelled::set_label(panel.priorityList.muniLevel$priorityList_entryYear_prodes) <- "PRODES year when the municipality was placed on the priority list (4-digits, cross-section, MMA-2017)"
sjlabelled::set_label(panel.priorityList.muniLevel$priorityList_exitYear_prodes) <- "PRODES year when the municipality was removed from the priority list (4-digits, cross-section, MMA-2017)"
sjlabelled::set_label(panel.priorityList.muniLevel$priorityList_active) <- "= 1 if the municipality was on the priority list in the current calendar year, =0 otherwise (binary, panel, MMA-2017)"
sjlabelled::set_label(panel.priorityList.muniLevel$priorityList_active_prodes) <- "= 1 if the municipality was on the priority list in the current PRODES year, =0 otherwise (binary, panel, MMA-2017)"
sjlabelled::set_label(panel.priorityList.muniLevel$priorityList_ever) <- "= 1 if the municipality was ever placed on the priority list, =0 otherwise (binary, cross-section, MMA-2017)"


# POST-TREATMENT OVERVIEW
# summary(panel.priorityList.muniLevel)





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

saveRDS(panel.priorityList.muniLevel,
        file = here::here("data/projectSpecific/muniLevel", "panel_priorityList_muniLevel.rds"))



# END TIMER
tictoc::toc(log = T)

# export time to csv table
ExportTimeProcessing("code/projectSpecific")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------
