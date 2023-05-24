
# > PROJECT INFO
# NAME: PRIORITY MUNICIPALITIES AMAZON - EXAMPLE
# LEAD: JOAO VIEIRA
#
# > THIS SCRIPT
# AIM: ADD PRODES AMAZON LAND COVER/DEFORESTATION DATA TO MUNI LEVEL PANEL SAMPLE
# AUTHOR: JOAO VIEIRA
#
# > NOTES
# 1: -




# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIMER
tictoc::tic(msg = "panel_prodesAmazon_projectSpecific_muniLevel.R script", log = T)





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# PANEL MUNI LEVEL SAMPLE
panel.sample.muniLevel <- readRDS(file = here::here("data/projectSpecific/muniLevel/panel_sample_muniLevel.rds"))


# AMAZON PRIORITY LIST
clean.prodesAmazon <- readRDS(file = here::here("data/raw2clean/prodesAmazon_inpe/output", "clean_prodesAmazon.rds"))





# DATA MANIPULATION ----------------------------------------------------------------------------------------------------------------------------------

# MERGE PRODES AMAZON WITH PANEL SAMPLE
# check if all municipalities in the amazon sample are contained in PRODES (as they should)
if(sum(unique(panel.sample.muniLevel$muni_code) %in% unique(clean.prodesAmazon$muni_code)) != length(unique(panel.sample.muniLevel$muni_code))) {
  warning("The list of municipalities above are in the amazon sample but not in PRODES. For the sake of brevity we are gonna ignore this problem in this example project. However, in a real project this should be further investigated.")

  # print the Amazon sample municipalities not present in PRODES data
  panel.sample.muniLevel %>%
    dplyr::filter(!muni_code %in% clean.prodesAmazon$muni_code) %>%
    dplyr::group_by(muni_code) %>%
    dplyr::slice(1) %>%
    dplyr::ungroup() %>%
    print()
}

# merge
panel.prodesAmazon.muniLevel <-
  panel.sample.muniLevel %>%
  dplyr::left_join(clean.prodesAmazon, by = c("muni_code", "year"))


# SELECT COLUMNS OF INTEREST AND ORDER VARIABLES
panel.prodesAmazon.muniLevel <-
  panel.prodesAmazon.muniLevel %>%
  dplyr::select(muni_code, year, starts_with("prodesAmazon")) %>%
  dplyr::arrange(muni_code, year)



# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
# check existing labels
sjlabelled::get_label(panel.prodesAmazon.muniLevel)

# add labels when missing
sjlabelled::set_label(panel.prodesAmazon.muniLevel$year) <- "PRODES year, starts in August/t-1 and ends in July/t with t = calendar year (4-digits, panel, INPE-2020)"


# POST-TREATMENT OVERVIEW
# summary(panel.prodesAmazon.muniLevel)





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

saveRDS(panel.prodesAmazon.muniLevel,
        file = here::here("data/projectSpecific/muniLevel", "panel_prodesAmazon_muniLevel.rds"))



# END TIMER
tictoc::toc(log = T)

# export time to csv table
ExportTimeProcessing("code/projectSpecific")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------
