
# > PROJECT INFO
# NAME: AMAZON PRIORITY MUNICIPALITIES - EXAMPLE
# LEAD: JOÃO VIEIRA
#
# > THIS SCRIPT
# AIM: GENERATE TABLE 1 NAME: SUMMARY STATISTICS BY TREATMENT COHORT
# AUTHOR: JOÃO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIMER
tictoc::tic(msg = "tab1_summaryStat_analysis.R script", log = T)





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# PANEL FOR ANALYSIS
panel.sampleForAnalysis.muniLevel <- readRDS(file = here::here("data/projectSpecific/muniLevel/panel_sampleForAnalysis_muniLevel.rds"))





# DATA PREP ------------------------------------------------------------------------------------------------------------------------------------------

# SELECT TIME PERIOD (PRE-TREATMENT AFTER 2001) + DEFINE CONTROL GROUP + SELECT RELEVANT VARIABLES
panel.sampleForAnalysis.muniLevel <-
  panel.sampleForAnalysis.muniLevel %>%
  dplyr::filter(year >= 2000 & year <= 2007) %>%
  dplyr::mutate(cohort_priorityList = dplyr::if_else(is.na(priorityList_entryYear), "never-treated", as.character(priorityList_entryYear))) %>%
  dplyr::select(muni_code, muni_area, muni_amazon_share, year, cohort_priorityList, starts_with("prodesAmazon"))





# GENERATE TABLE -------------------------------------------------------------------------------------------------------------------------------------

# define sd function with stat inside parenthesis
SD <- function(x) paste0('(', format(round(sd(x, na.rm = TRUE), 2), 2), ')')

# generate table by treatment group
tab1 <-
  panel.sampleForAnalysis.muniLevel %>%
  dplyr::group_by(muni_code, cohort_priorityList) %>%
  dplyr::summarise(`Average Annual Deforestation Area in 2000-2007 (1,000 km2)` = mean(prodesAmazon_deforestIncrement, na.rm=TRUE)/1000,
                   `Share of Muni Area in the Amazon (\\%)` = 100*mean(muni_amazon_share),
                   `Muni Area (1,000 km2)` = mean(muni_area)/1000,
                   `Accumulated Deforestation Area in 2007 (1,000 km2)` = max(prodesAmazon_deforestAccumulated)/1000,
                   `Forest Area in 2007 (1,000 km2)` = min(prodesAmazon_forest)/1000,
                   `Non-Forest Area in 2007 (1,000 km2)` = max(prodesAmazon_nonForest)/1000,
                   `Hidrography Area in 2007 (1,000 km2)` = max(prodesAmazon_hidrography )/1000) %>%
  dplyr::ungroup() %>%
  dplyr::select(-muni_code) %>%
  as.data.frame() %>%

  modelsummary::datasummary(formula = modelsummary::All(.)*(modelsummary::Mean+SD) + N ~ Factor(cohort_priorityList,
                                                                                  levelnames = c("2008", "2009", "2011", "2012", "2017", "Never")),
                            data = .,
                            fmt = 2, output = "data.frame", escape = FALSE) %>%
  dplyr::select(-"  ")

# add number of farms by group
tab1[15,1] <- "Municipalities (\\#)"





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

tab1 %>%
  kableExtra::kbl(booktabs = TRUE, escape = FALSE, linesep = c(rep("", 19), "\\addlinespace"), format = "latex", align = "lcccccc") %>%
  kableExtra::add_header_above(c("", "Treatment" = 5, "Control" = 1)) %>%
  kableExtra::column_spec(2:6, "2cm") %>%
  kableExtra::row_spec(14, hline_after = TRUE) %>%
  kableExtra::save_kable(file = here::here("results/tables/tab1_summaryStat.tex"))


# END TIMER
tictoc::toc(log = T)

# export time to csv table
ExportTimeProcessing("code/analysis")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------