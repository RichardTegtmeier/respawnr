if (file.exists(file.path("R", "respawnr.R"))) {
  source(file.path("R", "respawnr.R"))
} else {
  library(respawnr)
}

internal <- function(name) {
  if (exists(name, envir = globalenv(), inherits = FALSE)) {
    return(get(name, envir = globalenv()))
  }

  getFromNamespace(name, "respawnr")
}

script <- c(
  "library(dplyr)",
  "# respawnr: imports",
  "x <- 1",
  "  # @respawn model-fit  ",
  "# ordinary comment"
)

markers <- find_respawns(script)
stopifnot(identical(markers$name, c("imports", "model-fit")))
stopifnot(identical(markers$line, c(2L, 4L)))

empty <- find_respawns(c("x <- 1", "# regular comment"))
stopifnot(identical(names(empty), c("name", "line", "text")))
stopifnot(nrow(empty) == 0L)

unordered <- data.frame(
  name = c("third", "first", "second"),
  line = c(30L, 10L, 20L),
  text = c("# respawnr: third", "# respawnr: first", "# respawnr: second")
)
ordered <- internal("order_markers")(unordered)
stopifnot(identical(ordered$name, c("first", "second", "third")))
stopifnot(identical(unname(internal("marker_choices")(ordered)), c("1", "2", "3")))

internal("record_last_selected_marker")(ordered[2, , drop = FALSE])
choices <- names(internal("marker_choices")(ordered))
stopifnot(grepl("\U0001F534", choices[[2]], fixed = TRUE))
