# DUST FUNCTIONS
# Dashboard User Statistics Tracking

#' Connect to DUST Postgres database
#'
#' @param silencer Logical. If TRUE, disables logging. Set to FALSE to enable logging.
#'
#' @return A DBI connection object, or NULL if silencer is TRUE.
#'
#' @importFrom DBI dbConnect dbWriteTable
#' @importFrom odbc odbc
#' @keywords internal
dust_connect_to_postgres <- function(silencer = FALSE) {

  # Check silencer parameter to determine whether to log
  # Stop logging and send message
  if(silencer == TRUE) {

    message("DUST: Logging is currently disabled. To re-enable it, set the `silencer` parameter to FALSE.")

    return()

    # Proceed with logging
  } else {

    # Retrieve credentials from environment variables
    db <- Sys.getenv("POSTGRES_DB")
    username_pg <- Sys.getenv("POSTGRES_USER")
    password <- Sys.getenv("POSTGRES_PASSWORD")
    host <- Sys.getenv("POSTGRES_HOST")
    port <- Sys.getenv("POSTGRES_PORT")

    if (.Platform$OS.type == "unix") {
      # Create a postgres connection
      connection <- DBI::dbConnect(
        odbc::odbc(),
        Driver = "PostgreSQL Unicode(x64)",
        Server = host,
        Database = db,
        UID = username_pg,
        PWD = password,
        Port = as.integer(port)
      )
    } else {
      # Create a postgres connection using RPostgres
      connection <- DBI::dbConnect(
        RPostgres::Postgres(),
        host = host,
        dbname = db,
        user = username_pg,
        password = password,
        port = as.integer(port)
      )
    }
    return(connection)
  }
}


#' Set up DUST session variables
#'
#' Detects platform and extracts username, session ID, role and log path.
#'
#' @param session Shiny session object.
#'
#' @return A list with session_id, uname, urole, and log_file_path.
#' @keywords internal
dust_session_setup <- function(session) {
  if (.Platform$OS.type == "unix") {
    uname <- session$request$HTTP_X_FORWARDED_EMAIL
    session_id <- session$token
    role_values <- session$request$HTTP_X_FORWARDED_GROUPS
    log_file_path <- "/logs/"

    if (!is.null(role_values) && length(role_values) > 0 && !is.na(role_values)) {
      role_values <- unlist(strsplit(role_values, ","))

      groups <- list(
        "rls_north_west" = "North West",
        "rls_south_west" = "South West",
        "rls_south_east" = "South East",
        "rls_yorkshire_and_the_humber" = "Yorkshire and The Humber",
        "rls_east_of_england" = "East of England",
        "rls_london" = "London",
        "rls_west_midlands" = "West Midlands",
        "rls_east_midlands" = "East Midlands",
        "rls_north_east" = "North East",
        "rls_all_regions" = "All Regions"
      )

      urole <- c()
      for (group_name in names(groups)) {
        if (group_name %in% role_values) {
          urole <- c(urole, groups[[group_name]])
        }
      }
    } else {
      urole <- NA
    }

  } else {
    uname <- Sys.info()[["user"]]
    session_id <- uuid::UUIDgenerate()
    urole <- NA
    log_file_path <- "logs/"
  }

  list(
    session_id = session_id,
    uname = uname,
    urole = urole,
    log_file_path = log_file_path
  )
}


#' Create DUST session log entry
#'
#' @param app_name Character. Name of the application.
#' @param session_id Character. Session identifier.
#' @param username Character. Username.
#' @param silencer Logical. If TRUE, disables logging.
#'
#' @return A data.frame with session start info, or NULL if silencer is TRUE.
#' @keywords internal
dust_create_session_log <- function(app_name, session_id, username, silencer = FALSE) {

  if (silencer == TRUE) {
    return(NULL)
  }

  start_time <- Sys.time()

  data.frame(
    app_name = app_name,
    session_id = session_id,
    username = username,
    start_time = start_time
  )
}


