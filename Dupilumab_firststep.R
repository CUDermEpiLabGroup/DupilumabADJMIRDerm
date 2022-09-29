
#=== DUPILUMAB FIRST STEP =========================================================
# This file read data from Google Big Query and writes locally to your Eureka Instance.

## CHANGE THIS LOCATION TO WRITE FILES LOCALLY 
save_location <- "/home/grace.bosma/Documents/Dupilumab"

#--- Packages -------------------------------------------------------------------
library(bigrquery)
library(remotes)
remotes::install_github("ohdsi/Hades") 

#--- Functions -------------------------------------------------------------------

read_googlebigquery <- function(tablename, folder = 'atopic_dermatitis', project = 'hdcdm2687'){
  # Requires: project name as defined by Google Big Query, folder name the tables are saved under
  # as well as the name of table of interst and google bigquery username for auth. 
  # Function: Creates SQL code to pull from Google Biquery and writes the tables locally
  # to Documents > [project name] in a csv format

  Sql <- sprintf('#standardSQL
      SELECT *
      FROM `%s.%s.%s`', project, folder, tablename)
  
  #table <- query_exec(Sql, project=project, use_legacy_sql=FALSE, max_pages=Inf)
  table <- bq_table_download(bq_project_query(project, Sql), bigint = "character")

  return(table)
}

#--- READ ------------------------------------------------------------------------

care_site <- read_googlebigquery("care_site")
concept   <- read_googlebigquery("concept")
concept_ancestor <- read_googlebigquery("concept_ancestor")
concept_relationship   <- read_googlebigquery("concept_relationship")
condition_occurrence <- read_googlebigquery("condition_occurrence")
death <- read_googlebigquery(project, folder, "death")
drug_exposure <- read_googlebigquery("drug_exposure")
drug_strength <- read_googlebigquery("drug_strength")
encounter <- read_googlebigquery("encounter")
location <- read_googlebigquery("location")
measurement <- read_googlebigquery("measurement")
observation <- read_googlebigquery("observation")
observation_period <- read_googlebigquery("observation_period")
person <- read_googlebigquery("person")
provider <- read_googlebigquery("provider")
visit_detail <- read_googlebigquery("visit_detail")
visit_occurrence <- read_googlebigquery("visit_occurrence")

#--- WRITE -------------------------------------------------------------------------
write.csv(care_site, file=sprintf("%s/%s.csv", save_location, 'care_site'))
write.csv(concept, file=sprintf("%s/%s.csv", save_location, 'concept'))
write.csv(concept_ancestor, file=sprintf("%s/%s.csv", save_location, 'concept_ancestor'))
write.csv(concept_relationship, file=sprintf("%s/%s.csv", save_location, 'concept_relationship'))
write.csv(condition_occurrence, file=sprintf("%s/%s.csv", save_location, 'condition_occurrence'))
write.csv(death, file=sprintf("%s/%s.csv", save_location, 'death'))
write.csv(drug_exposure, file=sprintf("%s/%s.csv", save_location, 'drug_exposure'))
write.csv(drug_strength, file=sprintf("%s/%s.csv", save_location, 'drug_strength'))
write.csv(encounter, file=sprintf("%s/%s.csv", save_location, 'encounter'))
write.csv(location, file=sprintf("%s/%s.csv", save_location, 'location'))
write.csv(measurement, file=sprintf("%s/%s.csv", save_location, 'measurement'))
write.csv(observation, file=sprintf("%s/%s.csv", save_location, 'observation'))
write.csv(observation_period, file=sprintf("%s/%s.csv", save_location, 'observation_period'))
write.csv(person, file=sprintf("%s/%s.csv", save_location, 'person'))
write.csv(provider, file=sprintf("%s/%s.csv", save_location, 'provider'))
write.csv(visit_detail, file=sprintf("%s/%s.csv", save_location, 'visit_detail'))
write.csv(visit_occurrence, file=sprintf("%s/%s.csv", save_location, 'visit_occurrence'))




