### Server

#' Application server logic
#'
#' @param input Shiny inputs
#' @param output Shiny outputs
#' @param session Shiny session
#'
#' @export

app_server <- function(input, output, session) {


  # --- DUST User Tracking Setup ---
  # Connect to DUST Postgres (silencer controlled via golem-config.yml)
  silencer <- get_golem_config("silencer")
  if(Sys.getenv("POSTGRES_PASSWORD") != ""){
    silencer = FALSE
  }
   
  postgres_con <- dust_connect_to_postgres(silencer = silencer)

  # Session setup (detects platform, gets username, session ID, etc.)
  session_info <- dust_session_setup(session)
  session_id   <- session_info$session_id
  uname        <- session_info$uname
  log_file_path <- session_info$log_file_path

  # Log messages
  message(glue("Session ID: {session_id}"))
  message(glue("User: {uname}"))

  # Create session log entry
  app_name <- "TICLR"
  users_data_start <- dust_create_session_log(
    app_name   = app_name,
    session_id = session_id,
    username   = uname
  )

  existing_bookmarks <- tibble::tibble()
  if(silencer == FALSE){
    dust_init_bookmarks(postgres_con)
    existing_bookmarks <- dust_find_bookmarks(postgres_con, app_name, uname)
  }
  # Write session log on session end
  dust_write_session_log(
    session          = session,
    users_data_start = users_data_start,
    log_file_path    = log_file_path,
    session_id       = session_id,
    con              = postgres_con,
    access           = if (!is.null(session_info$urole) && !anyNA(session_info$urole)) {
      paste(session_info$urole, collapse = ", ")
    } else if (.Platform$OS.type == "unix") {
      "No Access Groups"
    } else {
      "Local"
    },
    write_locally    = FALSE
  )

  # --- Tab Activity Logging ---
  # Log tab switches on the main navbar
  dust_log_tab_event(
    input_id      = "navbarPage",
    input         = input,
    app_name      = app_name,
    session_id    = session_id,
    uname         = uname,
    log_file_path = log_file_path,
    postgres_con  = postgres_con,
    write_locally = FALSE
  )

  # --- Module Servers ---
  mod_help_about_server("mod_help_about_1")
  inputdata <- mod_input_data_server("mod_input_data_1")
  mod_timeline_server("mod_plotly_timeline_1", inputdata, postgres_con,  existing_bookmarks, app_name, uname)

}
