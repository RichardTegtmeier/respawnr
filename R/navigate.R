#' Find all markers in the active document
find_markers <- function() {
  ctx <- rstudioapi::getActiveDocumentContext()
  if (is.null(ctx)) return(data.frame(name = character(), line = integer()))
  
  contents <- ctx$contents
  pattern <- "#\\s?@respawn\\((.*?)\\)"
  matches <- grepl(pattern, contents)
  
  if (!any(matches)) return(data.frame(name = character(), line = integer()))
  
  lines <- which(matches)
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
  if (nrow(next_hit) == 0) return(invisible(message("No more markers.")))

  # Using simplest signature: setCursorPosition(position)
  pos <- rstudioapi::document_position(row = next_hit$line[1], column = 1)
  rstudioapi::setCursorPosition(pos)
}

#' @export
jump_prev_marker <- function() {
  ctx <- rstudioapi::getActiveDocumentContext()
  curr_line <- ctx$selection[[1]]$range$start[["row"]]
  markers <- find_markers()
  
  prev_hit <- markers[markers$line < curr_line, ]
  if (nrow(prev_hit) == 0) return(invisible(message("No markers above.")))

  pos <- rstudioapi::document_position(row = tail(prev_hit$line, 1), column = 1)
  rstudioapi::setCursorPosition(pos)
}

#' @export
jump_to_marker <- function() {
  markers <- find_markers()
  if (nrow(markers) == 0) return(invisible(message("No markers found.")))
  
  choice <- utils::select.list(markers$name, title = "Respawn At:")
  if (choice != "") {
    line <- markers$line[markers$name == choice][1]
    pos <- rstudioapi::document_position(row = line, column = 1)
    rstudioapi::setCursorPosition(pos)
  }
}
