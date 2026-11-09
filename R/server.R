### Server

#' Application server logic
#'
#' @param input Shiny inputs
#' @param output Shiny outputs
#' @param session Shiny session
#'
#' @export

app_server <- function(input, output, session) {

  # --- Module Servers ---
  mod_help_about_server("mod_help_about_1")
  inputdata <- mod_input_data_server("mod_input_data_1")
  mod_timeline_server("mod_plotly_timeline_1", inputdata)

}
