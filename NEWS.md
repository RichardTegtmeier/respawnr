# respawnr 0.1.0

Initial GitHub release.

- Adds RStudio addins for marker insertion and marker navigation.
- Supports marker comments using `# respawnr: name` and `# @respawn name`.
- Adds a dropdown marker picker ordered by line number.
- Marks the last marker selected from the dropdown with a red dot.
- Adds `last_selected_respawn()` for returning to the last marker chosen from
  the dropdown.
- Adds next/previous marker navigation with wraparound.
