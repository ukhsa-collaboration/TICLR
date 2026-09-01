#' mod_help_about page UI function
#'
#' @description A Shiny module
#'
#' @param id A shiny session id
#' @export

mod_help_about <- function(id) {

  #namespace
  ns <- NS(id)

  tagList(
    mainPanel(
      h3("About"),
         p(),
      h6(tags$b("TICLR"), "is a Timeline for Infection Clusters tool for Shiny by RStudio. It is based upon a spreadsheet created by Gareth Hughes and Mark Reacher, later developed into an R shiny app by Gareth Hughes and Adrian Wensley."),
         p(),

      ## create tabsets
      tabsetPanel(
        ## add some instructions for use
        tabPanel(
          "Instructions for use",
          p(),
      h6(tags$b("Importing data")),
      h6("Input data must meet a specified long format with each row representing a patient movement. Five columns are required to produce a timeline.
         These columns should contain data corresponding to:"),
      tags$ul(
        tags$li("Unique patient identifier"),
        tags$li("Movement number for each patient"),
        tags$li("Unique location identifier"),
        tags$li("Start date of each movement"),
        tags$li("End date of each movement")),
      h6("The following columns are optional:"),
      tags$ul(
        tags$li("Date of symptoms onset"),
        tags$li("Date of symptoms end"),
        tags$li("Date of positive specimen"),
        tags$li("Date of death"),
        tags$li("Case definition"),
        tags$li("Date of negative screen"),
        tags$li("Additional category (for use in filters), e.g., microbiological typing")
      ),
      h6("TICLR is compatible with comma separated text (.txt or .csv). TICLR accepts three different date formats (DMY, MDY, YMD; e.g. 01/12/2026, 12/01/2026, 2026/12/01) and any separator (e.g. - or
          /). Datetime formats are also supported (e.g. 01/12/2026 14:30). Please note that a consistent date formatting must be used for the entire dataset. It is not possible to edit data loaded into TICLR; all data editing must be done prior to loading into TICLR."),
      p(),
      h6("An example data set containing all mandatory and optional fields can be loaded by selecting the tick box. A blank csv template with recommended field names can also be downloaded from the Input Data
tab."),
      p(),
      h6(tags$b("Displaying data")),
      h6("Once a dataset has been loaded, ensure that the appropriate field has been selected from the drop down options for all compulsory columns, and any optional columns required. If the imported data
         uses the suggested column names included in the template, these will auto-populate."),
      p(),
      h6("All five compulsory fields required by TICLR must be mapped in order to plot a timeline."),
      p(),
      h6("When the dataset is loaded, and column mapping has been completed, the raw and cleaned datasets will be presented in tables below the mapping options. Any issues identified during data cleaning,
         e.g., missing data or incorrect date formats, will be displayed as a warning. Manually correct these in the dataset and upload the updated data."),
      p(),
      h6(tags$b("Please note:"), tags$i("Movements and symptom onsets with no end date will be automatically extended to the current date, assuming that the patient is still admitted to this location. If this is not the case, manually update
         the end date and upload to TICLR.")),
      p(),
      h6(tags$b("Customising the timeline")),
      h6("A limited number of location colours are available: 8 (Accent, Dark 2, Set 2, Colour blind), 9 (Set 1), 11 (Spectral), 12 (Set 3), 20 (Tableau20). Only colour schemes with the required number of colours will
          be available after data has been imported. Individual location colours can also be manually customised."),
      p(),
      h6("The options for timeline customisation will vary depending on the optional fields included in the imported data set."),
      p(),
      h6("The timeline can be downloaded as a ggplot object (.rds) for additional user customisation."),
      p()
      ),

        ## outline changes from version 2
      tabPanel(
      "Updates since last version",
      p(),
      h6("This is version v3.1.0 of the TICLR tool. Recent updates include:"),
           tags$ul(
           tags$li("Help guides can now be found in the buttons located on each page"),
           tags$li("Ability to download a csv template for data collection"),
           tags$li("Improved variable selection during data import"),
           tags$li("Added data quality warnings to data import"),
           tags$li("Added tables showing raw and cleaned data"),
           tags$li("Plotly functionality has been incorporated into the timeline, including interactive hover labels, legend-based filtering, and zoom capabilities"),
           tags$li("Ability to present dates of negative screens"),
           tags$li("Optional suppression of time periods with no admissions"),
           tags$li("Ability to display single day admissions"),
           tags$li("Ability to show multiple patient movements in one day"),
           tags$li("Support added for datetime formats."),
           tags$li("Options to download timeline as an svg file or customisable ggplot object"),
           tags$li("Ability to filter by date range, location, case definition, and an additional customisable field"),
           tags$li("Ability to present case definitions of cases as a symbol on y-axis"),
           tags$li("Added a colour-blind friendly palette, with the option to manually customise colours for individual locations"),
           tags$li("Timeline options presented in tabs"),
           tags$li("Renv added for managing packages"),
           tags$li("Bookmarking settings added"),
           tags$li("Dashboard hosting moved to Shiny server")),
      p("Thanks to developers and contributors: Chloe Byers, Jade Talbot, Joe Alberts, Josh Carter, Katie Wrenn and Lara Utsi, as well as colleagues from the EpiDS team (Emma Parker, Frederick Sloots, Greg Parker, James Duke and Steve Parrett)")

      ),

      ## add contact info
      tabPanel(
        "Contact",
        p(),
          h6("For any queries please contact the UKHSA Field Service Incident Response Improvement Group (IRIG)", tags$a(href="mailto:irig@ukhsa.gov.uk", "(irig@ukhsa.gov.uk)")),
          style='width: auto; height: auto',
      width = 12
    ),
   )
  )
  )
}

#' mod_help_about_server page server function
#'
#' @param id A shiny session id
#'
#' @export
mod_help_about_server <- function(id) {

  moduleServer(id, function(input, output, session) {

  })
}
