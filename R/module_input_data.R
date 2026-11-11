#' mod_input_data UI function
#'
#' @description A Shiny module
#'
#' @param id A shiny session id
#' @export

mod_input_data <- function(id) {

  ns <- NS(id)

  tagList(
    shinyjs::useShinyjs(),
    # Full-screen loading overlay
    shinyjs::hidden(
      div(
        id = ns("loading_overlay"),
        style = "position: fixed; top: 0; left: 0; width: 100%; height: 100%;
                 background-color: rgba(255, 255, 255, 0.8); z-index: 9999;
                 display: flex; align-items: center; justify-content: center;",
        div(
          style = "text-align: center;",
          tags$div(
            class = "fa-3x",
            tags$i(class = "fas fa-spinner fa-spin", style = "color: #3a7abf;")
          ),
          tags$p("Loading data...", style = "margin-top: 10px; font-size: 16px; color: #3a7abf;")
        )
      )
    ),
    # Slide-in notification ribbons
    tags$style(HTML("
      .ticlr-ribbon {
        overflow: hidden;
        max-height: 0;
        opacity: 0;
        transition: max-height 0.4s ease, opacity 0.4s ease, padding 0.4s ease;
        padding: 0 16px;
        border-radius: 4px;
        margin-bottom: 4px;
        font-size: 13px;
        font-weight: bold;
      }
      .ticlr-ribbon.visible {
        max-height: 60px;
        opacity: 1;
        padding: 8px 16px;
      }
      .ticlr-ribbon-red {
        background-color: #f8d7da;
        border-left: 5px solid #c0392b;
        color: #7b1a1a;
      }
      .ticlr-ribbon-amber {
        background-color: #fff3cd;
        border-left: 5px solid #ffc107;
        color: #856404;
      }
    ")),
    uiOutput(ns("ribbon_red")),
    uiOutput(ns("ribbon_amber")),

    actionButton(
        ns("help_btn"),
        label = tagList(icon("info-circle"), "Click here for help"),
        style = "padding: 4px 8px; font-size: 12px;"
      ),
    p(),

    mainPanel(
      h3("Input Data"),
      div(id = "inputs",
        fluidRow(
          column(5,
                 fileInput(
                   ns('fileimport'),
                   label = NULL,
                   accept = c('.csv', '.tsv', '.txt')
                 ),
                 style = "height:30px; padding: 1px; margin-top: 10px"
          ),
          column(5,
                 downloadButton(ns('dltemplate'), 'Download csv template'),
                 style = "height:30px; padding: 1px; margin-top: 10px; font-size: 12px;"
          )
        ),
        p(),
        fluidRow(
          column(8,
            div(
              style = "background-color: #eef6ff; border: 2px solid #3a7abf; border-radius: 6px; padding: 10px 16px; margin-top: 10px; margin-bottom: 10px;",
              checkboxInput(ns('exdata'), tags$strong("Use example data"), FALSE),
              conditionalPanel(
                condition = sprintf("input['%s'] === true", ns('exdata')),
                selectInput(
                  ns('exdata_choice'),
                  label = "Select example dataset:",
                  choices = character(0)
                )
              )
            )
          )
        ),
        br(),
        p(),
        fluidRow(
          column(5,
                 h4("Compulsory columns"),
                 selectInput(ns('patient'),
                             'Patient identifier',
                             choices = c("Upload data then define columns")
                 ),
                 selectInput(ns('movenum'),
                             'Movement number for each patient',
                             choices = c("Upload data then define columns")
                 ),
                 selectInput(ns('location'),
                             'Unique location identifier',
                             choices = c("Upload data then define columns")
                 ),
                 selectInput(ns('startdate'),
                             'Start date of each movement',
                             choices = c("Upload data then define columns")
                 ),
                 selectInput(ns('enddate'),
                             'End date of each movement',
                             choices = c("Upload data then define columns")
                 )
          ),
          column(5,
                 h4("Optional columns"),
                 selectizeInput(ns('symonsdate'),
                             'Date of symptoms onset',
                             choices = c("Upload data then define columns", allowEmptyOption = T)
                 ),
                 selectizeInput(ns('symenddate'),
                             'Date of symptoms end',
                             choices = c("Upload data then define columns", allowEmptyOption = T)
                 ),
                 selectizeInput(ns('specdate'),
                             'Date of positive specimen',
                             choices = c("Upload data then define columns", allowEmptyOption = T)
                 ),
                 selectizeInput(ns('deathdate'),
                             'Date of death',
                             choices = c("Upload data then define columns", allowEmptyOption = T)
                 ),
                 selectizeInput(ns('case_def'),
                             'Case definition',
                             choices = c("Upload data then define columns", allowEmptyOption = T)
                 ),
                 selectizeInput(ns('neg_specdate'),
                             'Date of negative specimen',
                             choices = c("Upload data then define columns", allowEmptyOption = T)
                 ),
                 selectizeInput(ns('extra_cat'),
                             'Additional category for filtering, e.g. typing',
                             choices = c("Upload data then define columns", allowEmptyOption = T)
                 )
           )
        ),
        p(),
          fluidRow(
            h4("Raw data"),
          div(
            DT::dataTableOutput(ns("importtbl")),
            style = "font-size: 80%; width: 80%"
          )
        ),
        p(),
          fluidRow(
          h4("Results of data checks"),
          h6("The following checks will be performed on the input data:"),
          tags$ul(
            style = "list-style-type: none;",
            tags$li(HTML("i) Check that all dates are within an expected format, i.e., Day/Month/Year, Year/Month/Day, Month/Day/Year.")),
            tags$li(HTML("ii) Check to confirm that the startdate of each movement precedes the enddate. If the enddate occurs before the startdate, these rows are highlighted below and will be excluded from the timeline.")),
            tags$li(HTML("iii) The same check is performed for symptom onset start and end dates.")),
            tags$li(HTML("iv) Checks for missing data/values within 4 key variables 'patient', 'location', 'startdate' and 'movenum'.")),
          ),
          h6("These checks will update when you select a dataset for evaluation."),
          div(uiOutput(ns("data_errors")), style = "width: 80%")),
        p(),
        fluidRow(
          tags$style(HTML("
                    .dataTables_wrapper table.dataTable {
                    border: none !important;
                      }
                    .dataTables_wrapper table.dataTable thead th,
                    .dataTables_wrapper table.dataTable tbody td {
                     border-left: none !important;
                     border-right: none !important;
                     }
                    .dataTables_wrapper {
                    border: none !important;
                      }
                    ")),
          h4("Cleaned data with any associated error flags"),
          h6("Rows with errors are highlighted in red and will be excluded from the timeline. The original data values are preserved."),
          div(tags$style(HTML("
              .error-row td {
                background-color: #ffcccc !important; color: darkred;
              }
              ")),
              DT::dataTableOutput(ns("importtbl_final")),
            style = "font-size: 80%; width: 80%"
          )
        )
      ),
      width = 12
    )
  )
}



#' mod_input_data server function
#'
#' @param id A shiny session id
#' @param session A shiny session object
#'
#' @export
mod_input_data_server <- function(id,
                                  session) {

  moduleServer(id, function(input,
                            output,
                            session) {

    observeEvent(input$help_btn, {
      showModal(modalDialog(
        title = "Help",
        tagList(

          h6("Input data must meet a specified long format with each row representing a patient movement. Five columns are required to produce a timeline. These columns should contain data corresponding to:"),
          p("- Unique patient identifier"),
          p("- Movement number for each patient"),
          p("- Unique location identifier"),
          p("- Start date of each movement"),
          p("- End date of each movement"),
          h6("The following columns are optional:"),
          p("- Date of symptoms onset"),
          p("- Date of symptoms end"),
          p("- Date of positive specimen"),
          p("- Date of death"),
          h5("TICLR is compatible with comma separated text (.txt or .csv). TICLR accepts three different date formats (DMY, MDY, YMD; e.g. 01/12/2026, 12/01/2026, 2026/12/01) and any separator (e.g. - or
/)."),
          p(),
          h6("It is not possible to edit data loaded into TICLR; all data editing must be done prior to loading into TICLR.")
        ),
        easyClose = TRUE,
        footer = modalButton("Close"),
        size = "l"
      ))
    })

    # OBTAIN REACTIVE VALUES --------------------------------------------------------------------------------------------------

    input_variables <- c('patient', 'movenum', 'location',
                         'startdate', 'enddate', "symonsdate",
                         "symenddate", "specdate", "deathdate",
                         'neg_specdate', 'extra_cat', 'case_def')


    # Download template for data collection
    output$dltemplate <- downloadHandler(
      filename = 'TICLR template.csv',
      content = function(file) {
        write.csv(exampledata_blank, file, row.names = F)
      })

    # Discover available example datasets from extdata
    extdata_dir <- system.file("extdata", package = "TICLR")
    extdata_files <- list.files(extdata_dir, pattern = "\\.csv$")
    # Pin example_data.csv to top, then sort the rest alphabetically
    base_file <- "example_data.csv"
    other_files <- sort(setdiff(extdata_files, base_file))
    extdata_files_ordered <- c(base_file, other_files)
    extdata_choices <- setNames(
        extdata_files_ordered,
        {
            labels <- gsub("[_-]", " ", sub("\\.csv$", "", extdata_files_ordered))
            paste0(toupper(substr(labels, 1, 1)), tolower(substr(labels, 2, nchar(labels))))
        }
    )
    updateSelectInput(session, "exdata_choice", choices = extdata_choices)

    # Template always based on base example file
    exampledata_blank <- read.csv(file.path(extdata_dir, "example_data.csv"), row.names = 1)[0, ]

    # Reactive example data based on dropdown selection
    example_data <- reactive({
        chosen <- if (!is.null(input$exdata_choice) && nchar(input$exdata_choice) > 0) {
            input$exdata_choice
        } else {
            extdata_files[1]
        }
        read.csv(file.path(extdata_dir, chosen), na.strings = c("NA", ""))
    })

    # If a file is loaded, uncheck the example data checkbox
    observe({
      if (!is.null(input$fileimport)) {
        updateCheckboxInput(session, 'exdata', value=FALSE)
      }
    })

    # Show loading overlay when file upload starts or column mapping changes
    observeEvent(input$fileimport, {
      shinyjs::show("loading_overlay")
    })

    observeEvent(list(input$patient, input$movenum, input$location,
                      input$startdate, input$enddate, input$symonsdate,
                      input$symenddate, input$specdate, input$deathdate,
                      input$case_def, input$neg_specdate, input$extra_cat), {
      req(inputdata_raw())
      shinyjs::show("loading_overlay")
    }, ignoreInit = TRUE)

    # load data
    inputdata_raw <- reactive({
      if (input$exdata == TRUE) {
        example_data()
        } else {
          req(input$fileimport)
          read.csv(input$fileimport$datapath,
                   na.strings = c("NA", ""))
      }
    })

    # Hide loading overlay once data processing is complete
    observe({
      req(inputdata_with_flags())
      shinyjs::hide("loading_overlay")
    })

    # Fallback: hide overlay when data is loaded but mandatory columns aren't mapped
    observe({
      req(inputdata_raw())
      cols <- colnames(inputdata_renamed())
      mandatory <- c("patient", "movenum", "location", "startdate", "enddate")
      if (!all(mandatory %in% cols)) {
        shinyjs::hide("loading_overlay")
      }
    })

  ## update column names selectInput
    inputcols <- reactive(colnames(inputdata_raw()))

    observe({
      for (col_item in input_variables) {
        updateInputCols(session, inputcols(), col_item)
      }

      # Default 'location' to 'bed' when data has 'bed' but not 'location'
      cols <- inputcols()
      if ("bed" %in% cols && !"location" %in% cols) {
        shiny::updateSelectizeInput(session, "location",
                                    choices = c("", cols),
                                    selected = "bed")
      }
    })

    observe({
      if (!is.null(input$fileimport)) {
        updateCheckboxInput(session, 'exdata', value=FALSE)
      }
    })

    ## rename data using input
    inputdata_renamed <- reactive({
      req(inputdata_raw())
      inputdata_raw() |>
        dplyr::select(any_of(c("patient" = input$patient,
                        "movenum" = input$movenum,
                        "location" = input$location,
                        "startdate" = input$startdate,
                        "enddate" = input$enddate,
                        "symonsdate" = input$symonsdate,
                        "symenddate" = input$symenddate,
                        "specdate" = input$specdate,
                        "deathdate" = input$deathdate,
                        "case_def" = input$case_def,
                        "neg_specdate" = input$neg_specdate,
                        "extra_cat" = input$extra_cat
        )))})


    ## Clean data
    inputdata <- reactive({
      # Dont make final dataset until all mandatory columns have been provided
      validate(
        need(('patient' %in% colnames(inputdata_renamed())), "Please identify the 'patient' variable"),
        need(('movenum' %in% colnames(inputdata_renamed())), "Please identify the 'movenum' variable"),
        need(('location' %in% colnames(inputdata_renamed())), "Please identify the 'location' variable"),
        need(('startdate' %in% colnames(inputdata_renamed())), "Please identify the 'start date' variable as: 'startdate'"),
        need(('enddate' %in% colnames(inputdata_renamed())), "Please identify the 'end date' variable as: 'enddate'"),
      )
      inputdata_renamed() |>
        # Use non-missing values to fill missing case definitions for each patient
        group_by(patient)  |>
        dplyr::mutate(across(any_of("case_def"), \(x) {
          if (all(is.na(x))) NA_character_ else max(x, na.rm = TRUE)
        })) |>
        ungroup()   |>
        # Replace missing movement end dates with current date
        dplyr::mutate(enddate = tidyr::replace_na(enddate, as.character(Sys.Date()))) |>
        # Replace missing symptom end dates with current date
        mutate(across(any_of("symenddate"),
                      \(x) case_when(!is.na(symonsdate) ~ tidyr::replace_na(x, as.character(Sys.Date())),
                                     T ~ x))) |>
        # Replace missing categorical variables with unknown value
        mutate(across(any_of(c("case_def", "extra_cat")),
                      \(x) tidyr::replace_na(as.character(x), "Unknown")))


    })

    output$importtbl <- DT::renderDataTable(inputdata_raw())

    ##### run some checks on the input data, and notify user of any issues #####
    data_errors <- reactive({
       req(
    'patient' %in% colnames(inputdata_renamed()),
    'movenum' %in% colnames(inputdata_renamed()),
    'location' %in% colnames(inputdata_renamed()),
    'startdate' %in% colnames(inputdata_renamed()),
    'enddate' %in% colnames(inputdata_renamed())
  )
      req(inputdata())

      inputted_data <- inputdata()

      issues <- list()
     # removal_index <- c()
      error_flags <- data.frame(row_num = 1:nrow(inputted_data),
                                has_error = FALSE,
                                error_type = NA_character_,
                                error_details = NA_character_,
                                stringsAsFactors = FALSE)

      ## check required fields exist for performing the checks
      required_cols <- c("startdate", "enddate", "patient", "movenum", "location")
      missing <- setdiff(required_cols, names(inputted_data))

      if (length(missing) > 0) {
        issues <- c(issues,
                    list(paste("Missing columns:", paste(missing, collapse = ", "))))
      }

      ## start by converting dates
      ## detect invalid date formats BEFORE conversion
      date_vars <- names(inputted_data)[grepl("date", names(inputted_data))]

      bad_date_entries <- purrr::map_df(
        date_vars,
        ~ detect_bad_dates(inputted_data[[.x]]) %>%
          mutate(variable = .x, row = row_number()) %>%
          filter(bad)
      )

      if (nrow(bad_date_entries) > 0) {
        bad_msgs <- bad_date_entries %>%
          mutate(msg = paste0(
            "Invalid date format in '", variable,
            "' on row ", row,
            ": '", original, "'"
          )) %>%
          pull(msg)

        issues <- c(issues, bad_msgs)

        # Flag these rows
        for (i in 1:nrow(bad_date_entries)) {
          row_idx <- bad_date_entries$row[i]
          error_flags$has_error[row_idx] <- TRUE
          error_flags$error_type[row_idx] <- paste0(
            ifelse(is.na(error_flags$error_type[row_idx]), "", paste0(error_flags$error_type[row_idx], "; ")),
            "Invalid date format"
          )
          error_flags$error_details[row_idx] <- paste0(
            ifelse(is.na(error_flags$error_details[row_idx]), "", paste0(error_flags$error_details[row_idx], "; ")),
            "Invalid format in '", bad_date_entries$variable[i], "'"
          )
        }
      }

      ## format dates (taken from earlier in the script and moved to after check) - without warnings

      oldw <- getOption("warn")
      options(warn = -1)

      inputted_data <- inputted_data %>%
                      mutate(across(contains("date"),
               \(x) {
                 if (inherits(x, c("POSIXct", "POSIXlt", "Date"))) {
                   x  # already parsed - preserve type
                 } else {
                   parse_date_time(
                     x,
                     c("dmy", "ymd", "mdy", "dmy HMS", "ymd HMS", "mdy HMS")
                   )  # returns POSIXct; preserves time if present
                 }
               }))

      options(warn = oldw)


      ## check for any missing values within 4 key variables
      key_vars <- c("patient", "movenum", "location", "startdate")

      missing_vals <- inputted_data %>%
        mutate(.row = row_number()) %>%
        # Convert all key variables to character to avoid type-mismatch errors
        mutate(across(all_of(key_vars), as.character)) %>%
        select(all_of(key_vars), .row) %>%
        tidyr::pivot_longer(cols = all_of(key_vars),
               names_to = "variable",
               values_to = "value") %>%
               filter(is.na(value) | value == "")

      if (nrow(missing_vals) > 0) {

        ## add messages for each missing entry
        missing_messages <- missing_vals %>%
          mutate(msg = paste0("Missing value in '", variable, "' variable, on row ", .row, ".")) %>%
          pull(msg)

        issues <- c(issues,
                    paste0(missing_messages))

        # Flag these rows
        for (i in 1:nrow(missing_vals)) {
          row_idx <- missing_vals$.row[i]
          error_flags$has_error[row_idx] <- TRUE
          error_flags$error_type[row_idx] <- paste0(
            ifelse(is.na(error_flags$error_type[row_idx]), "", paste0(error_flags$error_type[row_idx], "; ")),
            "Missing required value"
          )
          error_flags$error_details[row_idx] <- paste0(
            ifelse(is.na(error_flags$error_details[row_idx]), "", paste0(error_flags$error_details[row_idx], "; ")),
            "Missing '", missing_vals$variable[i], "'"
          )
        }
      }

      ## check end date(s) earlier than start date
      bad_dates <- inputted_data %>%
                      mutate(.row = row_number(),
                             .caseID = patient,
                             .moveID = movenum) %>%
                        filter(as.POSIXct(enddate) < as.POSIXct(startdate))

      if (nrow(bad_dates) > 0) {
        issues <- c(issues,
                    (paste("There are case ID(s) and movement ID(s) within the input dataset where end date occurs before start date:",
                          paste(unique(bad_dates[c("patient", "movenum")]), collapse = ", "))))

        # Flag these rows
        for (i in 1:nrow(bad_dates)) {
          row_idx <- bad_dates$.row[i]
          error_flags$has_error[row_idx] <- TRUE
          error_flags$error_type[row_idx] <- paste0(
            ifelse(is.na(error_flags$error_type[row_idx]), "", paste0(error_flags$error_type[row_idx], "; ")),
            "Date logic error"
          )
          error_flags$error_details[row_idx] <- paste0(
            ifelse(is.na(error_flags$error_details[row_idx]), "", paste0(error_flags$error_details[row_idx], "; ")),
            "End date before start date"
          )
        }
      }

      if("symonsdate" %in% names(inputted_data) & "symenddate" %in% names(inputted_data)) {
      ## check symptom onset and symptom end dates
      bad_symp <- inputted_data %>%
                    mutate(.row = row_number(),
                           .caseID = patient,
                           .moveID = movenum) %>%
                      filter(as.POSIXct(symenddate) < as.POSIXct(symonsdate))

      if (nrow(bad_symp) > 0) {
        issues <- c(issues,
                    paste("There are case ID(s) and movement ID(s) within the input dataset where symptom end date occurs before symptom onset:",
                          paste(unique(bad_symp[c("patient", "movenum")]), collapse = ", ")))

        # Flag these rows
        for (i in 1:nrow(bad_symp)) {
          row_idx <- bad_symp$.row[i]
          error_flags$has_error[row_idx] <- TRUE
          error_flags$error_type[row_idx] <- paste0(
            ifelse(is.na(error_flags$error_type[row_idx]), "", paste0(error_flags$error_type[row_idx], "; ")),
            "Date logic error"
          )
          error_flags$error_details[row_idx] <- paste0(
            ifelse(is.na(error_flags$error_details[row_idx]), "", paste0(error_flags$error_details[row_idx], "; ")),
            "Symptom end before symptom onset"
          )
        }
      }
  }
      ## notify users about the errors
      if (sum(error_flags$has_error) > 0) {

        issues <- c(issues,
                    paste0("<strong>", sum(error_flags$has_error),
                           " row(s) contain errors and will be excluded from the timeline. ",
                           "The original data values are preserved in the table below. ",
                           "Please rectify these issues in your source data if you want to include these rows.</strong>"))

      }

      ## notify if there's no errors detected
      if (length(issues) == 0) {

        issues <- "No issues detected with the input data"

        }

      return(list(
        issues = issues,
        error_flags = error_flags))

    })

        ## render to include in the UI
    output$data_errors <- renderUI({
      req(data_errors())

      errs <- data_errors()$issues
      ambig <- ambiguous_dates()

      tagList(
        # red errors
        if (length(errs) == 1 && errs == "No issues detected with the input data") {
          div(style = "color: green; font-weight: bold;", errs)
        } else {
          tagList(lapply(errs, function(msg) {
            div(style = "color: darkred; margin-bottom: 6px;",
                HTML(paste0(msg, "<br>")))
          }))
        },
      )
    })

    ## Create a reactive that returns the data with error flags
    inputdata_with_flags <- reactive({
      req(inputdata(), data_errors())

      oldw <- getOption("warn")
      options(warn = -1)

      df <- inputdata() |>
        ## Format dates without warning
        mutate(across(contains("date"),
                      \(x) as.POSIXct(parse_date_time(x, c("dmy", "ymd", "mdy","dmy HMS", "ymd HMS", "mdy HMS")))))

      options(warn = oldw)

      flags <- data_errors()$error_flags

      # Add error flag columns to the data
      df$has_error <- flags$has_error
      df$error_type <- flags$error_type
      df$error_details <- flags$error_details

      df
    })

    # Detect ambiguous dates that could be parsed as either DMY or MDY (e.g. 01/02/2020 could be Jan 2 or Feb 1)

    ambiguous_dates <- reactive({
  req(
    'patient' %in% colnames(inputdata_renamed()),
    'location' %in% colnames(inputdata_renamed())
  )
  # ... rest unchanged, but replace req(inputdata()) with inputdata() directly

  date_vars <- names(inputdata()) |> purrr::keep(~ grepl("date", .x))

  purrr::map_df(date_vars, function(col) {
    vals <- as.character(inputdata()[[col]])
    purrr::imap_dfr(vals, function(val, i) {
      if (is.na(val) || val == "") return(NULL)
      d_dmy <- suppressWarnings(as.Date(parse_date_time(val, "dmy")))
      d_mdy <- suppressWarnings(as.Date(parse_date_time(val, "mdy")))
      if (!is.na(d_dmy) && !is.na(d_mdy) && d_dmy != d_mdy) {
        data.frame(row = i, variable = col, value = val, stringsAsFactors = FALSE)
      } else NULL
    })
  })
})

    # render ribbons for data errors or date ambiguity

    output$ribbon_red <- renderUI({
  req(data_errors())
  n_red <- sum(data_errors()$error_flags$has_error)
  if (n_red > 0) {
    div(class = "ticlr-ribbon ticlr-ribbon-red visible",
        icon("circle-xmark"),
        sprintf("  %d red warning(s) - rows with errors will be excluded from the timeline.", n_red))
  }
})

output$ribbon_amber <- renderUI({
  req(ambiguous_dates())
  n_amber <- nrow(ambiguous_dates())
  if (n_amber > 0) {
    div(class = "ticlr-ribbon ticlr-ribbon-amber visible",
        icon("triangle-exclamation"),
        sprintf("Warning,  %d ambiguous dates detected. TICLR will assume DD/MM/YYYY format for ambiguous dates.", n_amber),
        tags$br(),
        "Please make sure your dates are showing as intended in the table below.")
  }
})



    output$importtbl_final <- DT::renderDT({

      req(inputdata_with_flags())

      df <- inputdata_with_flags()

      # Compute indices for columns to hide
      hide_cols_idx <- which(names(df) %in% c("has_error", "error_type", "error_details"))

      # Compute indices for column showing T/F error
      has_error_idx <- which(names(df) == "has_error")

      DT::datatable(df,
                    class = 'display nowrap',
                    options = list(
                      pageLength = 10,
                      scrollX = TRUE,
                      columnDefs = list(
                        list(visible = FALSE, targets = hide_cols_idx)
                      ),
                      rowCallback = DT::JS(sprintf(
                        "function(row, data, index) {
                            var v = data[%d];
                            if (v === true) {
                              $(row).addClass('error-row');
                            }
                          }",
                        has_error_idx))
                    )
      )

    })

    # Return the data with error flags
    return(inputdata_with_flags)

  }) # closes moduleServer
} # closes mod_input_data_server
