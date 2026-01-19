# respawnr — complete functional core with robust marker detection
# Works in .R and .Rmd, hardened for real-world RStudio usage

find_markers <- function() {
  if (!rstudioapi::isAvailable()) {
    return(data.frame(name = character(), line = integer()))
  }

  ctx <- rstudioapi::getActiveDocumentContext()
  lines <- ctx$contents

  if (length(lines) == 0) {
    return(data.frame(name = character(), line = integer()))
  }

  in_chunk <- FALSE
  idx <- integer()

  for (i in seq_along(lines)) {
    line <- lines[i]

    # Detect start/end of R code chunks
    if (grepl("^```\\s*\\{r", line)) {
      in_chunk <- TRUE
      next
    }
    if (grepl("^```\\s*$", line)) {
      in_chunk <- FALSE
      next
    }

    if (in_chunk && grepl("@respawn", line, fixed = TRUE)) {
      idx <- c(idx, i)
    }
  }

  if (!length(idx)) {
    rstudioapi::showDialog(
      "respawnr",
      "No @respawn markers found in R code chunks.\nMarkers must be inside ```{r} chunks."
    )
    return(data.frame(name = character(), line = integer()))
  }

  names <- sub(".*@respawn\\s*", "", lines[idx])
  names <- trimws(names)

  data.frame(
    name = names,
    line = idx,
    stringsAsFactors = FALSE
  )
}

jump_to_marker <- function(name, offset = 5) {
  name <- trimws(name)
  markers <- find_markers()

  hit <- markers[markers$name == name, ]
  if (nrow(hit) == 0) {
    stop("Marker not found: ", name)
  }

  rstudioapi::setCursorPosition(
    rstudioapi::document_position(
      row = max(1, hit$line - offset),
      column = 1
    )
  )

  rstudioapi::setCursorPosition(
    rstudioapi::document_position(
      row = hit$line,
      column = 1
    )
  )
}

jump_next_marker <- function() {
  if (!rstudioapi::isAvailable()) return(invisible())

  ctx <- rstudioapi::getActiveDocumentContext()
  cursor <- ctx$selection[[1]]$range$start[["row"]] + 1
  markers <- find_markers()

  next_hit <- markers[markers$line > cursor, ]
  if (nrow(next_hit) == 0) return(invisible())

  rstudioapi::setCursorPosition(
    rstudioapi::document_position(
      row = next_hit$line[1],
      column = 1
    )
  )
}

jump_prev_marker <- function() {
  if (!rstudioapi::isAvailable()) return(invisible())

  ctx <- rstudioapi::getActiveDocumentContext()
  cursor <- ctx$selection[[1]]$range$start[["row"]] + 1
  markers <- find_markers()

  prev_hit <- markers[markers$line < cursor, ]
  if (nrow(prev_hit) == 0) return(invisible())

  rstudioapi::setCursorPosition(
    rstudioapi::document_position(
      row = tail(prev_hit$line, 1),
      column = 1
    )
  )
}

pick_marker <- function() {
  markers <- find_markers()
  if (nrow(markers) == 0) return(invisible())

  choice <- utils::select.list(
    seq_len(nrow(markers)),
    title = "Jump to respawn marker",
    labels = markers$name,
    graphics = FALSE
  )

  if (!nzchar(choice)) return(invisible())

  idx <- as.integer(choice)
  jump_to_marker(markers$name[idx])
}