#' Write DUST session log on session end
#'
#' @param session Shiny session object.
#' @param users_data_start Data.frame from dust_create_session_log().
#' @param log_file_path Character. Path for local log files.
#' @param session_id Character. Session identifier.
#' @param con DBI connection object.
#' @param access Character. User access/role string.
#' @param write_locally Logical. Whether to also write a local log file.
#'
#' @importFrom DBI dbWriteTable
#' @keywords internal
dust_write_session_log <- function(session, users_data_start, log_file_path, session_id, con, access, write_locally = FALSE) {
  session$onSessionEnded(function() {

    users_data <- users_data_start
    end_time <- Sys.time()
    users_data$end_time <- end_time

    if (write_locally == TRUE) {
      utils::write.table(
        x = users_data,
        file = paste0(log_file_path, "session_log_", session_id, ".txt"),
        append = TRUE,
        row.names = FALSE,
        col.names = FALSE,
        sep = ";"
      )
    }

    tryCatch({
      DBI::dbWriteTable(
        con = con,
        name = "session",
        value = data.frame(
          app_name = users_data$app_name[1],
          session_id = users_data$session_id[1],
          username = users_data$username[1],
          access = access,
          start_time = users_data$start_time[1],
          end_time = end_time
        ),
        append = TRUE,
        row.names = FALSE
      )
    }, error = function(e) {
      message("DUST: Error during session upload: ", e$message)
    })

  })
}


#' Log tab activity to DUST
#'
#' @param input_value Character. The current tab name.
#' @param app_name Character. Application name.
#' @param session_id Character. Session identifier.
#' @param uname Character. Username.
#' @param log_file_path Character. Path for local log files.
#' @param postgres_con DBI connection object.
#' @param write_locally Logical. Whether to also write a local log file.
#'
#' @importFrom DBI dbWriteTable
#' @keywords internal
dust_log_tab_activity <- function(input_value, app_name, session_id, uname, log_file_path, postgres_con, write_locally = FALSE) {

  message("DUST: ", session_id, ": ", uname, ": USER ON ", input_value)

  isolate({
    usertabinfo <- data.frame(
      app_name = app_name,
      session_id = session_id,
      tab = input_value,
      time_clicked = Sys.time()
    )

    if (write_locally == TRUE) {
      tryCatch({
        utils::write.table(
          rbind(usertabinfo),
          paste0(log_file_path, "tabs", session_id, ".txt"),
          sep = ";",
          append = TRUE,
          row.names = FALSE,
          col.names = FALSE
        )
      }, error = function(e) {
        message("DUST: Error writing ", input_value, " table: ", e$message)
      })
    }

    tryCatch({
      DBI::dbWriteTable(
        con = postgres_con,
        name = "tab",
        usertabinfo,
        append = TRUE,
        row.names = FALSE
      )
    }, error = function(e) {
      message("DUST: Error during ", input_value, " DUST upload: ", e$message)
    })
  })
}


