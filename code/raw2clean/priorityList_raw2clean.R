
# > PROJECT INFO
# NAME: AMAZON PRIORITY MUNICIPALITIES - EXAMPLE
# LEAD: JOAO VIEIRA
#
# > THIS SCRIPT
# AIM: EXTRACT AMAZON PRIORITY MUNI DATA FROM PDF AND CLEAN IT (MMA-2017)
# AUTHOR: JOAO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIMER
tictoc::tic(msg = "priorityList_raw2clean.R script", log = T)





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# RAW DATA
# extract table from first page of the PDF
raw.priorityList1 <- data.frame(tabulizer::extract_tables(here::here("data/raw2clean/priorityList_mma/input/lista_municipios_prioritarios_AML_2017.pdf"),
                                                                 pages = 1, output = "data.frame", encoding = "UTF-8"))

# extract table from second page of the PDF
raw.priorityList2 <- data.frame(tabulizer::extract_tables(here::here("data/raw2clean/priorityList_mma/input/lista_municipios_prioritarios_AML_2017.pdf"),
                                                                 pages = 2, output = "data.frame", guess = F, encoding = "UTF-8",
                                                                 area = list(c(131.7639 , 101.7254 , 506.5210 , 522.6854))))


# DATA EXPLORATION (use when building the script to understand the input data)
# summary(raw.priorityList1)
# str(raw.priorityList1)
# summary(raw.priorityList2)
# str(raw.priorityList2)





# DATA MANIPULATION ----------------------------------------------------------------------------------------------------------------------------------

# FIRST PAGE TREATMENT - ACTUAL PRIORITY LIST ----

# COLUMN CLEANUP
# names
colnames(raw.priorityList1)

# remove unnecessary column
raw.priorityList1 <-
  raw.priorityList1 %>%
  dplyr::select(-X)

# clean column names
raw.priorityList1 <-
  raw.priorityList1 %>%
  janitor::clean_names()

# translate column names
raw.priorityList1 <-
  raw.priorityList1 %>%
  dplyr::rename(state_uf = "uf",
                muni_name = "nome",
                priorityList_entryYear = "ano_de_entrada",
                priorityList_entryLawOrdinance = "portaria_de_entrada")

# add empty columns to match with table from page 2
raw.priorityList1 <-
  raw.priorityList1 %>%
  dplyr::mutate(priorityList_exitYear  = as.numeric(NA),
                priorityList_exitLawOrdinance = as.character(NA))

# class - no need of change
lapply(raw.priorityList1, class)


# CHARACTER TREATMENT

# clean characters
raw.priorityList1 <-
  raw.priorityList1 %>%
  dplyr::mutate(dplyr::across(tidyselect:::where(is.character),
                              \(x) iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")))



# SECOND PAGE TREATMENT - HISTORIC LIST ----

# COLUMN CLEANUP
# names
colnames(raw.priorityList2)

# clean column names
raw.priorityList2 <-
  raw.priorityList2 %>%
  janitor::clean_names()

# translate column names
raw.priorityList2 <-
  raw.priorityList2 %>%
  dplyr::rename(state_uf = "uf",
                muni_name = "nome",
                priorityList_entryYear = "ano_de",
                priorityList_entryLawOrdinance = "portaria_de_entrada",
                priorityList_exitYear = "ano_de_1",
                priorityList_exitLawOrdinance = "portaria_de_saida")

# class - no need of change
lapply(raw.priorityList2, class)


# CHARACTER TREATMENT

# clean characters
raw.priorityList2 <-
  raw.priorityList2 %>%
  dplyr::mutate(dplyr::across(tidyselect:::where(is.character),
                              \(x) iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")))

# manual fix errors due to double lined cells
raw.priorityList2 <-
  raw.priorityList2 %>%
  dplyr::filter(state_uf != "") %>%
  dplyr::mutate(muni_name = dplyr::case_when(muni_name == "PORTO DOS"    ~ "PORTO DOS GAUCHOS",
                                             muni_name == "SAO FELIX DO" ~ "SAO FELIX DO ARAGUAIA",
                                             muni_name == "SANTANA DO"   ~ "SANTANA DO ARAGUAIA",
                                             muni_name == "SANTA MARIA"  ~ "SANTA MARIA DAS BARREIRAS",
                                             TRUE                        ~ muni_name))

# check columns class
lapply(raw.priorityList2, class)

# change year columns class to numeric
raw.priorityList2 <-
  raw.priorityList2 %>%
  dplyr::mutate(dplyr::across(tidyselect::ends_with("year"), as.numeric))



# MERGE THE TWO PAGES ----

# use bind_rows because both tables have the same columns
raw.priorityList <- dplyr::bind_rows(raw.priorityList1, raw.priorityList2)

# clear objects from global environment
rm(raw.priorityList1, raw.priorityList2)





# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
sjlabelled::set_label(raw.priorityList$state_uf)                       <- "state name (2-characters, cross-section, MMA-2017)"
sjlabelled::set_label(raw.priorityList$muni_name)                      <- "municipality name (character, cross-section, MMA-2017)"
sjlabelled::set_label(raw.priorityList$priorityList_entryYear)         <- "year when the municipality was placed on the priority list, NA = never placed (4-digits, cross-section, MMA-2017)"
sjlabelled::set_label(raw.priorityList$priorityList_entryLawOrdinance) <- "law ordinance name that placed the municipality on the priority list, NA = never placed (character, cross-section, MMA-2017)"
sjlabelled::set_label(raw.priorityList$priorityList_exitYear)          <- "year when the municipality was removed from the priority list, NA = never removed (4-digits, cross-section, MMA-2017)"
sjlabelled::set_label(raw.priorityList$priorityList_exitLawOrdinance)  <- "law ordinance name that removed the municipality from the priority list, NA = never removed (character, cross-section, MMA-2017)"


# POST-TREATMENT OVERVIEW
# summary(raw.priorityList)
# str(raw.priorityList)


# CODEBOOK GENERATION (VARIABLES DESCRIPTION + SUMMARY STATISTICS)

# create text file to be filled with console output
sink(here::here("data/raw2clean/priorityList_mma/documentation/codebook_priorityList.txt"))

# describe all variables
raw.priorityList %>%
  Hmisc::describe() %>%
  print()

# end printing console output to text file
sink()





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

saveRDS(raw.priorityList,
        file = here::here("data/raw2clean/priorityList_mma/output", "clean_priorityList.rds"))


# END TIMER
tictoc::toc(log = T)

# export time to csv table
ExportTimeProcessing("code/raw2clean")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------