% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/r2p_nest.R
\name{r2p_nest}
\alias{r2p_nest}
\title{Row to Pair Nested Transformation}
\usage{
r2p_nest(data, rows2bind, by, nest_type = "dt")
}
\arguments{
\item{data}{Input \verb{data frame} or \verb{data table}
\itemize{
\item Must contain valid columns for transformation
\item Supports multiple data types
}}

\item{rows2bind}{Row binding specification
\itemize{
\item Can be a \code{character} column name
\item Can be a \code{numeric} column index
\item Must be a single column identifier
}}

\item{by}{Grouping specification for nested pairing
\itemize{
\item Can be a \code{character} vector of column names
\item Can be a \code{numeric} vector of column indices
\item Must specify at least one column
\item Supports multi-column transformation
}}

\item{nest_type}{Output nesting format
\itemize{
\item \code{"dt"}: Returns nested \verb{data table} (default)
\item \code{"df"}: Returns nested \verb{data frame}
}}
}
\value{
\verb{data table} containing nested transformation results
\itemize{
\item Includes \code{name} column identifying source columns
\item Contains \code{data} column storing nested data structures
}
}
\description{
A sophisticated data transformation tool for performing row pair conversion
and creating nested data structures with advanced configuration options.
}
\details{
Advanced Transformation Mechanism:
\enumerate{
\item Input validation and preprocessing
\item Dynamic column identification
\item Flexible row pairing across specified columns
\item Nested data structure generation
}

Transformation Process:
\itemize{
\item Validate input parameters and column specifications
\item Convert numeric indices to column names if necessary
\item Reshape data from wide to long format
\item Perform column-wise nested transformation
\item Generate final nested structure
}

Column Specification:
\itemize{
\item Supports both column names and numeric indices
\item Numeric indices must be within valid range (1 to ncol)
\item Column names must exist in the dataset
\item Flexible specification for both rows2bind and by parameters
}
}
\note{
Key Operation Constraints:
\itemize{
\item Requires non-empty input data
\item Column specifications must be valid (either names or indices)
\item By parameter must specify at least one column
\item Low computational overhead
}
}
\examples{
# Example 1: Row-to-pairs nesting with column names
r2p_nest(
  mtcars,                     # Input mtcars dataset
  rows2bind = "cyl",          # Column to be used as row values
  by = c("hp", "drat", "wt")  # Columns to be transformed into pairs
)
# Returns a nested data.table where:
# - name: variable names (hp, drat, wt)
# - data: list column containing data.tables with rows grouped by cyl values

# Example 2: Row-to-pairs nesting with numeric indices
r2p_nest(
  mtcars,                     # Input mtcars dataset
  rows2bind = 2,              # Use 2nd column (cyl) as row values
  by = 4:6                    # Use columns 4-6 (hp, drat, wt) for pairs
)
# Returns a nested data.table where:
# - name: variable names from columns 4-6
# - data: list column containing data.tables with rows grouped by cyl values
}
\seealso{
\itemize{
\item \code{\link[data.table:melt.data.table]{data.table::melt()}} Long format conversion
\item \code{\link[data.table:dcast.data.table]{data.table::dcast()}} Wide format conversion
\item \code{\link[base:cbind]{base::rbind()}} Row binding utility
\item \code{\link[=c2p_nest]{c2p_nest()}} Column to pair nested transformation
}
}
