Project: Dupilumab Analysis 
PI: Robert Dellavalle, Lisa Schilling
Create by: Grace Bosma

There are a few main documents here: 

- Dupilumab_firststep.R: Pulls data from Google Cloud Query and writes the data locally to csv files (reading directly from GBQ takes some time -- reading in from a locally saved file is much quicker)

- Dupilumab_data_management.R: Cleaning and writing clean datasets locally to "cleaned/" folder

- Dupilumab_report.Rmd: produces the file Dupilumab_Report.html. Collapses some descriptions with graphs and tables

- Dupilumab_Report.html: Output of Dupulumb_report.RMD

- P20023DellavalleSchilling_Background_Dupilumab_medicationlist_atlats.....: this file contains the IDs for all dupiumab prescriptions
