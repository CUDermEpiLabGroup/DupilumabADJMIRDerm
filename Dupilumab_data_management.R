#== SETUP =======================================================================

## CHANGE THIS LOCATION TO READ LOCAL FILES
save_location <- "/home/grace.bosma/Documents/Dupilumab"

#--- Packages -------------------------------------------------------------------
library(bigrquery) 
library(devtools) 
library(tidyverse)
library(lubridate)
library(ggplot2)

gbtheme <-theme_light() + theme(panel.grid.major = element_blank(), 
                                panel.grid.minor = element_blank(), axis.ticks = element_line(color = "grey60"), 
                                plot.title = element_text(hjust=0.5), plot.subtitle = element_text(hjust = 0.5), 
                                text = element_text(size = 10, face = "bold"))


#--- Read in data locally --------------------------------------------------------

# Read in locally saved files (faster than reading in from BigQuery)
# care_site <- read.csv(sprintf("%s/%s.csv", save_location, 'care_site'), stringsAsFactors=FALSE)
concept   <- read.csv(sprintf("%s/%s.csv", save_location, 'concept'), stringsAsFactors=FALSE)
# concept_ancestor <- read.csv(sprintf("%s/%s.csv", save_location, 'concept_ancestor'), stringsAsFactors=FALSE)
# concept_relationship   <-read.csv(sprintf("%s/%s.csv", save_location, 'concept_relationship'), stringsAsFactors=FALSE)
condition_occurrence <- read.csv(sprintf("%s/%s.csv", save_location, 'condition_occurrence'), stringsAsFactors=FALSE)
# death <- read.csv(sprintf("%s/%s.csv", save_location, 'death'), stringsAsFactors=FALSE)
drug_exposure <- read.csv(sprintf("%s/%s.csv", save_location, 'drug_exposure'), stringsAsFactors=FALSE)
#drug_strength <- read.csv(sprintf("%s/%s.csv", save_location, 'drug_strength'), stringsAsFactors=FALSE)
encounter <- read.csv(sprintf("%s/%s.csv", save_location, 'encounter'), stringsAsFactors=FALSE)
# location <- read.csv(sprintf("%s/%s.csv", save_location, 'location'), stringsAsFactors=FALSE) 
# measurement <- read.csv(sprintf("%s/%s.csv", save_location, 'measurement'), stringsAsFactors=FALSE)
# observation <- read.csv(sprintf("%s/%s.csv", save_location, 'observation'), stringsAsFactors=FALSE)
#observation_period <- read.csv(sprintf("%s/%s.csv", save_location, 'observation_period'), stringsAsFactors=FALSE)
person <- read.csv(sprintf("%s/%s.csv", save_location, 'person'), stringsAsFactors=FALSE)
# provider <- read.csv(sprintf("%s/%s.csv", save_location, 'provider'), stringsAsFactors=FALSE)
# visit_detail <- read.csv(sprintf("%s/%s.csv", save_location, 'visit_detail'), stringsAsFactors=FALSE)
visit_occurrence <- read.csv(sprintf("%s/%s.csv", save_location, 'visit_occurrence'), stringsAsFactors=FALSE)

dup_ATLAS <- read.csv("Dupilumab ATLAS Med Codes_Dupilumab_Inj_Schilling_44.csv")

#== Data Cleaning =======================================================================

#--- Merging & Inclusion Criteria -------------------------------------------------------

library(tidyverse)
# grab visit occurence id
visit <- visit_occurrence %>% dplyr::select(person_id, visit_occurrence_id, visit_concept_id, visit_start_date)

# connect concept names to the conditions
condition <- condition_occurrence %>%
  left_join(concept, by=c('condition_concept_id'='concept_id')) %>%
  rename(condition_concept_name=concept_name) %>%
  dplyr::select(person_id, condition_start_date, condition_type_concept_id, condition_occurrence_id, condition_concept_id, condition_concept_name, visit_occurrence_id)
  

nrow(condition) #1,005,096

