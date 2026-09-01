#' Read App Config
#'
#' Retrieve a value from the golem configuration file (`inst/golem-config.yml`).
#'
#' @param value The key to retrieve from the config file.
#' @param config The configuration environment to use. Defaults to the value of
#'   the `GOLEM_CONFIG_ACTIVE` environment variable, or `"default"` if unset.
#' @param use_parent Whether to inherit values from the parent configuration.
#'
#' @return The configuration value for the given key.
#'
#' @export
get_golem_config <- function(
    value,
    config = Sys.getenv("GOLEM_CONFIG_ACTIVE", unset = "default"),
    use_parent = TRUE
) {
  config::get(
    value = value,
    config = config,
    file = app_sys("golem-config.yml"),
    use_parent = use_parent
  )
}

#' System File Helper
#'
#' Wrapper around `system.file()` scoped to the TICLR package.
#'
#' @param ... Character vectors, passed to `system.file()`.
#'
#' @return A character string giving the path to the file found.
#'
#' @export
app_sys <- function(...) {
  system.file(..., package = "TICLR")
}
