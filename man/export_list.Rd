% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/export_list.R
\name{export_list}
\alias{export_list}
\title{Export List of \code{data.frame}s/\code{data.table}s with Advanced Directory Management}
\usage{
export_list(split_dt, export_path = tempdir(), file_type = "txt")
}
\arguments{
\item{split_dt}{A \code{list} of \code{data.frame}s, \code{data.table}s, or compatible data structures
to be exported.}

\item{export_path}{Base directory path for file export. Defaults to a temporary directory
created by \code{tempdir()}.}

\item{file_type}{File export format, either \code{"txt"} (tab-separated) or \code{"csv"}.
Defaults to \code{"txt"}.}
}
\value{
An \code{integer} representing the total number of files exported successfully.
}
\description{
Exports a list of \code{data.frame}s, \code{data.table}s, or compatible data structures
with sophisticated directory handling, flexible naming, and multiple file format support.
}
\details{
Comprehensive List Export Features:
\itemize{
\item Advanced nested directory structure support based on list element names
\item Intelligent handling of unnamed list elements
\item Automatic conversion to \code{data.table} for consistent export
\item Hierarchical directory creation with nested path names
\item Multi-format file export with intelligent separator selection
\item Robust error handling and input validation
}

Naming and Directory Creation Strategy:
\enumerate{
\item Unnamed list elements automatically assigned default names (e.g., \code{"split_1"})
\item Nested path names (containing \code{"/"}) dynamically create corresponding subdirectories
\item Automatic generation of required export directories
}

Data Conversion and Processing Characteristics:
\enumerate{
\item Automatic conversion to \code{data.table} for consistent processing
\item Preservation of original data structure during export
\item Flexible support for various input data types
}

File Export Capabilities:
\itemize{
\item Supports \code{"txt"} (tab-separated) and \code{"csv"} formats
\item Intelligent file naming based on list element names
\item Handles complex nested directory structures
\item Efficient file writing using \code{data.table::fwrite()}
}
}
\note{
Key Capabilities:
\itemize{
\item Flexible list naming and directory management
\item Comprehensive support for \code{data.frame} and \code{data.table} inputs
\item Intelligent default naming for unnamed elements
\item High-performance file writing mechanism
}
}
\examples{
# Data Nesting Operation
dt_split <- w2l_split(data = iris, cols2l = 1:2, by = "Species")
# Export Nested Data
export_list(split_dt = dt_split)
# Check Export Results
files <- list.files(path = tempdir(), pattern = "txt", recursive = TRUE, full.names = TRUE)
files
file.remove(files)
}
