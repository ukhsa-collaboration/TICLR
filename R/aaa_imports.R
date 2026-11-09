#' @import dplyr
#' @import tidyr
#' @import ggplot2
#' @import bslib
#' @import glue
#' @import purrr
#' @import lubridate
#' @import plotly
#' @import htmlwidgets
#' @import keys
#' @import shinycssloaders
#' @importFrom scales date_breaks date_format
#' @importFrom stringr str_detect str_replace
#' @importFrom stats setNames
#' @importFrom utils read.csv write.csv
#' @import shiny
#' @importFrom shinyjs useShinyjs
#' @importFrom colourpicker colourInput updateColourInput
#' @importFrom shinyWidgets updateSliderTextInput
#' @import RColorBrewer
#' @importFrom scales hue_pal
#' @importFrom grDevices colorRampPalette
"_PACKAGE"

# Column/variable names referenced via tidyverse NSE (not literal objects).
utils::globalVariables(c(
  "case_def", "enddate", "event_date", "extra_cat", "gap", "gap_start",
  "has_error", "kind", "location", "movenum", "msg", "nudge", "original",
  "patient", "single_day", "startdate", "symbol", "symenddate", "symonsdate",
  "type", "uname", "value", "variable", "y"
))
