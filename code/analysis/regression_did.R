
# > PROJECT INFO
# NAME: AMAZON PRIORITY MUNICIPALITIES - EXAMPLE
# LEAD: JOÃO VIEIRA
#
# > THIS SCRIPT
# AIM: RUN MAIN DID REGRESSIONS
# AUTHOR: JOÃO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIMER
tictoc::tic(msg = "regression_did_analysis.R script", log = T)





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# PANEL FOR ANALYSIS
panel.sampleForAnalysis.muniLevel <- readRDS(file = here::here("data/projectSpecific/muniLevel/panel_sampleForAnalysis_muniLevel.rds"))





# DATA PREP ------------------------------------------------------------------------------------------------------------------------------------------

# SELECT TIME PERIOD + TRANSFORM OUTCOME + DEFINE CONTROL GROUP + SELECT RELEVANT VARIABLES
panel.sampleForAnalysis.muniLevel <-
  panel.sampleForAnalysis.muniLevel %>%
  dplyr::filter(year >= 2001 & year <= 2019) %>%
  dplyr::mutate(ihs_deforest = asinh(prodesAmazon_deforestIncrement)) %>%
  dplyr::mutate(cohort_priorityList = dplyr::if_else(is.na(priorityList_entryYear), 0, priorityList_entryYear)) %>%
  dplyr::select(muni_code, year, ihs_deforest, cohort_priorityList)





# ESTIMATION -----------------------------------------------------------------------------------------------------------------------------------------

# set seed for reproducibility (did uses a bootstrap procedure to calculat SEs of the estimates)
set.seed(970)


# estimate group-time ATTs
reg.did.groupTime <-
  did::att_gt(yname = "ihs_deforest",
              tname = "year",
              idname = "muni_code",
              gname = "cohort_priorityList",
              clustervars = "muni_code",
              data = panel.sampleForAnalysis.muniLevel,
              panel = T, base_period = "universal",
              control_group = "notyettreated")

# aggregate estimation to balanced eventStudy-study (e=-7:4)
reg.did.eventStudyBalanced <- did::aggte(reg.did.groupTime, type = "dynamic", balance_e = 2, min_e = -7)

# aggregate estimation to unbalanced eventStudy-study (e=-16:11)
reg.did.eventStudyUnbalanced <- did::aggte(reg.did.groupTime, type = "dynamic")





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

# save regression outputs
saveRDS(reg.did.groupTime, file = here::here("data/analysis/regressions/reg_did_groupTime.rds"))
saveRDS(reg.did.eventStudyBalanced, file = here::here("data/analysis/regressions/reg_did_eventStudyBalanced.rds"))
saveRDS(reg.did.eventStudyUnbalanced, file = here::here("data/analysis/regressions/reg_did_eventStudyUnbalanced.rds"))


# END TIMER
tictoc::toc(log = T)

# export time to csv table
ExportTimeProcessing("code/analysis")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------