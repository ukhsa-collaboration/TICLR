#' Sort Data
#'
#' Creates an ordered character vector of unique `patient` values,
#' sorted according to a given column.
#' If the sorting column does not exist, sorting defaults to `patient`.
#' The output is reversed to support plotting from top to bottom.
#'
#' @param df A data.frame containing at least a `patient` column.
#' @param var String: column name to sort on
#'
#' @return A character vector of uniquely ordered patient IDs.
#'   Returns `character(0)` if `df` has zero rows.

#' @export
#'
#' @examples
#' # Example data
#' df <- data.frame(
#'   patient = c("A", "B", "C", "A", "B"),
#'   startdate = c(3, 1, 2, 4, 6)
#' )
#'
#' # Sort by a column
#' sort_data(df, "startdate")
#'
#' # Sort by patient (var not provided or invalid)
#' sort_data(df, NULL)
#' sort_data(df, "nonexistent_column")
sort_data <- function(df, var){

  if (nrow(df) == 0) return(character(0))

  df$patient <- as.character(df$patient)

  # If var doesn't exist, sort by patient; otherwise sort by var
  sort_col <- if (!is.null(var) && var %in% colnames(df)) var else "patient"

  df |>
    dplyr::arrange(.data[[sort_col]]) |>
    dplyr::distinct(patient) |>
    dplyr::pull(patient) |>
    rev()

}

#' Update Input Columns
#'
#' Update the options in a selectInput when provided with a vector of options,
#' default to the input id if it's in the vector. Used in `module_input_data`
#' for selecting which columns in the input data should be used for which variable
#'
#' @param session A Shiny session object
#' @param col_list Vector of column names
#' @param col_to_update String - name of column selector to update
#'
#' @return This function is called for its side effect of updating a Shiny
#'   `selectizeInput` widget. It returns the result of `updateSelectizeInput()`,
#'   which is the updated UI input object (invisibly).

#' @export
#'
#' @examples
#' # A minimal runnable Shiny example:
#' if (interactive()) {
#'
#'   library(shiny)
#'
#'   ui <- fluidPage(
#'     selectInput("patient", "Patient column:", choices = NULL),
#'     actionButton("load", "Load columns")
#'   )
#'
#'   server <- function(input, output, session) {
#'
#'     # Simulated column names (e.g., from a data frame)
#'     example_cols <- c("patient", "startdate", "enddate")
#'
#'     observeEvent(input$load, {
#'       updateInputCols(
#'         session = session,
#'         col_list = example_cols,
#'         col_to_update = "patient"
#'       )
#'     })
#'   }
#'
#'   shinyApp(ui, server)
#' }
updateInputCols <- function(session, col_list, col_to_update){
  shiny::updateSelectizeInput(session, col_to_update,
                    choices = c("", col_list, allowEmptyOption = T),
                    selected = switch(col_to_update %in% col_list,
                                      col_to_update, NULL))
}


#' Detect malformed or unparseable date strings
#'
#' Attempts to parse a character vector of dates using several common
#' date formats (`"dmy"`, `"ymd"`, and `"mdy"`).
#' Returns a tibble containing the original input, the parsed
#' `POSIXct` values, and a logical indicator showing which entries
#' could not be parsed.
#'
#' @param x A character vector containing date strings to check.
#'
#' @return A tibble with three columns:
#' \describe{
#'   \item{original}{The original input values.}
#'   \item{parsed}{The parsed date values (or `NA` if parsing failed).}
#'   \item{bad}{Logical flag indicating whether the input could not be parsed.}
#' }
#'
#' @details
#' Parsing is performed using `lubridate::parse_date_time()` with quiet
#' mode enabled. A value is marked as `bad` when parsing returns `NA`
#' but the original value is not `NA` and not an empty string.
#'
#' @examples
#' detect_bad_dates(c("2020-01-01", "31/12/2020", "13/40/2020", ""))
#'
#' @export
detect_bad_dates <- function(x) {
  # If already parsed (POSIXct/Date), treat all non-NA values as valid
  if (inherits(x, c("POSIXct", "POSIXlt", "Date"))) {
    return(dplyr::tibble(
      original = as.character(x),
      parsed   = as.POSIXct(x),
      bad      = FALSE
    ))
  }
  parsed <- lubridate::parse_date_time(
    x,
    c("dmy", "ymd", "mdy", "dmy HMS", "ymd HMS", "mdy HMS"),
    quiet = TRUE
  )
  bad <- is.na(parsed) & !is.na(x) & nchar(trimws(x)) > 0
  dplyr::tibble(original = x, parsed = parsed, bad = bad)
}


#' Sort Data (Version 2)
#'
#' Sorts patients for the Plotly timeline using movement and/or event dates.
#'
#' @param df A data.frame of timeline traces (must include `patient` and `startdate`; may include `kind`).
#' @param events A data.frame of events (must include `patient`, `type`, and `event_date`).
#' @param sorttype String; one of "startdate", "patient", "symonsdate", or "specdate".
#' @return A character vector of uniquely ordered patient IDs.
#' @export
sort_data_2 <- function(df, events, sorttype){
  
  # For the two movement sort types we can reuse the older sorting function
  if(sorttype %in% c("startdate", "patient")){
    return(sort_data(df, sorttype))
  } else if(sorttype == "symonsdate"){
    # get the list of patients sorted by startdate
    ssort <- sort_data(df, "startdate") |> rev()
    
    # subset df to only include symptomatic types
    patients <- df |> dplyr::filter(kind == "symptomatic") |>
      dplyr::arrange(startdate, patient) |>
      dplyr::distinct(patient) |>
      dplyr::pull(patient)
    
    # concatenate with the patients sorted by startdate
    return(unique(c(patients, ssort)) |> rev())

  } else if(sorttype == "specdate"){

    # get the list of patients sorted by startdate
    ssort <- sort_data(df, "startdate") |> rev()
    patients <- events |> 
      dplyr::filter(type == "Positive specimen") |>
      dplyr::arrange(event_date, patient) |>
      dplyr::distinct(patient) |>
      dplyr::pull(patient)

    # concatenate with the patients sorted by startdate
    # putting patients with a positive specimen at the top of the list
    return(unique(c(patients, ssort)) |> rev())

  } else {
    # error handling for invalid sorttype
    stop(paste("Invalid sorttype:", sorttype))
  }

}