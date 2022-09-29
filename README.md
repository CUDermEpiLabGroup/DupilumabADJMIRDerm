Project: Dupilumab Analysis 
PI: Robert Dellavalle, Lisa Schilling
Create by: Grace Bosma

There are a few main documents here: 

- Dupilumab_firststep.R: Pulls data from Google Cloud Query and writes the data locally to csv files (reading directly from GBQ takes some time -- reading in from a locally saved file is much quicker)

- Dupilumab_data_management.R: Cleaning and writing clean datasets locally to "cleaned/" folder

- Dupilumab_report.Rmd: produces the file Dupilumab_Report.html. Collapses some descriptions with graphs and tables

- Cleaned/ folder: Should be empty. Code in the "first step" file will populated this with cleaned data. If deleted, this code will break

- Dupilumab_Report.html: Output of Dupulumb_report.RMD

- Dupilumab.RProj: R Rproject to work in all of these files

- logo.png is used in RMD file to attach CIDA logo to output

- P20023DellavalleSchilling_Background_Dupilumab_medicationlist_atlats.....: this file contains the IDs for all dupiumab prescriptions

- COPY_Dupilumab_data_management.R contains the old version of data management file. Did not want to delete because it contains a LOT of free text coding using regular expression. Wanted to keep just in case we needed --- if this idea resurfaces, look into using heirarchy codes to pull necessary medications rather than free coding this way.
