jump_to_marker <- function(name, offset = 5) {
  name <- trimws(name)

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