# sanity check on birth date inclusiveness
# 355 dropped because we want those with birthdate up to 3/28/1932
personSubset <- person %>%
  mutate(birth_datetime = lubridate::make_date(year = year_of_birth, month = month_of_birth, day = day_of_birth)) %>% 
  #remove patients with birth dates outside of protocol range
  filter(birth_datetime > "1932-03-28" & birth_datetime <= "1999-03-28") 
  #COMPASS allowed birthdate up to 3/27/1931, who would be 85 on the day dupilumab approved
  # "between the ages of 4 and 85 on 3/28/2017"
  # UPDATE APRIL 2022: Exclude those 4-18 years of age
 
nrow(personSubset) #114,121

# IDs for atopic neurodermatitis, besniers prurigo, flexural eczema, nummular eczema
condition_concept_ids_of_interest <- c(4066382, 3422350, 45543364, 42490135, 42490135, 1418234, 45611687, 
                                       45944803, 4066727, 45446938, 35208449, 
                                       4210912, 45453585, 3239307, 42490136, 45552974,45925492, 45525139,4290734, 4033771,
                                       #(infantile eczema) 4236759 40319733 40395761 4002519 4321570 45523623 45915599 
                                       #(infantile eczema cont.) 45531141, 3300638, 42490137, 3106599, 3127760, 45917161, 3359070, 3291693,
                                       45611687, 4298599,4216188, 3080828, 3106607, 45927253,40319748,40352945, 
                                       4049417, 37203896, 4221829, 4221830, 4223639, 4221832, 3232239, 4033769, 
                                       133551, 4223498, 4221831, 4292517, 4223476, 3140011, 45914206, 3405877, 
                                       3334939, 3236797, 3362201, 3257465, 3352355, 3276218, 4223477, 4067178, 
                                       4031017, 40458522, 45618091, 
                                       40319730, 133834, 4297478, 4298597, 4031631, 45557698, 4061737, 3534150, 40319732, 
                                       4296193, 4296192, 4080927, 4290734, 4080928, 4298599, 4031013, 4080929, 1418227, 
                                       1469765, 3106596, 4033671, 37610771, 42490132,37086266, 4290740, 4031630, 4290736, 
                                       4296190, 4206125, 45427018, 45925493, 40581054, 45533637, 3250197, 3405763, 3412498, 
                                       3216958, 3304718, 3308761, 3307988, 3265645, 1418230, 1418231, 1569766, 45567351, 3218567, 
                                       3312065, 3261338, 3127765, 3106598, 37606525, 42490134, 42490139, 37086268, 4290738, 442067, 
                                       3530804, 4296191, 44824472, 40482226, 1418285, 3394791, 3244326, 3360855, 3351563, 3354006,
                                       3375021, 3363833, 3316333, 3157496, 4297362, 45948181, 45496996, 1418357, 44836148, 1418392, 
                                       3357360, 3298695, 3072247, 4298601, 4298600, 3303690, 3290906, 1424287, 42490140, 1418238, 1418239, 
                                       37086269, 35208450, 37607432, 45548191, 45450280, 4290737, 3298013, 3371481, 3461132, 
                                       3142484, 4148919, 3540255, 40319736, 3106601, 4290735, 3397124, 45611587)


# checking to see that AD diagnosis dates match our definition - could we find these somewhere else?
# can we upload the concept ids and then see if they match, should have same results
first_AD_diagnosis <- condition %>% 
  #excluded all asthma related, rhinitis, intertrigo, pityriasis alba, Id reaction, 
  # Inflammatory dermatosis, Infective dermatitis
  filter(condition_concept_id %in% condition_concept_ids_of_interest) %>% 
  inner_join(personSubset) %>% 
  arrange(person_id, condition_start_date) %>% 
  group_by(person_id) %>% 
  mutate(include = case_when(sum(condition_start_date >= "2017-03-28") >= 2 ~ 1,
                             sum(condition_start_date >= "2017-03-28") >= 1 & 
                               sum(condition_start_date >= "2013-03-28" & 
                                     condition_start_date < "2017-03-28") >= 1 ~ 1,
                             TRUE ~ 0)) %>% 
  ungroup() %>% 
  left_join(visit)