#' Observe and log tab events
#'
#' @param input_id Character. The input ID of the tab panel to observe.
#' @param input Shiny input object.
#' @param app_name Character. Application name.
#' @param session_id Character. Session identifier.
#' @param uname Character. Username.
#' @param log_file_path Character. Path for local log files.
#' @param postgres_con DBI connection object.
#' @param write_locally Logical. Whether to also write a local log file.
#' @param tab_mapping Named list. Custom tab name mapping.
#' @param tabs_to_log Character vector. Specific tabs to log (NULL = all).
#' @param parent_tab Character. Input ID of parent tab for first-tab logging.
#' @param parent_tab_name Character. Name of parent tab.
#' @param first_tab Character. Name of first sub-tab.
#' @param silencer Logical. If TRUE, disables logging.
#'
#' @keywords internal
dust_log_tab_event <- function(input_id, input, app_name, session_id, uname,
                               log_file_path, postgres_con, write_locally = FALSE,
                               tab_mapping = NULL, tabs_to_log = NULL,
                               parent_tab = NULL, parent_tab_name = NULL, first_tab = NULL,
                               silencer = FALSE) {

  if (silencer == TRUE) {
    return()
  }

  # Observe tab switches

  observeEvent(input[[input_id]], {

    current_tab <- input[[input_id]]

    if (is.null(current_tab)) return()

    # Filter tabs if specified
    if (!is.null(tabs_to_log) && !(current_tab %in% tabs_to_log)) return()

    # Apply custom tab mapping
    if (!is.null(tab_mapping) && current_tab %in% names(tab_mapping)) {
      tab_label <- tab_mapping[[current_tab]]
      tab_name <- current_tab
    } else {
      tab_label <- current_tab
      tab_name <- current_tab
    }

    # Log tab activity
    dust_log_tab_activity(tab_label, app_name, session_id, uname, log_file_path, postgres_con, write_locally)

  }, ignoreInit = TRUE)

  # Validate parent tab parameters

  tab_params <- list(parent_tab, parent_tab_name, first_tab)
  non_null_count <- sum(!sapply(tab_params, is.null))

  if (non_null_count > 0 && non_null_count < 3) {
    message(
      "DUST: Parameters `parent_tab`, `first_tab`, and `parent_tab_name` must be provided together or not at all."
    )
    return()
  }

  # Parent tab first sub-tab logging

  if (!is.null(parent_tab) && !is.null(parent_tab_name) && !is.null(first_tab)) {

    observeEvent(input[[parent_tab]], {

      current_parent_tab <- input[[parent_tab]]
      current_sub_tab <- input[[input_id]]

      if (!is.null(tab_mapping) && current_sub_tab %in% names(tab_mapping)) {
        current_sub_tab_label <- tab_mapping[[current_sub_tab]]
      } else {
        current_sub_tab_label <- current_sub_tab
      }

      if (is.null(current_parent_tab)) return()

      if (current_parent_tab == parent_tab_name) {
        dust_log_tab_activity(current_sub_tab_label, app_name, session_id, uname, log_file_path, postgres_con, write_locally)
      }

    }, ignoreInit = TRUE)
  }
}


#' Log a custom event to DUST
#'
#' @param postgres_con DBI connection object.
#' @param app_name Character. Application name.
#' @param session_id Character. Session identifier.
#' @param event_type Character. Type of event (e.g. "download").
#' @param tag Character. Grouping field (e.g. region).
#' @param value Character. Additional value to log.
#'
#' @importFrom DBI dbWriteTable
#' @keywords internal
dust_log_event <- function(postgres_con, app_name, session_id, event_type, tag, value) {

  tryCatch({
    DBI::dbWriteTable(
      con = postgres_con,
      name = "event",
      value = data.frame(
        app_name = app_name,
        session_id = session_id,
        event_type = event_type,
        tag = tag,
        value = value,
        time_clicked = Sys.time()
      ),
      append = TRUE,
      row.names = FALSE
    )
  }, error = function(e) {
    message("DUST: Error during ", event_type, " upload: ", e$message)
  })
}


dust_init_bookmarks <- function(postgres_con){
  # first create the table if it does not exist
  tryCatch({
    DBI::dbExecute(
      con = postgres_con,
      "CREATE TABLE IF NOT EXISTS public.user_settings(
        id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        app_name VARCHAR(255) NOT NULL,
        username VARCHAR(255) NOT NULL,
        s_key VARCHAR(255),
        settings TEXT NOT NULL,
        last_updated TIMESTAMP DEFAULT NOW(),
        CONSTRAINT user_settings_app_user_skey_key UNIQUE (app_name, username, s_key)
      )"
    )
  }, error = function(e){ message(paste0("Error during table creation: ", e$message))})

  # backfill the uniqueness constraint for tables created before this was added,
  # so the ON CONFLICT upsert in dust_save_bookmark() has something to target
  tryCatch({
    dbExecute(
      con = postgres_con,
      "DO $$
       BEGIN
         IF NOT EXISTS (
           SELECT 1 FROM pg_constraint WHERE conname = 'user_settings_app_user_skey_key'
         ) THEN
           ALTER TABLE public.user_settings
             ADD CONSTRAINT user_settings_app_user_skey_key UNIQUE (app_name, username, s_key);
         END IF;
       END $$;"
    )
  }, error = function(e){ message(paste0("Error adding uniqueness constraint: ", e$message))})
}

