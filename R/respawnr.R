#' Find respawn markers in text
#'
#' Respawn markers are regular comments using either `# respawnr: name` or
#' `# @respawn name`. Marker names should be unique within a script.
#'
#' @param text Character vector containing script lines.
#' @param pattern Regular expression used to identify marker comments. The first
#'   capture group is used as the marker name.
#'
#' @return A data frame with `name`, `line`, and `text` columns.
#' @export
find_respawns <- function(
    text,
    pattern = default_marker_pattern()) {
  stopifnot(is.character(text))

  matches <- regexec(pattern, text, perl = TRUE)
  captures <- regmatches(text, matches)
  marker_lines <- which(lengths(captures) > 1)

  if (!length(marker_lines)) {
    return(data.frame(
      name = character(),
      line = integer(),
      text = character(),
      stringsAsFactors = FALSE
    ))
  }

  names <- vapply(captures[marker_lines], function(match) trimws(match[[2]]), character(1))
  data.frame(
    name = names,
    line = marker_lines,
    text = text[marker_lines],
    stringsAsFactors = FALSE
  )
}

default_marker_pattern <- function() {
  getOption("respawnr.marker_pattern", "^\\s*#\\s*(?:respawnr|@respawn)\\s*:?\\s*(.+?)\\s*$")
}

respawnr_state <- new.env(parent = emptyenv())
respawnr_state$last_selected_marker <- NULL

#' Insert a respawn marker in the active RStudio document
#'
#' @param name Marker name. When omitted, RStudio prompts for one.
#'
#' @return Invisibly returns the inserted marker text.
#' @export
insert_respawn <- function(name = NULL) {
  ensure_rstudio()

  if (is.null(name) || !nzchar(trimws(name))) {
    name <- rstudioapi::showPrompt(
      title = "Insert Respawn Marker",
      message = "Marker name",
      default = default_marker_name()
    )
  }

  if (is.null(name) || !nzchar(trimws(name))) {
    return(invisible(NULL))
  }

  marker <- paste0("# respawnr: ", trimws(name))
  context <- rstudioapi::getActiveDocumentContext()
  position <- context$selection[[1]]$range$start
  range <- rstudioapi::document_range(position, position)

  rstudioapi::insertText(range, paste0(marker, "\n"))
  invisible(marker)
}

#' List respawn markers in the active RStudio document
#'
#' @return A data frame of markers.
#' @export
list_respawns <- function() {
  markers <- active_markers()

  if (!nrow(markers)) {
    message("No respawn markers found in the active document.")
    return(invisible(markers))
  }

  print(markers[, c("name", "line")], row.names = FALSE)
  invisible(markers)
}

#' Jump to a respawn marker
#'
#' @param name Marker name. When omitted, RStudio shows a dropdown of markers
#'   ordered by line number. Partial names are accepted when `name` is supplied
#'   directly and matches exactly one marker.
#'
#' @return Invisibly returns the selected marker row.
#' @export
jump_respawn <- function(name = NULL) {
  ensure_rstudio()
  markers <- active_markers()

  if (!nrow(markers)) {
    rstudioapi::showDialog("respawnr", "No respawn markers found in the active document.")
    return(invisible(NULL))
  }

  if (is.null(name) || !nzchar(trimws(name))) {
    selected <- choose_marker(markers)
    if (!is.null(selected)) {
      record_last_selected_marker(selected)
    }
  } else {
    selected <- match_marker(markers, name)
    if (nrow(selected) != 1) {
      rstudioapi::showDialog(
        "respawnr",
        paste0("No unique marker matches '", name, "'. Use List Respawn Markers to inspect available markers.")
      )
      return(invisible(NULL))
    }
  }

  if (is.null(selected)) {
    return(invisible(NULL))
  }

  navigate_to_line(selected$line[[1]])
  invisible(selected)
}

#' Jump to the next respawn marker
#'
#' @return Invisibly returns the selected marker row.
#' @export
next_respawn <- function() {
  jump_relative_marker(direction = 1)
}

#' Jump to the previous respawn marker
#'
#' @return Invisibly returns the selected marker row.
#' @export
previous_respawn <- function() {
  jump_relative_marker(direction = -1)
}

#' Jump to the last marker selected from the dropdown
#'
#' @return Invisibly returns the selected marker row.
#' @export
last_selected_respawn <- function() {
  ensure_rstudio()
  marker <- respawnr_state$last_selected_marker

  if (is.null(marker)) {
    rstudioapi::showDialog("respawnr", "No dropdown-selected respawn marker has been recorded yet.")
    return(invisible(NULL))
  }

  selected <- resolve_last_selected_marker(active_markers(), marker)
  if (is.null(selected)) {
    rstudioapi::showDialog("respawnr", "The last dropdown-selected respawn marker was not found in the active document.")
    return(invisible(NULL))
  }

  navigate_to_line(selected$line[[1]])
  invisible(selected)
}

active_markers <- function() {
  ensure_rstudio()
  context <- rstudioapi::getActiveDocumentContext()
  order_markers(find_respawns(context$contents))
}

current_position <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  context$selection[[1]]$range$start
}

