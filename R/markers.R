find_markers <- function() {
  ctx <- rstudioapi::getActiveDocumentContext()
  lines <- ctx$contents

  pattern <- "^\\s*#\\s*@respawn\\s+(.+)$"
  hits <- stringr::str_match(lines, pattern)
  idx <- which(!is.na(hits[, 2]))

  if (length(idx) == 0) {
    return(data.frame(name = character(), line = integer()))
  }

  data.frame(
    name = stringr::str_trim(hits[idx, 2]),
    line = idx,
    stringsAsFactors = FALSE
  )
}
