
# > PROJECT INFO
# NAME: AMAZON PRIORITY MUNICIPALITIES - EXAMPLE
# LEAD: JOÃO VIEIRA
#
# > THIS SCRIPT
# AIM: GENERATE FIGURE 1: BALANCED EVENT-STUDY PLOT
# AUTHOR: JOÃO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIMER
tictoc::tic(msg = "fig1_eventStudyBalanced_analysis.R script", log = T)





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# load balanced event-study output
reg.did.eventStudyBalanced <- readRDS(file = here::here("data/analysis/regressions/reg_did_eventStudyBalanced.rds"))





# GENERATE FIGURE ------------------------------------------------------------------------------------------------------------------------------------

# FIGURE 1: BALANCED EVENT-STUDY PLOT
plot.did.eventStudyBalanced <-
  reg.did.eventStudyBalanced %>%
  did::ggdid()





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

ggplot2::ggsave(plot = plot.did.eventStudyBalanced,
                filename = here::here(glue::glue("results/figures/fig1_eventStudyBalanced.png")),
                width = 12, height = 6, dpi = 300)


# END TIMER
tictoc::toc(log = T)

# export time to csv table
ExportTimeProcessing("code/analysis")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------