dust_find_bookmarks <- function(postgres_con, app_name, uname) {

  if(!isS4(postgres_con)){
    return(tibble::tibble())
  }

  tryCatch({

    existing_bookmarks <- dbGetQuery(
      con = postgres_con,
      glue::glue_sql(
        "SELECT s_key, settings FROM user_settings WHERE app_name = {app_name} AND username = {uname}",
        .con = postgres_con
      )
    )

    if(nrow(existing_bookmarks) > 0){
      existing_bookmarks <- existing_bookmarks |>
        mutate(set = purrr::map(settings, jsonlite::fromJSON, simplifyVector = FALSE))

      # sort rows alphabetically by s_key
      existing_bookmarks <- existing_bookmarks |> arrange(s_key)
      return(existing_bookmarks)
    } else {
      existing_bookmarks <- tibble::tibble()
      return(existing_bookmarks)
    }
  }, error = function(e) {
    message(paste0("Error during bookmark retrieval: ", e$message))
    tibble::tibble()
  })
}


#' Save or update a user bookmark in the DUST PostgreSQL database
#'
#' Persists a user's application settings as a JSON bookmark, identified by
#' app name, username, and a user-chosen preset name (\code{s_key}). The
#' row is written with a single atomic \code{INSERT ... ON CONFLICT DO UPDATE}
#' (relying on the unique constraint on \code{(app_name, username, s_key)}
#' created by \code{dust_init_bookmarks()}), so concurrent saves from the same
#' user/preset cannot race into duplicate rows. All queries are parameterized
#' via \code{glue::glue_sql()} to guard against SQL injection.
#'
#' @param postgres_con A DBI connection object to the DUST PostgreSQL database,
#'   as returned by \code{dust_connect_to_postgres()}.
#' @param app_name A string specifying the application name.
#' @param uname A string giving the current username (e.g. from
#'   \code{session$request$HTTP_X_FORWARDED_EMAIL}). If \code{NULL} or empty,
#'   the save is aborted and an error is logged.
#' @param name A string giving the preset's identifier/label (\code{s_key})
#'   under which the bookmark is saved.
#' @param options A list of settings to persist; serialized to JSON via
#'   \code{jsonlite::toJSON(options, auto_unbox = TRUE)} before saving.
#'
#' @return \code{TRUE} (invisibly) if the save succeeded, or \code{FALSE}
#'   (invisibly) if the username was missing or the database operation
#'   failed. Failures are logged with \code{message()} rather than raised.
#'
#' @examples
#' \dontrun{
#' dust_save_bookmark(postgres_con, "HCAI", uname, "identifier", list(org = "all"))
#' }
dust_save_bookmark <- function(postgres_con, app_name, uname, name, options){

  if(!isS4(postgres_con)){
    return(invisible(FALSE))
  }

  # convert options list to json string
  json_struct <- jsonlite::toJSON(options, auto_unbox = TRUE)

  if(is.null(uname) || uname == ""){
    message("Unable to save bookmark: no username found on session request headers.")
    return(invisible(FALSE))
  }

  result <- tryCatch({
    dbExecute(
      con = postgres_con,
      glue::glue_sql(
        "INSERT INTO public.user_settings (app_name, username, s_key, settings, last_updated)
         VALUES ({app_name}, {uname}, {name}, {json_struct}, NOW())
         ON CONFLICT (app_name, username, s_key)
         DO UPDATE SET settings = EXCLUDED.settings, last_updated = NOW()",
        .con = postgres_con
      )
    )
    TRUE
  }, error = function(e){
    message(paste0("Error during DUST bookmark upsert: ", e$message))
    FALSE
  })

  invisible(result)
}
