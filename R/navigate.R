#' @title Respawnr: Marker Navigation for RStudio
#' @description Improved navigation functions for .Rmd markers.

# Internal helper to find markers in the active document
# Looking for the pattern: # @respawn(name)
find_markers <- function() {
  ctx <- rstudioapi::getActiveDocumentContext()
  if (is.null(ctx)) return(data.frame(name = character(), line = integer()))
  
  contents <- ctx$contents
  # Regex allows for optional spaces and matches text inside parentheses
  pattern <- "#\\s?@respawn\\((.*?)\\)"
  matches <- grepl(pattern, contents)
  
  if (!any(matches)) {
    return(data.frame(name = character(), line = integer()))
  }
  
  lines <- which(matches)
  # Extract only the captured group (the name)
  names <- gsub(pattern, "\\1", contents[lines])
  
  data.frame(
    name = trimws(names),
    line = lines,
    stringsAsFactors = FALSE
  )
}

#' @export
jump_next_marker <- function() {
  ctx <- rstudioapi::getActiveDocumentContext()
  curr_line <- ctx$selection[[1]]$range$start[["row"]]
  markers <- find_markers()
  
  next_hit <- markers[markers$line > curr_line, ]
  
  if (nrow(next_hit) == 0) {
    message("No markers found below current position.")
    return(invisible())
  }
  
  rstudioapi::setCursorPosition(
    position = rstudioapi::document_position(row = next_hit$line[1], column = 1)
  )
}

#' @export
jump_prev_marker <- function() {
  ctx <- rstudioapi::getActiveDocumentContext()
  curr_line <- ctx$selection[[1]]$range$start[["row"]]
  markers <- find_markers()
  
  prev_hit <- markers[markers$line < curr_line, ]
  
  if (nrow(prev_hit) == 0) {
    message("No markers found above current position.")
    return(invisible())
  }
  
  # Jump to the last marker that is still above the cursor
  rstudioapi::setCursorPosition(
    position = rstudioapi::document_position(row = tail(prev_hit$line, 1), column = 1)
  )
}

#' @export
jump_to_marker_ui <- function() {
  markers <- find_markers()
  
  if (nrow(markers) == 0) {
    message("No markers found in this document. Use # @respawn(name) to create one.")
    return(invisible())
  }
  
  # Simple interactive selection list
  choice <- utils::select.list(
    choices = markers$name, 
    title = "Select Marker to 'Respawn' At",
    graphics = FALSE
  )
  
  if (choice != "") {
    target_line <- markers$line[markers$name == choice]
    rstudioapi::setCursorPosition(target_line[1], 1)
  }
}
