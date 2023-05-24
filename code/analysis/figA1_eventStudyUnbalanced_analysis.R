
# > PROJECT INFO
# NAME: AMAZON PRIORITY MUNICIPALITIES - EXAMPLE
# LEAD: JOÃO VIEIRA
#
# > THIS SCRIPT
# AIM: GENERATE FIGURE A1: UNBALANCED EVENT-STUDY PLOT
# AUTHOR: JOÃO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIMER
tictoc::tic(msg = "figA1_eventStudyUnbalanced_analysis.R script", log = T)





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# load balanced event-study output
reg.did.eventStudyUnbalanced <- readRDS(file = here::here("data/analysis/regressions/reg_did_eventStudyUnbalanced.rds"))





# GENERATE FIGURE ------------------------------------------------------------------------------------------------------------------------------------

# FIGURE 1: BALANCED EVENT-STUDY PLOT
plot.did.eventStudyUnbalanced <-
  reg.did.eventStudyUnbalanced %>%
  did::ggdid()





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

ggplot2::ggsave(plot = plot.did.eventStudyUnbalanced,
                filename = here::here(glue::glue("results/figures/figA1_eventStudyUnbalanced.png")),
                width = 12, height = 6, dpi = 300)


# END TIMER
tictoc::toc(log = T)

# export time to csv table
ExportTimeProcessing("code/analysis")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------