jump_to_marker <- function(name, offset = 5) {
  markers <- find_markers()
  hit <- markers[markers$name == name, ]

  if (nrow(hit) == 0) {
    stop("Marker not found: ", name)
  }

  ctx <- rstudioapi::getActiveDocumentContext()

  rstudioapi::setCursorPosition(
    documentId = ctx$id,
    row = max(1, hit$line - offset),
    column = 1
  )

  rstudioapi::setCursorPosition(
    documentId = ctx$id,
    row = hit$line,
    column = 1
  )
}

jump_next_marker <- function() {
  ctx <- rstudioapi::getActiveDocumentContext()
  cursor <- ctx$selection[[1]]$range$start["row"] + 1
  markers <- find_markers()

  next_hit <- markers[markers$line > cursor, ]
  if (nrow(next_hit) == 0) return(invisible())

  rstudioapi::setCursorPosition(
    documentId = ctx$id,
    row = next_hit$line[1],
    column = 1
  )
}

jump_prev_marker <- function() {
  ctx <- rstudioapi::getActiveDocumentContext()
  cursor <- ctx$selection[[1]]$range$start["row"] + 1
  markers <- find_markers()

  prev_hit <- markers[markers$line < cursor, ]
  if (nrow(prev_hit) == 0) return(invisible())

  rstudioapi::setCursorPosition(
    documentId = ctx$id,
    row = tail(prev_hit$line, 1),
    column = 1
  )
}
