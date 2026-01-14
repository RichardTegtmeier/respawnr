pick_marker <- function() {
  markers <- find_markers()

  if (nrow(markers) == 0) {
    rstudioapi::showDialog("respawnr", "No markers found.")
    return(invisible())
  }

  choice <- rstudioapi::selectList(
    choices = markers$name,
    title = "Jump to respawn marker"
  )

  if (!is.null(choice)) {
    jump_to_marker(choice)
  }
}
