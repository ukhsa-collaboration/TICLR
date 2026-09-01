#' mod_timeline UI Function
#' 
#' @description A Shiny module.
#' 
#' @param id A shiny session id
#' @export

mod_timeline <- function(id) {

  ns <- NS(id)

  tagList(

    useKeys(),
    keysInput(ns("hotkey_pressed"), c("f", "F"), global=TRUE),

    actionButton(
      ns("help_btn"),
      label = tagList(icon("info-circle"), "Click here for help"),
      style = "padding: 4px 8px; font-size: 12px;"
    ),
    p(),

    tags$script(HTML("
      Shiny.addCustomMessageHandler('download-svg', function(x) {
        const gd = document.getElementById(x.id);
        if (!gd) return;
        Plotly.downloadImage(gd, {
          format: 'svg',
          filename: x.filename || 'timeline'
        });
      });
    ")),

    tags$script(HTML(paste0("
      document.addEventListener('keydown', function(e) { 
        if( (e.key === 'h' || e.key === 'H') && !e.repeat){
          const el = document.getElementById('", ns("hover_info_file"), "');
          if(el){
            el.click();
          }
        }
      });
    "))),
    
    #useKeys(), # Starts the key listener
    #keysInput(ns("hotkey_pressed"), c("s"), global=TRUE),
    
    mainPanel(

      h3("Timeline"),
      shinycssloaders::withSpinner(plotly::plotlyOutput(ns("timeline"), width="100%", height="100%")),
      br(),

      # Tabs for customisation
      tabsetPanel(
        id =  ns("timeline_cust_tabs"),
        tabPanel(
          "Size",
          fluidRow(
            column(
              3,
              div(
                sliderInput(ns("barhgt"), "Location bar thickness", min=0, max=50, value=7, step=1, round=0, ticks=FALSE),
                sliderInput(ns("symhgt"), "Symptomatic period bar thickness", min=0, max=50, value=5, step=1, round=0, ticks=FALSE),
                sliderInput(ns("barspc"), "Location bar spacing", min=0, max=0.5, value=0.2, step=0.01, round=0, ticks=FALSE)
              )
            ),
            column(
              3,
              div(
                sliderInput(ns("xfs"), "Text size for dates", min=0, max=50, value=11, step=1, round=0, ticks=FALSE),
                sliderInput(ns("yfs"), "Text size for patient labels", min=0, max=50, value=14, step=1, round=0, ticks=FALSE),
                sliderInput(ns("legfs"), "Text size for legend", min=0, max=50, value=11, step=1, round=0, ticks=FALSE),
                uiOutput(ns("poisiz_ui"))
              )
            ),
            column(
              3,
              div(
                uiOutput(ns("case_def_ui")),
                uiOutput(ns("cdfs_ui")),
                sliderInput(ns("plotht"), "Plot height (px)", min=100, max=2000, value=500, step=100, round=0, ticks=FALSE),
                sliderInput(ns("plotwd"), "Plot width (px)", min=100, max=2000, value=1000, step=100, round=0, ticks=FALSE),
                style = "height: 30px; padding: 1px; margin-top: 15px;"
              )
            ),
            column(
              3,
              radioButtons(ns("leg_pos"), "Legend position", choices = c("Top" = "Top", "Side" = "Side"), selected = "Top")
            )
          )
        ),
        tabPanel(
          "Colour",
          fluidRow(
            column(3,
              uiOutput(ns("specol_ui")),
              uiOutput(ns("negcol_ui")),
              uiOutput(ns("symcol_ui")),
              uiOutput(ns("deacol_ui")),
                    colourpicker::colourInput(ns('majgricol'), "Major gridlines", "gray60", showColour = 'background', palette='limited', allowedCols=c("gray0", "gray20", "gray40", "gray60", "gray80", "gray100"), allowTransparent = T),
                    colourpicker::colourInput(ns('mingricol'), "Minor gridlines", "gray80", showColour = 'background', palette='limited', allowedCols=c("gray0", "gray20", "gray40", "gray60", "gray80", "gray100"), allowTransparent = T)
              ),
              column(3,
                    #radioButtons(ns("colsch"), "Colour scheme", choices = c("Accent" = "Accent", "Dark2" = "Dark2", "Paired" = "Paired", "Pastel1" = "Pastel1", "Pastel2" = "Pastel2", "Set1" = "Set1", "Set2" = "Set2", "Set3" = "Set3"), selected = "Set3"),
                    uiOutput(ns("colsch_ui")),
                    checkboxInput(ns("colsch_interp"), "Allow colour scheme interpolation?", value = FALSE),
                    actionButton(ns("ShuffleCols"), "Shuffle location colours", style = "margin-top: 25px;")
              ),
              column(3,
                "Manually override scheme:",
                uiOutput(ns("location_sel_ui")),
                uiOutput(ns("location_col_ui")),
                actionButton(ns("location_col_reset"), "Reset location colours", style = "margin-top: 25px;")
              )
            )
          ),
          tabPanel(
            "Filter",
            fluidRow(
              column(
                3,
                uiOutput(ns("selectSort")),
                dateRangeInput(ns("daterange"), "Filter to date range: ", start = Sys.Date() - 365, end = Sys.Date(),  separator = " - "),
                uiOutput(ns("selectLocation")),
                uiOutput(ns("selectCaseDef")),
                uiOutput(ns("selectExtraCat"))      
              ),
              column(
                3,
                shinyWidgets::sliderTextInput(
                  ns("suppress"),
                  "Suppress periods with no admissions over",
                  choices = c(
                    "1 month",
                    glue::glue("{2:6} months"),
                    "1 year",
                    glue::glue("{2:5} years"),
                    "Never"
                  ),
                  selected= "6 months"
                )
              ),
              column(
                2,
                radioButtons(ns("majbre"), "Major break", choices = c("Day" = "1 day", "Week" = "1 week", "Month" = "1 month", "Year" = "1 year"), selected = "1 week"),
                radioButtons(ns("minbre"), "Minor break", choices = c("Day" = "1 day", "Week" = "1 week", "Month" = "1 month", "Year" = "1 year"), selected = "1 day"),
                radioButtons(ns("xlabrot"), "Date labels", choices = c("Horizontal" = "horizontal", "Vertical" = "vertical", "Slanted" =  "slanted"), selected = "vertical")
              )
            )
          ),
          tabPanel(
            "Hover",
            fluidRow(
              column(
                3,
                checkboxInput(ns("hover_highlight"), "Enable highlighting (F/f)", value = FALSE)
              ),
              column(
                3,
                numericInput(ns("hover_window_pre"), "Extend overlap window before (hours)", value = 0, min = 0, step = 1)
              ),
              column(
                3,
                numericInput(ns("hover_window_post"), "Extend overlap window after (hours)", value = 0, min = 0, step = 1)
              )
            ),
            fluidRow(
              column(12,
              div(
                  tableOutput(ns("hover_info")),
                  style = "border: 1px solid #ccc; padding: 10px; margin-top: 10px;"
                )
              )
            ),
            fluidRow(
              column(3,
                downloadButton(ns("hover_info_file"), "Download (H/h)", style = "margin-top: 10px;")
              )
            )
          ),
          tabPanel(
            "Download",
            fluidRow(
              column(3,
                actionButton(ns("download_svg_btn"), "Download as .svg", style = "margin-top: 25px;"),
                downloadButton(ns("download_rds"), "Download as .rds", style = "margin-top: 25px;")
              )
            )
          ),
          tabPanel(
            "Reset",
            fluidRow(
              column(
                3,
                div(
                  actionButton(ns("resetAll"), "Reset all settings"),
                  p(),
                  actionButton(ns("resetDate"), "Reset date range")
                )
              )
            )
          )
      )
    )
  )
}


#' Collect the current timeline UI settings
#'
#' Reads the current values of the timeline module's customisation inputs
#' from \code{input} and returns them as a plain list, suitable for
#' serialising to JSON and persisting via \code{dust_save_bookmark()}.
#'
#' @param input Shiny input object for the timeline module.
#'
#' @return A named list of the current timeline settings. Any input that has
#'   not yet been set (e.g. UI not rendered) is omitted.
#' @keywords internal
timeline_collect_bookmark_settings <- function(input) {

  setting_ids <- c(
    "barhgt", "symhgt", "barspc", "poisiz", "xfs", "yfs", "legfs",
    "plotht", "plotwd", "case_def", "cdfs", "leg_pos",
    "colsch", "symcol", "specol", "negcol", "deacol",
    "mingricol", "majgricol", "majbre", "minbre", "xlabrot", "suppress",
    "hover_window_pre", "hover_window_post", "hover_highlight", "sorttype"
  )

  settings <- list()
  for (setting_id in setting_ids) {
    value <- input[[setting_id]]
    if (!is.null(value)) {
      settings[[setting_id]] <- value
    }
  }

  settings
}


#' Apply a set of timeline UI settings
#'
#' Updates the timeline module's inputs to match the values in
#' \code{settings}, as previously produced by
#' \code{timeline_collect_bookmark_settings()} (typically after being
#' retrieved from the database via \code{dust_find_bookmarks()}). Inputs
#' that are absent from \code{settings} are left unchanged.
#'
#' @param session Shiny session object for the timeline module.
#' @param settings A named list of settings, as returned by
#'   \code{timeline_collect_bookmark_settings()}.
#'
#' @keywords internal
timeline_apply_bookmark_settings <- function(session, settings) {

  if (is.null(settings) || length(settings) == 0) {
    return(invisible(NULL))
  }

  update_if_present <- function(name, fn) {
    if (!is.null(settings[[name]])) {
      fn(settings[[name]])
    }
  }

  update_if_present("barhgt", \(v) updateSliderInput(session, "barhgt", value = v))
  update_if_present("symhgt", \(v) updateSliderInput(session, "symhgt", value = v))
  update_if_present("barspc", \(v) updateSliderInput(session, "barspc", value = v))
  update_if_present("poisiz", \(v) updateSliderInput(session, "poisiz", value = v))
  update_if_present("xfs", \(v) updateSliderInput(session, "xfs", value = v))
  update_if_present("yfs", \(v) updateSliderInput(session, "yfs", value = v))
  update_if_present("legfs", \(v) updateSliderInput(session, "legfs", value = v))
  update_if_present("plotht", \(v) updateSliderInput(session, "plotht", value = v))
  update_if_present("plotwd", \(v) updateSliderInput(session, "plotwd", value = v))
  update_if_present("case_def", \(v) updateCheckboxInput(session, "case_def", value = v))
  update_if_present("cdfs", \(v) updateSliderInput(session, "cdfs", value = v))
  update_if_present("leg_pos", \(v) updateRadioButtons(session, "leg_pos", selected = v))

  update_if_present("colsch", \(v) updateRadioButtons(session, "colsch", selected = v))
  update_if_present("symcol", \(v) updateColourInput(session, "symcol", value = v))
  update_if_present("specol", \(v) updateColourInput(session, "specol", value = v))
  update_if_present("negcol", \(v) updateColourInput(session, "negcol", value = v))
  update_if_present("deacol", \(v) updateColourInput(session, "deacol", value = v))
  update_if_present("mingricol", \(v) updateColourInput(session, "mingricol", value = v))
  update_if_present("majgricol", \(v) updateColourInput(session, "majgricol", value = v))

  update_if_present("majbre", \(v) updateRadioButtons(session, "majbre", selected = v))
  update_if_present("minbre", \(v) updateRadioButtons(session, "minbre", selected = v))
  update_if_present("xlabrot", \(v) updateRadioButtons(session, "xlabrot", selected = v))
  update_if_present("suppress", \(v) updateSliderTextInput(session, "suppress", selected = v))

  update_if_present("hover_window_pre", \(v) updateNumericInput(session, "hover_window_pre", value = v))
  update_if_present("hover_window_post", \(v) updateNumericInput(session, "hover_window_post", value = v))
  update_if_present("hover_highlight", \(v) updateCheckboxInput(session, "hover_highlight", value = v))
  update_if_present("sorttype", \(v) updateRadioButtons(session, "sorttype", selected = v))

  invisible(NULL)
}


#' Save the current timeline UI state as a DUST bookmark
#'
#' Collects the timeline module's current settings via
#' \code{timeline_collect_bookmark_settings()} and persists them using
#' \code{dust_save_bookmark()}.
#'
#' @param postgres_con A DBI connection object to the DUST PostgreSQL database.
#' @param app_name Character. Application name.
#' @param uname Character. Current username.
#' @param name Character. Preset name/identifier (\code{s_key}) to save under.
#' @param input Shiny input object for the timeline module.
#'
#' @return \code{TRUE} (invisibly) if the save succeeded, \code{FALSE}
#'   otherwise. See \code{dust_save_bookmark()} for details.
#' @keywords internal
timeline_save_ui_bookmark <- function(postgres_con, app_name, uname, name, input) {

  if (!isS4(postgres_con)) {
    return(invisible(FALSE))
  }

  settings <- timeline_collect_bookmark_settings(input)

  dust_save_bookmark(
    postgres_con = postgres_con,
    app_name     = app_name,
    uname        = uname,
    name         = name,
    options      = settings
  )
}


#' Load a saved timeline UI state from a DUST bookmark
#'
#' Retrieves the user's saved bookmarks via \code{dust_find_bookmarks()},
#' locates the one matching \code{name}, and applies its settings to the
#' timeline module's inputs via \code{timeline_apply_bookmark_settings()}.
#'
#' @param postgres_con A DBI connection object to the DUST PostgreSQL database.
#' @param app_name Character. Application name.
#' @param uname Character. Current username.
#' @param name Character. Preset name/identifier (\code{s_key}) to load.
#' @param session Shiny session object for the timeline module.
#'
#' @return \code{TRUE} (invisibly) if a matching bookmark was found and
#'   applied, \code{FALSE} (invisibly) otherwise.
#' @keywords internal
timeline_load_ui_bookmark <- function(postgres_con, app_name, uname, name, session) {

  if (!isS4(postgres_con)) {
    return(invisible(FALSE))
  }

  bookmarks <- dust_find_bookmarks(postgres_con, app_name, uname)

  if (nrow(bookmarks) == 0 || !("s_key" %in% names(bookmarks))) {
    message(paste0("No bookmarks found for user '", uname, "' when loading '", name, "'."))
    return(invisible(FALSE))
  }

  match_row <- bookmarks[bookmarks$s_key == name, ]

  if (nrow(match_row) == 0) {
    message(paste0("Bookmark '", name, "' not found for user '", uname, "'."))
    return(invisible(FALSE))
  }

  settings <- match_row$set[[1]]
  timeline_apply_bookmark_settings(session, settings)

  invisible(TRUE)
}


#' mod_timeline_server Function
#' 
#' @param id A shiny session id
#' @param inputdata A reactive expression containing the input data
#' 
#' @param postgres_con A DBI connection object to the DUST PostgreSQL database.
#' @param existing_bookmarks A tibble of existing bookmarks, as returned by
#'   \code{dust_find_bookmarks()}.
#' @param app_name Character. Application name.
#' @param uname Character. Current username.
#'
#' @export
mod_timeline_server <- function(id, inputdata, postgres_con, existing_bookmarks, app_name, uname) {
    moduleServer(id, function(input, output, session) {

    # Apply any existing saved bookmark on startup, once the UI has been
    # fully rendered (so that updateXInput calls have controls to target).
    if (nrow(existing_bookmarks) > 0) {
      session$onFlushed(function() {
        timeline_apply_bookmark_settings(session, existing_bookmarks$set[[1]])
      }, once = TRUE)
    }

    # `colsch` is rendered via colsch_ui (a renderUI/uiOutput), so it doesn't
    # exist yet when the updateRadioButtons() above fires and is silently
    # ignored. Stash the saved value here so colsch_ui can apply it itself
    # the first time it renders.
    saved_colsch <- reactiveVal(
      if (nrow(existing_bookmarks) > 0) existing_bookmarks$set[[1]]$colsch else NULL
    )

    reset_trigger <- reactiveVal(0)
    data_mindate <- reactiveVal(NULL)
    data_maxdate <- reactiveVal(NULL)
    col_pal <- reactiveVal(NULL)
    figure <- reactiveVal(NULL)

    # Default customisation
    defaults <- list(
      barhgt = 7,
      symhgt = 5,
      barspc = 0.2,
      poisiz = 5,
      xfs =  11,
      yfs = 14,
      legfs = 12,
      plotht = 500,
      plotwd = 1000,
      specdate = 5,
      deathdate = 5,
      neg_specdate = 5,
      case_def = FALSE,
      cdfs = 12,
      colsch = "Tableau 20",
      colsch_interp = FALSE,
      majbre = "1 week",
      minbre = "1 day",
      xlabrot = "vertical",
      suppress = "6 months",
      hover_window_pre = 0,
      hover_window_post = 0,
      hover_highlight = FALSE,
      leg_pos = 'Top'
    )
    
        ### RESET THE TIMELINE
    observeEvent(input$resetAll, {

      reset_trigger(reset_trigger() + 1)

      # size
      updateSliderInput(session, "barhgt", value = defaults$barhgt)
      updateSliderInput(session, "symhgt", value = defaults$symhgt)
      updateSliderInput(session, "barspc", value = defaults$barspc)
      updateSliderInput(session, "poisiz", value = defaults$poisiz)
      updateSliderInput(session, "xfs", value = defaults$xfs)
      updateSliderInput(session, "yfs", value = defaults$yfs)
      updateSliderInput(session, "legfs", value = defaults$legfs)
      updateSliderInput(session, "plotht", value = defaults$plotht)
      updateSliderInput(session, "plotwd", value = defaults$plotwd)
      #updateSliderInput(session, "specdate", value = defaults$specdate)
      #updateSliderInput(session, "deathdate", value = defaults$deathdate)
      #updateSliderInput(session, "neg_specdate", value = defaults$neg_specdate)
      updateCheckboxInput(session, "case_def", value = defaults$case_def)
      updateSliderInput(session, "cdfs", value = defaults$cdfs)
      updateRadioButtons(session, "leg_pos", selected = defaults$leg_pos)

      # colour
      updateRadioButtons(session, "colsch", selected = defaults$colsch)
      updateCheckboxInput(session, "colsch_interp", value = defaults$colsch_interp)
      updateColourInput(session, "symcol", value = "#B3B3B3")
      updateColourInput(session, "specol", value = "#FF0000")
      updateColourInput(session, "negcol", value = "#00FF00")
      updateColourInput(session, "deacol", value = "#000000")
      updateColourInput(session, "mingricol", value = "#CCCCCC")
      updateColourInput(session, "majgricol", value = "#999999")

      # filters
      updateRadioButtons(session, "majbre", selected = defaults$majbre)
      updateRadioButtons(session, "minbre", selected = defaults$minbre)
      updateRadioButtons(session, "xlabrot", selected = defaults$xlabrot)
      updateSliderTextInput(session, "suppress", selected = defaults$suppress)
      updateSelectInput(session, "filterLocation", selected = character(0))
      updateSelectInput(session, "filterCaseDef", selected = character(0))
      updateSelectInput(session, "filterExtraCat", selected = character(0))
      updateDateRangeInput(session, "daterange",
                           start = as.Date(data_mindate()),
                           end   = as.Date(data_maxdate()))

      # hover
      updateNumericInput(session, "hover_window_pre", value = defaults$hover_window_pre)
      updateNumericInput(session, "hover_window_post", value = defaults$hover_window_post)
      updateCheckboxInput(session, "hover_highlight", value = defaults$hover_highlight)

    })

    ### RESET DATE RANGE ONLY
    observeEvent(input$resetDate, {

      updateSliderTextInput(session, "suppress", selected = defaults$suppress)
      updateDateRangeInput(session, "daterange",
                           start = as.Date(data_mindate()),
                           end   = as.Date(data_maxdate()))
    })

    # Help
    observeEvent(input$help_btn, {
      showModal(modalDialog(
        title = "Help",
        tagList(
          h6(tags$b("Colours")),
          p("Shiny colour palettes only provide a limited number of distinct colours (between 8 and 20). By default you will be automatically prevented from selecting a colour scheme with fewer colours than the number of locations in your data. However, if you choose to allow colour scheme interpolation, you can select a colour scheme with fewer colours than the number of locations in your data and the app will interpolate between the colours in the palette to generate additional distinct colours. Note that while this can allow you to generate a larger number of distinct colours, it can also lead to colours that are very similar to each other, which may make the plot harder to read."),       
          h6(tags$b("Highlighting")),
          p("The new hover tab controls highlighting behaviour. When active, moving your mouse over a movement will highlight it and any other patient traces within that location during that window. By default, the temporal window is confined to the exact start and end of the highlighted location movement but you can choose to expand the overlap window to highlight movements for that location X hours before, or after, the highlighted trace."),
          h6(tags$b("Keyboard Shortcuts")),
          p("Pressing the 'F' key will toggle the hover behaviour on/off \"Freezing\" the current table contents. Pressing the 'H' key will download the contents of hover information table as a .csv file.")
        ),
        easyClose = TRUE,
        footer = modalButton("Close"),
        size = "l"
      ))
    })

    ns <- session$ns
    stopifnot(is.reactive(inputdata))

        # Filtering ----------------------------------

    ### Dates
    # Calculate minimum date across all relevant date columns
    # so we can see the full date range even if some rows have errors
    mindate <- reactive({
      
      req(inputdata())
      df <- inputdata()
      dcols <- c("startdate", "symonsdate", "specdate", "neg_specdate", "deathdate")
      mdate <- NULL
      for(c in dcols){
        if(c %in% names(df)){
          m = min(df[[c]], na.rm = TRUE)
          # if m is not na and is less than mdate, update mdate
          if(!is.na(m) && (is.null(mdate) || m < mdate)){
            mdate <- m
          }
        }
      }
      as.Date(mdate, origin = "1970-01-01")
    })

    # Calculate maximum date across all relevant date columns
    maxdate <- reactive({
      req(inputdata())
      df <- inputdata()
      dcols <- c("enddate", "symenddate", "specdate", "neg_specdate", "deathdate")
      mdate <- NULL
      for(c in dcols){
        if(c %in% names(df)){
          m = max(df[[c]], na.rm = TRUE)
          # if m is not na and is greater than mdate, update mdate
          if(!is.na(m) && (is.null(mdate) || m > mdate)){
            mdate <- m
          }
        }
      }
      as.Date(mdate, origin = "1970-01-01")
    })

    # Update date range when data first loads (not reactively to avoid circular dependency)
    observeEvent(inputdata(), {
      req(inputdata())

      isolate({
        mn <- mindate()
        mx <- maxdate()
        data_mindate(mn)
        data_maxdate(mx)
        updateDateRangeInput(session, "daterange",
                             start = mn,
                             end   = mx)
      })
    }, ignoreNULL = TRUE)



    # first level of cleaning/preparation. 
    # Removes any known-faulty rows based on the error flag column (if existing)
    # Converts all date columns to POSIXct format if they are not already (to avoid issues with date handling later on)
    # Creates the trace and event dataframes that will be used for plotting the timeline. This is done prior to any filtering so that we have a complete set of traces and events to work with when building the plotly traces and applying filters.
    # 
    # This is only expected to re-run if the raw input data changes OR the user chooses to un-merge layers.
    inputdata_prep <- reactive({
      req(inputdata())

      df <- inputdata()
      # Check if error flag columns exist
      if ("has_error" %in% names(df)) {
        # Filter out rows with errors
        df <- df |>
          filter(!has_error) |>
          # Remove the error flag columns from the clean data
          select(-starts_with("has_error"), -starts_with("error_type"), -starts_with("error_details"))
      }

      # convert patient to character to avoid issues with plotly
      df$patient <- as.character(df$patient)

      # coerce location to character to avoid issues with plotly
      if("location" %in% names(df)){
        df$location <- as.character(df$location)
      }

      # for all possible date columns, if they exist and are not already in POSIXct format, convert them to POSIXct.
      for(date_field in c("startdate", "enddate", "symonsdate", "symenddate", "specdate", "neg_specdate", "deathdate")) {
        if (date_field %in% names(df)) {
          if (!inherits(df[[date_field]], "POSIXct")) {
            df[[date_field]] <- as.POSIXct(df[[date_field]], origin = "1970-01-01", tz = "UTC")
          }
        }
      }

      # look at the startdate and enddate columns, check whether all non-na values have midnight as a time
      # set the variable no_time equal to TRUE if so and FALSE if not.
      no_time <- all(format(df$startdate, "%H:%M:%S") == "00:00:00", na.rm = TRUE)

      # spot of semi-manual data handling for the initial layer setup
      # give it the minimal set of columns
      trace_data <- data.frame(
        patient = character(),
        startdate = as.POSIXct(character()),
        enddate = as.POSIXct(character()),
        location = character(),
        uname = character(),
        layer = numeric(),
        kind = character(),
        text = character(),
        single_day = logical(),
        extra_cat = character()
      )

      if("symonsdate" %in% names(df) && "symenddate" %in% names(df)){
        
        trace <- df |>
          select(patient, symonsdate, symenddate, movenum) |>
          rename(startdate = symonsdate, enddate = symenddate) 
        
        trace <- trace |>
          filter(!is.na(startdate) & !is.na(enddate))

        trace$location = "Symptomatic"
        trace$uname <- "Symptomatic"
        trace$layer = -1
        trace$kind = "symptomatic"

        if(no_time){
          trace$text = paste0(
            "Patient: ", trace$patient,
            "<br>Symptomatic period:",
            "<br>Start: ", format(trace$startdate, "%Y-%m-%d"),
            "<br>End: ", format(trace$enddate, "%Y-%m-%d")
          )
        } else {
          trace$text = paste0(
            "Patient: ", trace$patient,
            "<br>Symptomatic period:",
            "<br>Start: ", format(trace$startdate, "%Y-%m-%d %H:%M:%S"),
            "<br>End: ", format(trace$enddate, "%Y-%m-%d %H:%M:%S")
          )
        }

        # if it exists, na pad it in symptomatic traces
        if("extra_cat" %in% names(df)){
          trace$extra_cat <- NA_character_
        }

        trace <- trace |> mutate(single_day = if_else(startdate == enddate, TRUE, FALSE))
        trace_data <- rbind(trace_data, trace)
      }

      if("location" %in% names(df)){

        trace <- df |>
          select(patient, location, startdate, enddate, movenum, any_of("extra_cat"))

        if(!"extra_cat" %in% names(trace)){
          trace$extra_cat <- NA_character_
        }
        
        trace <- trace |>
          mutate(single_day = if_else(startdate == enddate, TRUE, FALSE),
                  extra_cat = if_else(is.na(extra_cat), NA_character_, as.character(extra_cat)))
        
        trace$layer = 0
        trace$kind = "location"
        if(no_time){
          trace$text = paste0(
            "Patient: ", trace$patient,
            "<br>Location: ", trace$location,
            "<br>Start: ", format(trace$startdate, "%Y-%m-%d"),
            "<br>End: ", format(trace$enddate, "%Y-%m-%d"),
            "<br>Single day: ", trace$single_day
          )
        } else {
          trace$text = paste0(
            "Patient: ", trace$patient,
            "<br>Location: ", trace$location,
            "<br>Start: ", format(trace$startdate, "%Y-%m-%d %H:%M:%S"),
            "<br>End: ", format(trace$enddate, "%Y-%m-%d %H:%M:%S"),
            "<br>Single day: ", trace$single_day
          )
        }
        trace$uname <- trace$location
        trace_data <- rbind(trace_data, trace)
      }

      # finally, if there are any single-day movements (where startdate = enddate), expand them to be 12 hours before and after the date to make them visible on the plot. We do this at the end so that we retain the original start and end dates for filtering and event matching purposes.
      trace_data <- trace_data |>
        mutate(
          startdate = if_else(single_day, startdate - hours(12), startdate),
          enddate = if_else(single_day, enddate + hours(12), enddate)
        )

      # next event data
      event_data = data.frame(
        patient = character(),
        event_date = as.POSIXct(character()),
        type = character(),
        layer = numeric(),
        kind = character(),
        text = character()
      )

      events = list(
        specdate = "Positive specimen",
        neg_specdate = "Negative specimen",
        deathdate = "Death"
      )
      for(event in names(events)){
        if(event %in% names(df)){
          ev <- df |>
            select(patient, event_date = all_of(event)) |>
            filter(!is.na(event_date))
          ev$type = events[[event]]
          ev$layer = -1
          ev$kind = "event"
          if(no_time){
            ev$text = paste0(
              "Patient: ", ev$patient,
              "<br>Event: ", ev$type,
              "<br>Date: ", format(ev$event_date, "%Y-%m-%d")
            )
          } else {
            ev$text = paste0(
              "Patient: ", ev$patient,
              "<br>Event: ", ev$type,
              "<br>Date: ", format(ev$event_date, "%Y-%m-%d %H:%M:%S")
            )
          }
          event_data <- rbind(event_data, ev)
        }
      }

      case_def_data <- data.frame()
      if("case_def" %in% names(df)){
        case_def_data <- df |> select(patient, case_def) |> filter(!is.na(case_def)) |> distinct()
      }
  
      return(list(trace_data = trace_data, event_data = event_data, case_def_data = case_def_data))
    }) # close inputdata_prep

    # set up sections of the UI that depend on the data.
    observeEvent(inputdata_prep(), {
      req(inputdata_prep())

      traces <- inputdata_prep()$trace_data
      events <- inputdata_prep()$event_data
      casedefs <- inputdata_prep()$case_def_data

      # built list of sort options based on what's in the data
      sort_options <- c(
        "First movement" = "startdate",
        "Patient ID" = "patient"
      )

      if(nrow(traces) > 0){

        ulocs_all <- unique(traces$location)
        # remove "Symptomatic" from ulocs_all list
        ulocs_all <- ulocs_all[ulocs_all != "Symptomatic"]

        # initialise location_sel_ui to be a dropdown containing all unique locations in the data
        output$location_sel_ui <- renderUI({
          selectInput(inputId = ns('location_sel'), "Select location to set colour", 
                      choices = sort(ulocs_all),
                      selected = ulocs_all[0])
        })

        output$location_col_ui <- renderUI(
          colourpicker::colourInput(
            ns("location_col"),
            label =  "Location colour",
            value = "#B3B3B3",
            showColour = "both",
            palette = "square",
            allowTransparent = TRUE
          )
        )

        #  symptomatic traces
        if(any(traces$layer == -1)){
          sort_options <- c(sort_options, "Onset date" = "symonsdate")
          output$symhgt_ui <- renderUI({
            sliderInput(ns("symhgt"), "Thickness of symptoms bars", min=0, max=50, value=5, step=1, round=0, ticks=FALSE)
          })
          output$symcol_ui <- renderUI(
            colourpicker::colourInput(
              ns("symcol"),
              label =  "Symptomatic period colour",
              value = "#B3B3B3",
              showColour = "both",
              palette = "square",
              allowTransparent = TRUE
            )
          )
        } else {
          output$symhgt_ui <- renderUI({})
          output$symcol_ui <- renderUI({})
        }

        # Extra cat selector
        if("extra_cat" %in% names(traces)){
          output$selectExtraCat <- renderUI({
            selectInput(inputId = ns('filterExtraCat'), "Filter by extra category", 
                        choices = sort(unique(traces$extra_cat)),
                        multiple = TRUE)
          })
        } else {
          output$selectExtraCat <- renderUI({})
        }

        if(any(traces$kind == "location")){
          output$selectLocation <- renderUI({
            selectInput(inputId = ns('filterLocation'), "Filter by location", 
                        choices = sort(unique(traces$location[traces$kind == "location"])),
                        multiple = TRUE)
          })
        } else {
          output$selectLocation <- renderUI({})
          output$selectExtraCat <- renderUI({})
          output$symhgt_ui <- renderUI({})
          output$symcol_ui <- renderUI({})
          output$location_sel_ui <- renderUI({})
          output$location_col_ui <- renderUI({})
        }
      }
      # if there are any events, set up the event filter UI
      if(nrow(events) > 0){

        # the inputs that effect any event
        output$poisiz_ui <- renderUI({
          sliderInput(ns("poisiz"), "Size of specimen/death points", min=0, max=20, value=5, step=1, round=0, ticks=FALSE)
        })

        # then event specific inputs
        if(any(events$type == "Positive specimen")){
          sort_options <- c(sort_options, "Specimen date" = "specdate")
          output$specol_ui <- renderUI(
            colourpicker::colourInput(
              ns("specol"),
              label =  "Positive specimen",
              value = "red",
              showColour = "both",
              palette = "square",
              allowTransparent = TRUE
            )
          )
        }
        if(any(events$type == "Negative specimen")){
          output$negcol_ui <- renderUI(
            colourpicker::colourInput(
              ns("negcol"),
              label =  "Negative specimen",
              value = "green",
              showColour = "both",
              palette = "square",
              allowTransparent = TRUE
            )
          )
        }
        if(any(events$type == "Death")){
          output$deacol_ui <- renderUI(
            colourpicker::colourInput(
              ns("deacol"),
              label =  "Death",
              value = "black",
              showColour = "both",
              palette = "square",
              allowTransparent = TRUE
            )
          )
        }
      } else {
        output$poisiz_ui <- renderUI({})
        output$specol_ui <- renderUI({})
        output$negcol_ui <- renderUI({})
        output$deacol_ui <- renderUI({})
      }

      if(nrow(casedefs) > 0){
        output$case_def_ui <- renderUI({
          checkboxInput(ns("case_def"), "Show case definition labels", value = FALSE)
        })
        output$cdfs_ui <- renderUI({
          sliderInput(ns("cdfs"), "Text size for case definition legend", min=0, max=50, value=12, step=1, round=0, ticks=FALSE)
        })
        output$selectCaseDef <- renderUI({
          selectInput(inputId = ns('filterCaseDef'), "Filter by case definition", 
                      choices = sort(unique(casedefs$case_def)),
                      multiple = TRUE)
        })
      } else {
        output$case_def_ui <- renderUI({})
        output$cdfs_ui <- renderUI({})
        output$selectCaseDef <- renderUI({})
      }

      # create the sort UI
      output$selectSort <- renderUI({
        radioButtons(inputId = ns("sorttype"), "Sort by:", choices = sort_options, selected = "startdate")
      })
    })

    # Second layer of data preparation.
    # This is where filtering based on data inputs will be applied, so this is expected to re-run more frequently as users apply and adjust filters.
    filtered_data <- reactive({
      req(inputdata_prep())

      traces <- inputdata_prep()$trace_data
      events <- inputdata_prep()$event_data
      case_defs <- inputdata_prep()$case_def_data

      # drop patients with no data once date filtered
      traces <- traces |>
        group_by(patient) |>
        filter(
          n() > 0 &
          !all(is.na(startdate)) &
          !all(is.na(enddate))
        ) |>
        filter(
          !(min(startdate, na.rm = TRUE) > input$daterange[2]) &
          !(max(enddate, na.rm = TRUE) < input$daterange[1])
        ) |>
          ungroup()
      # filter out events where event$patient is not in traces$patient
      
      if(nrow(events) > 0){
        events <- events |> filter(patient %in% traces$patient)
      }
      
      xmin <- input$daterange[1] %||% min(traces$startdate, na.rm = TRUE)
      xmax <- input$daterange[2] %||% max(traces$enddate, na.rm = TRUE)

      # convert to POSIXct if not already (to avoid issues with date handling later on)
      xmin <- as.POSIXct(xmin, origin = "1970-01-01", tz = "UTC")
      xmax <- as.POSIXct(xmax, origin = "1970-01-01", tz = "UTC")

      # if there are still events
      if(nrow(events) > 0){
        # drop events outside of the date range
        events <- events |> filter(event_date >= xmin & event_date <= xmax)
      }

      # truncate and drop traces outside of the date range
      traces <- traces |>
        mutate(
          startdate = pmax(startdate, xmin),
          enddate = pmin(enddate, xmax)
        ) |>
        filter(enddate >= startdate)
      
      if(isTruthy(input$filterLocation)){
        traces <- traces |>
          group_by(patient) |>
          filter(any(kind == "location" & location %in% input$filterLocation)) |>
          ungroup()
        # drop events where the patient does not meet the criteria
        events <- events |> filter(patient %in% traces$patient)
      }

      if("extra_cat" %in% names(traces)){
        if(isTruthy(input$filterExtraCat)){
          traces <- traces |>
            group_by(patient) |>
            filter(any(extra_cat %in% input$filterExtraCat)) |>
            ungroup()

          # drop events where the patient does not meet the criteria
          events <- events |> filter(patient %in% traces$patient)
          
        }
      }
      if(isTruthy(input$filterCaseDef)){
        
        # filter case_def data to the selected case definitions and get the patients that meet that criteria
        valid_patients <- case_defs |>
          filter(case_def %in% input$filterCaseDef) |>
          pull(patient) |>
          unique()

        # drop any traces where the patient does not meet the case definition criteria
        traces <- traces |> filter(patient %in% valid_patients)

        # drop any events where the patient does not meet the case definition criteria
        events <- events |> filter(patient %in% valid_patients)
      }

      return(list(traces_data = traces, event_data = events))

    }) # close filtered_data

    # Build the plotly traces and event
    timeline.plot <- reactive({
        req(filtered_data())
        traces <- filtered_data()$traces_data
        events <- filtered_data()$event_data
        case_defs <- inputdata_prep()$case_def_data
            
        if((nrow(traces) + nrow(events)) == 0){
          return(NULL)
        }
        
        # Sort patients
        sorttype <- input$sorttype %||% "startdate"
       
        # get the number of unique patients in the filtered data to set the y-axis
        # concatenate the unique patient identifiers present in traces with those present in events
        patients <- unique(c(traces$patient, events$patient))

        # sort patients be reordering factor
        if(!is.null(sorttype) && nrow(traces) > 0){
          sortnum_lookup <- sort_data_2(traces, events, sorttype)
          patient_y <- setNames(seq_along(sortnum_lookup), sortnum_lookup)
        } else {
          patient_y <- setNames(seq_along(patients), patients)
        }
      
        # put that back into the traces and events dataframes
        # get the bar spacing input
        barspc <- input$barspc %||% 0.2
        traces <- traces |> mutate(y = (patient_y[as.character(patient)] + (barspc*layer)))
        events <- events |> mutate(y = patient_y[as.character(patient)] + (barspc*layer))
        
        # if any traces are single_day == TRUE, adjust the height upwards a further half barspc
        traces <- traces |> mutate(
            y = if_else(single_day, y + (barspc/2), y)
          )

        # get the number of unique locations
        num_locations <- length(unique(traces$location))

        # build the colour palette based on the number of unique locations and the selected colour scheme
        colsch <- input$colsch %||% "Tableau 20"
        interp <-  input$colsch_interp %||% FALSE

        if(is.null(col_pal())){

          ulocs_all <- unique(inputdata_prep()$trace_data$location)
          ulocs_all <- ulocs_all[ulocs_all != "Symptomatic"]
        
          pal_cols = list(
            "Tableau 20" = 20,
            "Colourblind" = 8,
            "Set1" = 9,
            "Set2" = 8,
            "Set3" = 12,
            "Spectral" = 11,
            "Dark2" = 8,
            "Accent" = 8,
            "Paired" = 12
          )

          ncols_required <- min(max(1, length(ulocs_all)), pal_cols[[colsch]])

          if(colsch == "Tableau 20"){
            tabcol <- ggthemes::tableau_color_pal('Tableau 20')(20)[c(1,3,5,7,9,11,13,15,17,19,2,4,6,8,10,12,14,16,18,20)]
            c_pal <- tabcol[1:ncols_required]
          } else if(colsch == "Colourblind"){
            okabe_ito <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#000000")
            c_pal <- rep(okabe_ito, length.out = ncols_required)
          } else {
            c_pal <- RColorBrewer::brewer.pal(max(3, ncols_required), colsch)
          }

          if(length(ulocs_all) > ncols_required && interp){
            c_pal <- colorRampPalette(c_pal)(length(ulocs_all))
            c_pal <- sample(c_pal) # randomise the palette to reduce the risk of similar colours being assigned to adjacent locations
          }
          
          # create a dataframe of locations and their assigned colours
          if(length(ulocs_all) > 0){
            loc_col_df <- data.frame(location = ulocs_all, col = c_pal[1:length(ulocs_all)])
            
            # update location_col_ui to show the colour of the selected location
            updateColourInput(session, "location_col", value = loc_col_df$col[loc_col_df$location == input$location_sel])
          
          } else {
            loc_col_df <- data.frame(location = character(), col = character())
          }
          col_pal(loc_col_df)
        }
      
        # join the colour information back onto the traces
        traces <- traces |> left_join(col_pal(), by = "location")

        # then colour the symptomatic traces
        traces <- traces |> mutate(
          col = if_else(kind == "symptomatic", input$symcol %||% "#B3B3B3", col)
        )
        
        # then colour the event traces
        events <- events |> mutate(
          col = case_when(
            type == "Positive specimen" ~ input$specol %||% "red",
            type == "Negative specimen" ~ input$negcol %||% "green",
            type == "Death" ~ input$deacol %||% "black",
            TRUE ~ "black"
          )
        )
        # and set their shapes
        events <- events |> mutate(
          shape = case_when(
            type == "Positive specimen" ~ "triangle-right",
            type == "Negative specimen" ~ "triangle-left",
            type == "Death" ~ "diamond",
            TRUE ~ "circle"
          )
        )

        traces <- traces |> mutate(
          showlegend = TRUE
        )

        # set the overlap windows
        scale_factor <- 60 * 60 * 1000 # convert hours to milliseconds for use in plotly
        traces <- traces |> mutate(
          before = case_when(
            kind == "location" ~ input$hover_window_pre %||% 0,
            TRUE ~ 0
          ) * scale_factor,
          after = case_when(
            kind == "location" ~ input$hover_window_post %||% 0,
            TRUE ~ 0
          ) * scale_factor
        )

        # now build the plot
        fig <- plotly::plot_ly(width = input$plotwd %||% 1000, height = input$plotht %||% 500)

        # sort by layers so that symptomatic bars are plotted first and therefore
        # underneath any other traces they overlap with
        traces <- traces |> arrange(desc(layer), uname, movenum)

        t_sym <- traces |> filter(kind == "symptomatic")
        t_non_sym <- traces |> filter(kind != "symptomatic")

        # If all non-symptomatic uname values are numeric, re-sort by their numeric value
        uname_numeric <- suppressWarnings(as.numeric(t_non_sym$uname))
        if (!anyNA(uname_numeric)) {
          t_non_sym <- t_non_sym |> arrange(desc(layer), uname_numeric, movenum)
        }

        # symptomatic traces first so all other traces render on top of them
        traces <- rbind(t_sym, t_non_sym)

        # start with the traces
        legend_rendered <- c()
        for(k in seq_len(nrow(traces))){
          loc <- traces$location[k]
          if(loc %in% legend_rendered || !traces$showlegend[k]){
            showlegend = FALSE
          } else {
            showlegend = TRUE
            legend_rendered <- c(legend_rendered, loc)
          }
          fig <- fig |> plotly::add_trace(
            x = c(traces$startdate[k], traces$enddate[k]),
            y = c(traces$y[k], traces$y[k]),
            type = "scatter",
            mode = "lines",
            # make symptomatic traces symhgt thick and the rest barhgt thick
            line = list(
              color = traces$col[k],
              width = if_else(traces$kind[k] == "symptomatic", input$symhgt %||% 5, input$barhgt %||% 7)
            ),
            showlegend = showlegend,
            name = loc,
            legendgroup = loc,
            text = traces$text[k],
            hoverinfo = "text",
            meta = list(
              patient = traces$patient[k],
              kind = traces$kind[k],
              location = traces$uname[k],
              start = traces$startdate[k],
              end = traces$enddate[k],
              base_width = if_else(traces$kind[k] == "symptomatic", input$symhgt %||% 5, input$barhgt %||% 7),
              base_opacity = 1.0,
              base_color = traces$col[k],
              before = traces$before[k],
              after = traces$after[k]
            )
          )
        }
      
        # then add the events
        if(nrow(events) > 0){
          for(type in unique(events$type)){
            evs <- events |> filter(type == !!type)
            fig <- fig |> plotly::add_markers(
              data = evs,
              mode = "markers",
              x = ~event_date,
              y = ~y,
              marker = list(
                color = ~col,
                size = input$poisiz %||% 5,
                # line = list(color = "black", width = 1),
                symbol = ~shape
              ),
              name = ~type,
              hoverinfo = "text",
              text = ~text,
              meta = list(
                kind = "event",
                base_opacity = 1.0,
                base_width = input$poisiz %||% 5
              )
            )
          }
        }
        
        # add the hover behaviour JS
        highlight_behaviour <- input$hover_highlight %||% FALSE
        if(highlight_behaviour){
          fig <- fig |>
            htmlwidgets::onRender(
            "
            function(el, x) {
              const gd = document.getElementById(el.id);

              const t = (d) => new Date(d).getTime();

              const overlaps = (aStart, aEnd, bStart, bEnd, before, after) =>
                Math.max(aStart - before, bStart) <= Math.min(aEnd + after, bEnd);

              gd.on('plotly_hover', function(evt) {
                const curve = evt.points?.[0]?.curveNumber;
                if (curve == null) return;

                const hTrace = gd.data[curve];
                
                // if not hovering over something we want to react to, do nothing.
                if(!hTrace.meta || !['location', 'secondary', 'tertiary'].includes(hTrace.meta.kind)) return;
                

                const hLoc = hTrace.meta.location;
                const hStart = t(hTrace.meta.start);
                const hEnd = t(hTrace.meta.end);
                const hBefore = hTrace.meta.before ?? 0;
                const hAfter = hTrace.meta.after ?? 0;
                const hKind = hTrace.meta.kind;

                const opacities = [];
                const widths = [];
                const hitTraces = [];

                // Add the hovered trace as a hit
                hitTraces.push({
                  patient:   String(hTrace.meta.patient  ?? ''),
                  location:  String(hTrace.meta.location ?? ''),
                  startdate: String(hTrace.meta.start    ?? ''),
                  enddate:   String(hTrace.meta.end      ?? '')
                });

                for (let i = 0; i < gd.data.length; i++) {
                  const tr = gd.data[i];
                  const md = tr.meta || {};

                  //if (md.kind === 'movement' || md.kind === 'symptoms' || md.kind === 'event') {
                    const sameLoc = md.location === hLoc;

                    const ov = overlaps(hStart, hEnd, t(md.start), t(md.end), hBefore, hAfter);
                    const sk = md.kind == hKind;
                    const hit = sameLoc && ov && sk;

                    opacities.push(hit ? 1.0 : 0.12);
                    widths.push(hit ? 1.5*md.base_width : 0.5*md.base_width);

                    if (hit) {
                      hitTraces.push({
                        patient:   String(md.patient  ?? ''),
                        location:  String(md.location ?? ''),
                        startdate: String(md.start    ?? ''),
                        enddate:   String(md.end      ?? '')
                      });
                    }

                  //} else {
                  //  opacities.push(tr.opacity ?? 1);
                  //  widths.push(tr.line?.width ?? 2);
                  //}
                }

                Plotly.restyle(gd, { opacity: opacities, 'line.width': widths });

                if (window.Shiny && Shiny.setInputValue) {
                  Shiny.setInputValue(el.id + '_hit_traces', hitTraces, { priority: 'event' });
                }

              });

              gd.on('plotly_unhover', function() {
                const opacities = gd.data.map(tr => tr.meta?.base_opacity ?? (tr.opacity ?? 1));
                const widths = gd.data.map(tr => tr.meta?.base_width ?? (tr.line?.width ?? 2));
                Plotly.restyle(gd, { opacity: opacities, 'line.width': widths });
                if (window.Shiny && Shiny.setInputValue) {
                  Shiny.setInputValue(el.id + '_hit_traces', [], { priority: 'event' });
                }
              });
            }
            "
            )
        }

        # Set up gap suppression
        gaps <- data.frame()
        suppress <- input$suppress %||% "6 months"

        if (suppress != "Never" && nrow(traces) > 0) {
          # ivs::iv requires strict intervals: start < end
          trace_intervals <- traces |>
            filter(
              !is.na(startdate),
              !is.na(enddate),
              enddate > startdate
            )

          if (nrow(trace_intervals) > 0) {
            # merge all overlapping time periods into one
            merged_intervals <- ivs::iv(
              trace_intervals$startdate,
              trace_intervals$enddate
            ) |>
              ivs::iv_groups()

            # Create a new df of just the merged periods
            gaps <- data.frame(
              startdate = ivs::iv_start(merged_intervals),
              enddate = ivs::iv_end(merged_intervals)
            ) |>
              # calculate the gap between periods
              mutate(
                gap_start = lag(enddate),
                gap = startdate - gap_start,
                # Add some space for plotting
                nudge = floor(0.02 * gap),
                void_start = gap_start + nudge,
                void_end = startdate - nudge
              ) |>
                filter(lubridate::as.duration(gap) > lubridate::as.duration(lubridate::period(suppress)))
          }
        }

        # then build the x axis skips.
        if(nrow(gaps) > 0){
          x_breaks <- lapply(seq_len(nrow(gaps)), \(i) {
            list(bounds = c(gaps$void_start[i], gaps$void_end[i]))
          })
        } else {
          x_breaks = NULL
        }
      
      xlabrot <- input$xlabrot %||% "vertical"
      if(xlabrot == "horizontal"){
        xlabangle <- 0
        xlabhjust <- 0.5
        xlabvjust <- 1
      } else if(xlabrot == "vertical"){
        xlabangle <- 90
        xlabhjust <- 1
        xlabvjust <- 0.5
      } else if(xlabrot == "slanted"){
        xlabangle <- 45
        xlabhjust <- 1
        xlabvjust <- 1
      }

      # set up the tick marks based on user input or defaults
      majbre <- input$majbre %||% "1 month"
      minbre <- input$minbre %||% "1 week"
      x_start <- as.POSIXct(input$daterange[1] %||% data_mindate(), origin = "1970-01-01", tz = "UTC")
      x_end <- as.POSIXct(input$daterange[2] %||% data_maxdate(), origin = "1970-01-01", tz = "UTC")
      major_breaks <- seq(from = x_start, to = x_end, by = majbre)
      minor_breaks <- seq(from = x_start, to = x_end, by = minbre)
      
      yfs <- input$yfs %||% 14
      xfs <- input$xfs %||% 11

      # case definition labels are controlled via input$case_def
      
      if(input$case_def %||% FALSE){

        all_syms <- c(
          "\u25A0", # square
          "\u25B2", # triangle
          "\u25BC", # downwards triangle
          "\u25C6", # diamond
          "\u25A3", # double square
          "\u25D1", # half circle
          "\u25E9" # half square
        )
        cdef <- sort(unique(case_defs$case_def))
        # if any cdef is null replace with "Unknown"
        cdef[is.na(cdef)] <- "Unknown"

        cdef_symbols <- data.frame(
          case_def = cdef,
          symbol = all_syms[seq_along(cdef)]
        )

        case_defs <- case_defs |> left_join(cdef_symbols, by = "case_def")
        y_labels <- data.frame(patient = names(patient_y), y = patient_y) |>
          left_join(case_defs, by = "patient") |>
          mutate(label = if_else(!is.na(case_def), paste(patient, symbol, sep = " "), patient))

        # add a subtitle to the plot to explain the case definition symbols, with the text size based on the user input
        fig <- fig |> plotly::layout(
          title = list(
            text = paste0("Case definitions: ", paste(cdef, cdef_symbols$symbol, sep = " ", collapse = ", ")),
            font = list(size = input$cdfs %||% 12),
            y = 0,
            x = 0
          )
        )

      }else{
        y_labels <- data.frame(patient = names(patient_y), y = patient_y, label = names(patient_y))
      }

      majgricol <- input$majgricol %||% "#CCCCCC"
      mingricol <- input$mingricol %||% "#EEEEEE"

      # convert majgricol and mingricol to RGB format for plotly with an alpha of 0.5
      majgricol <- grDevices::col2rgb(majgricol)
      majgricol <- paste0("rgba(", majgricol[1,], ",", majgricol[2,], ",", majgricol[3,], ", 0.2)")
      mingricol <- grDevices::col2rgb(mingricol)
      mingricol <- paste0("rgba(", mingricol[1,], ",", mingricol[2,], ",", mingricol[3,], ", 0.2)")


      leg_pos <- input$leg_pos %||% "Top"
      if(leg_pos == "Top"){
        leg_list = list(
          font = list(size = input$legfs %||% 12),
          orientation="h",      # horizontal legend
          yanchor="bottom",
          y=1.02,
          xanchor="left",
          x=0
        )
      } else {
        leg_list = list(
          font = list(size = input$legfs %||% 12)
        )
      }

      # use patient_names for y axis labels
      fig <- fig |> plotly::layout(
        #legend = list(orientation = "h", x = 0.5, xanchor = "center", y = 1.1),
        # set the y axis with patient names
        yaxis = list(
          tickmode = "array",
          tickvals = y_labels$y,
          ticktext = y_labels$label,
          title = "Patient",
          ticks = "outside",
          range = c(0.5, length(patient_y) + 0.5),
          font = list(size = yfs),
          tickfont = list(size = yfs)
        ),
        # now set the x axis ticks and gap suppression
        xaxis = list(
          title = "Date",
          ticks = "outside",
          tickangle = xlabangle,
          tickfont = list(size = xfs),
          tickvals = major_breaks,
          ticktext = format(major_breaks, "%Y-%m-%d"),
          rangebreaks = x_breaks,
          tickcolor = majgricol,
          gridcolor = majgricol,
          minor = list(
            dtick = switch(minbre, "1 day" = 86400000, "1 week" = 7 * 86400000, "1 month" = "M1", "1 year" = "M12", 86400000),
            showgrid = TRUE,
            gridcolor = mingricol,
            tickcolor = mingricol
          ),
          font = list(size = xfs)
        ),
        legend = leg_list
      )
      figure(fig)
      return(fig)
    })

    # Debounce bookmark saving so it only fires ~2s after the user stops
    # adjusting inputs, rather than on every single change.
    timeline_plot_debounced <- debounce(timeline.plot, 2000)

    observeEvent(timeline_plot_debounced(), {
      # Persist the current UI state so it can be restored on next visit.
      timeline_save_ui_bookmark(postgres_con, app_name, uname, "default", input)
    })
    
    output$timeline <- plotly::renderPlotly({
      timeline.plot()
    })

    observeEvent(input$colsch, {
      col_pal(NULL)
    })

    observeEvent(input$ShuffleCols, {
      c <- col_pal() |> mutate(col = sample(col))
      col_pal(c)

      # update location_col_ui to show the colour of the selected location
      updateColourInput(session, "location_col", value = c$col[c$location == input$location_sel])
    })

    hover_info_df <- reactiveVal(data.frame())

    observeEvent(input$timeline_hit_traces, {
      hits <- input$timeline_hit_traces

      if (length(hits) == 0) {
        hover_info_df(data.frame())
      } else {
        # hits is a flat list of single-element vectors, 4 per trace in order:
        # patient, location, startdate, enddate
        vals <- unlist(hits)
        n <- length(vals) / 4

        df <- data.frame(
          patient   = vals[seq(1, by = 4, length.out = n)],
          location  = vals[seq(2, by = 4, length.out = n)],
          startdate = vals[seq(3, by = 4, length.out = n)],
          enddate   = vals[seq(4, by = 4, length.out = n)],
          stringsAsFactors = FALSE
        )

        # drop duplicate rows
        df <- df[!duplicated(df), ]
        
        # drop the milliseconds from the dates for cleaner display
        df$startdate <- as.POSIXct(df$startdate, origin = "1970-01-01", tz = "UTC")
        df$enddate <- as.POSIXct(df$enddate, origin = "1970-01-01", tz = "UTC")
        df$startdate <- format(df$startdate, "%Y-%m-%d %H:%M:%S")
        df$enddate <- format(df$enddate, "%Y-%m-%d %H:%M:%S")

        hover_info_df(df)
      }
    })

    output$hover_info <- renderTable({
      hover_info_df()
    })

    output$hover_info_file <- downloadHandler(
      filename = 'hover_info.csv',
      content = function(file) {
        write.csv(hover_info_df(), file, row.names = TRUE)
      }
    )

    output$download_rds <- downloadHandler(
      filename = 'timeline_plot.rds',
      content = function(file) {
        saveRDS(figure(), file)
      }
    )

    observeEvent(input$download_svg_btn, {
      session$sendCustomMessage(
        "download-svg",
        list(
          id = ns("timeline"),
          filename = "timeline_plot"
        )
      )
    })

    col_choices <- reactive({
      req(inputdata_prep())
      palettes <- c(
        "Tableau 20" = "Tableau 20",
        "Colour blind" = "Colourblind",
        "Set 1" = "Set1",
        "Set 2" = "Set2",
        "Set 3" = "Set3",
        "Spectral" = "Spectral",
        "Dark 2" = "Dark2",
        "Accent" = "Accent",
        "Paired" = "Paired"
      )
      pallette_limits <- data.frame(
        col = palettes,
        limit = as.integer(c(20, 8, 9, 8, 12, 11, 8, 8, 12))
      )

      allow_interp <- input$colsch_interp %||% FALSE
      if(allow_interp){
        return(palettes)
      } else {
        
        unique_locs <- length(unique(inputdata_prep()$trace_data$location))
        palettes <- palettes[pallette_limits$limit >= unique_locs]
        if(length(palettes) == 0){
          palettes <- c("Tableau 20" = "Tableau 20")
        }

        return(palettes)
      }

    })

    observeEvent(input$location_sel, {
      req(col_pal(), input$location_sel)
      loc_col_df <- col_pal()
      updateColourInput(session, "location_col", value = loc_col_df$col[loc_col_df$location == input$location_sel])
    })

    observeEvent(input$location_col, {
      req(col_pal(), input$location_sel)
      loc_col_df <- col_pal()
      idx <- match(input$location_sel, loc_col_df$location)
      req(!is.na(idx))
      loc_col_df$col[idx] <- input$location_col
      col_pal(loc_col_df)
    })

    observeEvent(input$location_col_reset, {
      col_pal(NULL)
    })

    output$colsch_ui <- renderUI({
      # col_choices() req()s on inputdata_prep() and can throw before data is
      # loaded; resolve it first so a failed attempt doesn't consume/lose the
      # pending saved value below
      choices <- col_choices()
      pending <- isolate(saved_colsch())
      if (!is.null(pending)) {
        saved_colsch(NULL)
        selected <- pending
      } else {
        selected <- input$colsch %||% "Tableau 20"
      }
      radioButtons(ns("colsch"), "Colour scheme:", choices = choices, selected = selected)
    })
    # lives on the "Colour" tab; render it even while hidden so the saved
    # bookmark value is applied on load instead of only when the tab is opened
    outputOptions(output, "colsch_ui", suspendWhenHidden = FALSE)

    observeEvent(input$hotkey_pressed, {
      hotkey <- input$hotkey_pressed
      if(hotkey == "f" || hotkey == "F"){
        val = input$hover_highlight %||% FALSE
        updateCheckboxInput(session, "hover_highlight", value = !val)
        # flash a warning message to indicate the hover behaviour has been toggled
        if(!val){
          showNotification("Hover behaviour enabled", type = "message", duration = 2)
        } else {
          showNotification("Hover behaviour disabled", type = "message", duration = 2)
        }
      }

    })

  }) # close 
}