first_AD_diagnosis$condition_concept_name <- ifelse(first_AD_diagnosis$condition_concept_name == "Besnier's prurigo", "Atopic dermatitis", first_AD_diagnosis$condition_concept_name)


nrow(first_AD_diagnosis) #42,756 new: 36,815

#reasons people are excluded: only 1 diagnosis, no diagnosis in dupilumab window, one diagnosis in
# dupilumab window but none in the lookback window (some are too far back)
# exclude <- first_AD_diagnosis %>%
#              filter(include == 0)


#include has all patients with the correct age range and diagnoses in the correct windows
include <- first_AD_diagnosis %>% 
             filter(include == 1)

nrow(include) #38,871 new: 33600
length(unique(include$person_id)) #6422

#--- Multiple Dx and some Cleaning ---------------------------------------------

#what do we do about multiple different diagnoses per person? 
table(include$condition_concept_name)

# Decdied to keep most recent diagnoses for each individual 
# believe it to be the most accurate diagnoses
most_recent_diagnoses <- include[!duplicated(include$person_id, fromLast = TRUE), ]
most_recent_diagnoses <- most_recent_diagnoses %>% dplyr::select(person_id, condition_concept_name, visit_occurrence_id)

length(unique(include$person_id)) # sanity check 7723
length(most_recent_diagnoses$person_id) # matches above 7723

byperson <- personSubset %>% 
             filter(person_id %in% unique(include$person_id)) %>% 
             mutate(age = round(as.numeric(difftime("2021-03-28", birth_datetime, units = "weeks"))/52.25)) %>% 
             dplyr::select(person_id, age, race_source_value, ethnicity_source_value, gender_source_value, birth_datetime) %>%
             rename(gender=gender_source_value, race=race_source_value, ethnicity=ethnicity_source_value)

#combined the two other pacific islander groups
byperson$race <- ifelse(byperson$race == "Other Pacific Islander", "Native Hawaiian and Other Pacific Islander", byperson$race)

# add most recent diagnoses to byperson dataset
# allows us to include demographics with most recent diagnoses
byperson <- left_join(byperson, most_recent_diagnoses) 

nrow(byperson) #7,723

#---User Prevelence ---------------------------------------------------------------

# connect concept names to dupilumab prescriptions
drug <- drug_exposure %>%
  left_join(concept, by=c('drug_concept_id'='concept_id')) %>%
  rename(drug_concept_name=concept_name) %>%
  dplyr::select(person_id, drug_exposure_start_date, drug_exposure_end_date, drug_type_concept_id, drug_type_concept_id, drug_concept_name, visit_occurrence_id, refills, quantity) %>%
  mutate(time_on_trt = as.numeric(difftime(drug_exposure_end_date, drug_exposure_start_date, units = "weeks"))) %>% 
  filter(drug_exposure$drug_concept_id %in% dup_ATLAS$Id) %>% 
  filter(person_id %in% byperson$person_id)


nrow(drug) #1051

byperson_drug <- byperson %>%
  left_join(dplyr::select(drug, drug_concept_name, person_id), by = c('person_id'= 'person_id'))

nrow(drug) #1051


byperson_drug <- byperson_drug[!duplicated(byperson_drug$person_id, fromLast = TRUE), ]
nrow(byperson_drug) #6422


byperson$received_rx <- ifelse(!is.na(byperson_drug$drug_concept_name), "Received Dupilumab", "Did not Receive")

#=== WRITE ========================================================================
write.csv(byperson, file = "cleaned/byperson.csv")
write.csv(drug, file = 'cleaned/drug.csv')
write.csv(most_recent_diagnoses, file = "cleaned/most_recent_diagnoses.csv")
#write.csv(included_COI, file = "cleaned/included_COI.csv")

