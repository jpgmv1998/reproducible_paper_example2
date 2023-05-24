
# > PROJECT INFO
# NAME: AMAZON PRIORITY MUNICIPALITIES - EXAMPLE
# LEAD: JOÃO VIEIRA
#
# > THIS SCRIPT
# AIM: GENERATE SUPPORTING STATS CITED IN-TEXT
# AUTHOR: JOÃO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIMER
tictoc::tic(msg = "supportingStats_analysis.R script", log = T)





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# PANEL FOR ANALYSIS
panel.sampleForAnalysis.muniLevel <- readRDS(file = here::here("data/projectSpecific/muniLevel/panel_sampleForAnalysis_muniLevel.rds"))





# DATA PREP ------------------------------------------------------------------------------------------------------------------------------------------

# extract only municipalities that entered and exited the priority list
aux.muni.exitPriorityList <-
  panel.sampleForAnalysis.muniLevel %>%
  dplyr::filter(!is.na(priorityList_exitYear)) %>%
  dplyr::group_by(muni_code) %>%
  dplyr::slice(1) %>%
  dplyr::ungroup()




# STATISTICS CITED IN THE TEXT -----------------------------------------------------------------------------------------------------------------------

sink(here::here("results/stats/supportingStats.txt"))

# in-text citation 1
print("(page X): only 21 municipalities exited the priority list ...")

# print the statistic
print(nrow(aux.muni.exitPriorityList))

# in-text citation 2
print("(page X): only two municipalities stayed in the list for less than 4 years")

# print the statistic
aux.muni.exitPriorityList %>%
  dplyr::mutate(priorityList_activeTime = priorityList_exitYear - priorityList_entryYear) %>%
  dplyr::select(priorityList_activeTime) %>%
  table() %>%
  print()

# end printing console output to text file
sink()


# END TIMER
tictoc::toc(log = T)

# export time to csv table
ExportTimeProcessing("code/analysis")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------