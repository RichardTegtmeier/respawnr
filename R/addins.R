pick_marker <- function() {
  markers <- find_markers()

  if (nrow(markers) == 0) {
    rstudioapi::showDialog("respawnr", "No markers found.")
    return(invisible())
  }

  choice <- utils::select.list(
    choices = markers$name,
    title = "Jump to respawn marker",
    graphics = FALSE
  )

  if (nzchar(choice)) {
    jump_to_marker(choice)
  }
}