current_line <- function() {
  current_position()[["row"]]
}

jump_relative_marker <- function(direction) {
  ensure_rstudio()
  markers <- active_markers()

  if (!nrow(markers)) {
    rstudioapi::showDialog("respawnr", "No respawn markers found in the active document.")
    return(invisible(NULL))
  }

  line <- current_line()
  if (direction > 0) {
    candidates <- which(markers$line > line)
    if (length(candidates)) {
      index <- candidates[[1]]
    } else {
      index <- 1
    }
  } else {
    candidates <- which(markers$line < line)
    if (length(candidates)) {
      index <- candidates[[length(candidates)]]
    } else {
      index <- nrow(markers)
    }
  }

  selected <- markers[index, , drop = FALSE]
  navigate_to_line(selected$line[[1]])
  invisible(selected)
}

match_marker <- function(markers, name) {
  needle <- tolower(trimws(name))
  exact <- tolower(markers$name) == needle

  if (sum(exact) == 1) {
    return(markers[exact, , drop = FALSE])
  }

  partial <- startsWith(tolower(markers$name), needle)
  markers[partial, , drop = FALSE]
}

choose_marker <- function(markers) {
  ensure_gadget_packages()
  markers <- order_markers(markers)
  selected_index <- default_marker_index(markers, current_line())
  choices <- marker_choices(markers)

  ui <- miniUI::miniPage(
    shiny::tags$head(
      shiny::tags$style(shiny::HTML(
        ".selectize-dropdown-content { max-height: 260px; }"
      ))
    ),
    miniUI::gadgetTitleBar("Jump to Respawn Marker"),
    miniUI::miniContentPanel(
      shiny::selectInput(
        inputId = "marker",
        label = NULL,
        choices = choices,
        selected = as.character(selected_index),
        width = "100%",
        selectize = TRUE
      )
    )
  )

  server <- function(input, output, session) {
    shiny::observeEvent(input$done, {
      shiny::stopApp(as.integer(input$marker))
    })

    shiny::observeEvent(input$cancel, {
      shiny::stopApp(NULL)
    })
  }

  index <- shiny::runGadget(
    app = ui,
    server = server,
    viewer = shiny::dialogViewer("Jump to Respawn Marker", width = 420, height = 220)
  )

  if (is.null(index)) {
    return(invisible(NULL))
  }

  markers[index, , drop = FALSE]
}

order_markers <- function(markers) {
  if (!nrow(markers)) {
    return(markers)
  }

  markers[order(markers$line), , drop = FALSE]
}

marker_choices <- function(markers) {
  labels <- sprintf("%s - %s", markers$line, markers$name)
  selected <- last_selected_index(markers)

  if (!is.na(selected)) {
    labels[[selected]] <- paste0("\U0001F534 ", labels[[selected]])
  }

  stats::setNames(as.character(seq_len(nrow(markers))), labels)
}

default_marker_index <- function(markers, line) {
  next_marker <- which(markers$line >= line)
  if (length(next_marker)) {
    return(next_marker[[1]])
  }

  1L
}

navigate_to_line <- function(line) {
  position <- rstudioapi::document_position(line, 1)
  navigate_to_position(position)
}

navigate_to_position <- function(position) {
  range <- rstudioapi::document_range(position, position)
  rstudioapi::setSelectionRanges(list(range))
}

record_last_selected_marker <- function(marker) {
  respawnr_state$last_selected_marker <- list(
    name = marker$name[[1]],
    line = marker$line[[1]]
  )
}

last_selected_index <- function(markers, marker = respawnr_state$last_selected_marker) {
  if (is.null(marker) || !nrow(markers)) {
    return(NA_integer_)
  }

  exact <- which(markers$name == marker$name & markers$line == marker$line)
  if (length(exact)) {
    return(exact[[1]])
  }

  same_name <- which(markers$name == marker$name)
  if (length(same_name) == 1) {
    return(same_name[[1]])
  }

  NA_integer_
}

resolve_last_selected_marker <- function(markers, marker) {
  index <- last_selected_index(markers, marker)
  if (is.na(index)) {
    return(NULL)
  }

  markers[index, , drop = FALSE]
}

ensure_rstudio <- function() {
  if (!requireNamespace("rstudioapi", quietly = TRUE)) {
    stop("respawnr requires the rstudioapi package. Install it with install.packages(\"rstudioapi\").", call. = FALSE)
  }

  if (!rstudioapi::isAvailable()) {
    stop("respawnr requires RStudio for editor navigation.", call. = FALSE)
  }
}

ensure_gadget_packages <- function() {
  missing <- c(
    if (!requireNamespace("shiny", quietly = TRUE)) "shiny",
    if (!requireNamespace("miniUI", quietly = TRUE)) "miniUI"
  )

  if (length(missing)) {
    stop(
      "respawnr's dropdown marker picker requires: ",
      paste(missing, collapse = ", "),
      ". Install missing packages with install.packages().",
      call. = FALSE
    )
  }
}

default_marker_name <- function() {
  paste0("marker-", format(Sys.time(), "%H%M%S"))
}
