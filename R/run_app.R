#' Launch the Shiny Application
#'
#' @param onStart A function of no arguments to be called before the app is
#'   started. Passed through to [shiny::shinyApp()].
#' @param options A list of options to pass to [shiny::shinyApp()].
#' @param enableBookmarking Passed through to [shiny::shinyApp()].
#' @param uiPattern Passed through to [shiny::shinyApp()].
#' @param ... Additional named arguments passed to [golem::with_golem_options()].
#'
#' @export
run_app <- function(
    onStart = NULL,
    options = list(),
    enableBookmarking = NULL,
    uiPattern = "/",
    ...
) {

  golem::with_golem_options(
    app = shiny::shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = function() {
        ## set display table options
        base::options(DT.options = list(
          pageLength = 10,
          rownames = FALSE,
          searching = FALSE,
          language = list(search = 'Filter:', target = 'column'),
          lengthChange = FALSE,
          lengthMenu = c(10, 20, 50, 100)
        ))

        ## mount the package's static resources under a URL prefix ("www")
        shiny::addResourcePath(
          prefix = "www",
          directoryPath = app_sys("app/www")
        )

        if (is.function(onStart)) onStart()
      },
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = list(...)
  )

}
