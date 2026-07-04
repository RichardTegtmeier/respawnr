\name{find_respawns}
\alias{find_respawns}
\title{Find respawn markers in text}
\usage{
find_respawns(text, pattern = default_marker_pattern())
}
\arguments{
\item{text}{Character vector containing script lines.}
\item{pattern}{Regular expression used to identify marker comments. The first capture group is used as the marker name.}
}
\value{
A data frame with \code{name}, \code{line}, and \code{text} columns.
}
\description{
Finds marker comments using either \code{# respawnr: name} or \code{# @respawn name}.
}
