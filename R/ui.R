### UI

#' Application UI
#'
#' @param request Internal parameter for Shiny. Do not modify.
#' @return A Shiny UI object.
#' @export


app_ui <- function(request) {

  tagList(
    navbarPage(
      id = "navbarPage",

      # Add logo + navigation bar
      title = div(img(
        src = "www/ukhsa_landscape_logo_white.svg",
        style = "padding-top: 20px; padding-right: 40px; float:left",
        height = "50"
      )),

      # Theme
      windowTitle = "TICLR Timeline Tool",
      theme = ukhsa_theme,

      # Add tabs
      # Landing page
      tabPanel(
        "Home",
        mod_help_about("mod_help_about_1")
      ),

      #Input data
      tabPanel(
        "Input Data",
        mod_input_data("mod_input_data_1")
      ),
      tabPanel(
        "Timeline",
        mod_timeline("mod_plotly_timeline_1")
      )
    ) # end navbarpage
  ) # end tagList

}
