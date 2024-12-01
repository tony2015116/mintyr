% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/w2l_split.R
\name{w2l_split}
\alias{w2l_split}
\title{Reshape Wide Data to Long Format and Split into List}
\usage{
w2l_split(data, cols2l, by = NULL, split_type = "dt")
}
\arguments{
\item{data}{A \code{data.frame} or \code{data.table}. The input data in wide format.}

\item{cols2l}{A numeric or character vector. Specifies the columns to reshape from wide to long format.
Can be either numeric indices or column names.}

\item{by}{An optional character vector. Specifies additional columns to split by. Default is \code{NULL}.}

\item{split_type}{A character string, either \code{"dt"} or \code{"df"}. Specifies the type of objects in the
resulting list: \code{"dt"} for \code{data.table}, \code{"df"} for \code{data.frame}. Default is \code{"dt"}.}
}
\value{
A list of \code{data.table} or \code{data.frame} objects (depending on \code{split_type}), split by variable
names and optional grouping columns.
\itemize{
\item If \code{by} is \code{NULL}, returns a list split by variable names only.
\item If \code{by} is specified, returns a list split by both variable names and grouping variables.
}
}
\description{
The \code{w2l_split} function reshapes wide-format data into long-format and splits it into a list
by variable names and optional grouping columns. It handles both \code{data.frame} and \code{data.table} objects.
}
\details{
The function first melts the specified wide columns into long format and then splits the resulting data
into a list based on the variable names and any additional grouping variables specified in \code{by}.
The resulting list elements can be either \code{data.table} or \code{data.frame} objects, as specified by
the \code{split_type} parameter.
}
\note{
\itemize{
\item The \code{cols2l} parameter should be either numeric indices or a character vector of column names present in \code{data}.
\item Ensure all grouping variables specified in \code{by} are present in \code{data}.
\item The function automatically converts \code{data.frame} to \code{data.table} for processing.
\item The \code{split_type} parameter determines the class of objects in the resulting list.
\item Non-specified columns are automatically used as ID variables in the reshaping process.
}
}
\examples{
w2l_split(data = iris, cols2l = 1:3)
w2l_split(data = iris, cols2l = c("Sepal.Length", "Sepal.Width"))
}
