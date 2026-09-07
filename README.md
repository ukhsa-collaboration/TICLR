# Timeline for Infection Clusters tool in R (TICLR)

**Version:** 2.1.0.0

## Requirements

* R >= 4.2.0

## Installing the package

Install directly from GitHub using the `remotes` package:

``` r
# install.packages("remotes")
remotes::install_github("ukhsa-collaboration/TICLR")
```

## Launching the app

Load the package and run the app with `run_app()`:

``` r
library(TICLR)
run_app()
```

## Importing data

Input data must meet a specified long format with each row representing a patient movement. Five columns are required to produce a timeline. 
These columns should contain data corresponding to:

* Unique patient identifier
* Movement number for each patient
* Unique location identifier
* Start date of each movement
* End date of each movement

The following columns are optional:
* Date of symptoms onset
* Date of symptoms end
* Date of positive specimen
* Date of death
* Case definition
* Date of negative screen
* Additional category (for use in filters), e.g., microbiological typing

TICLR is compatible with comma separated text (.txt or .csv). TICLR accepts three different date formats (DMY, MDY, YMD; e.g. 01/12/2026, 12/01/2026, 2026/12/01) and any separator (e.g. - or 
/). It is not possible to edit data loaded into TICLR; all data editing must be done prior to loading into TICLR.

## Example data and template

Example datasets are provided and can be loaded from the Input Data tab to explore TICLR's features without needing your own data.

A blank csv template with recommended field names can also be downloaded from the Input Data tab.

## Displaying data

Once a dataset has been loaded, ensure that the appropriate field has been selected from the drop down options for all compulsory columns, and any optional columns required. If the imported data 
uses the suggested column names included in the template, these will auto-populate. 

All five compulsory fields required by TICLR must be mapped in order to plot a timeline.

When the dataset is loaded, and column mapping has been completed, the raw and cleaned datasets will be presented in tables below the mapping options. Any issues identified during data cleaning, 
e.g., missing data or incorrect date formats, will be displayed as a warning. Manually correct these in the dataset and upload the updated data.

**Please note**: Movements and symptom onsets with no end date will be automatically extended to the current date, assuming that the patient is still admitted to this location. If this is not the case, manually update
the end date and upload to TICLR.

## Customising the timeline

A limited number of location colours are available: 8 (Accent, Dark 2, Set 2, Colour blind), 9 (Set 1), 11 (Spectral), 12 (Set 3), 20 (Tableau20). Only colour schemes with the required number of colours will 
be available after data has been imported.

The options for timeline customisation will vary depending on the optional fields included in the imported data set.

The timeline can be downloaded as a ggplot object (.rds) for additional user customisation.

## Changes from version 2

* Help guides can now be found in the buttons located on each page
* Ability to download a csv template for data collection
* Improved variable selection during data import
* Added data quality warnings to data import
* Added tables showing raw and cleaned data
* Ability to present dates of negative screens
* Optional suppression of time periods with no admissions
* Ability to display single day admissions
* Options to download timeline as an svg file or customisable ggplot object
* Ability to filter by date range, location, case definition, and an additional customisable field
* Ability to present case definitions of cases as a symbol on y-axis
* Colour-blind friendly palette added
* Timeline options presented in tabs
* Renv added for managing packages. See README.md for renv instructions
