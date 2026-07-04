\name{jump_respawn}
\alias{jump_respawn}
\title{Jump to a respawn marker}
\usage{
jump_respawn(name = NULL)
}
\arguments{
\item{name}{Marker name. When omitted, RStudio shows a dropdown of markers ordered by line number. Partial names are accepted when supplied directly and matching exactly one marker.}
}
\value{
Invisibly returns the selected marker row.
}
\description{
Moves the RStudio editor cursor to a selected respawn marker in the active document.
}
