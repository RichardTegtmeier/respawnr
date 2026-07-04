\name{insert_respawn}
\alias{insert_respawn}
\title{Insert a respawn marker in the active RStudio document}
\usage{
insert_respawn(name = NULL)
}
\arguments{
\item{name}{Marker name. When omitted, RStudio prompts for one.}
}
\value{
Invisibly returns the inserted marker text.
}
\description{
Inserts a \code{# respawnr: name} comment at the current cursor position.
}
