% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/c2p_nest.R
\name{c2p_nest}
\alias{c2p_nest}
\title{Column to Pair Nested Transformation}
\usage{
c2p_nest(data, cols2bind, by = NULL, pairs_n = 2, sep = "-", nest_type = "dt")
}
\arguments{
\item{data}{Input \verb{data frame} or \verb{data table}
\itemize{
\item Must contain valid columns for transformation
\item Supports multiple data types
}}

\item{cols2bind}{Column specification for pair generation
\itemize{
\item Can be a \code{character} vector of column names
\item Can be a \code{numeric} vector of column indices
\item Must reference existing columns in the dataset
}}

\item{by}{Optional grouping specification
\itemize{
\item Can be a \code{character} vector of column names
\item Can be a \code{numeric} vector of column indices
\item Enables hierarchical nested transformations
\item Supports multi-level aggregation
\item Default is \code{NULL}
}}

\item{pairs_n}{\code{numeric} indicating combination size
\itemize{
\item Minimum value: 2
\item Maximum value: Length of \code{cols2bind}
\item Controls column pair complexity
\item Default is 2
}}

\item{sep}{\code{character} separator for pair naming
\itemize{
\item Used in generating combination identifiers
\item Must be a single character
\item Default is "-"
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
\item Includes \code{pairs} column identifying column combinations
\item Contains \code{data} column storing nested data structures
\item Supports optional grouping variables
}
}
\description{
A sophisticated data transformation tool for generating column pair combinations
and creating nested data structures with advanced configuration options.
}
\details{
Advanced Transformation Mechanism:
\enumerate{
\item Input validation and preprocessing
\item Dynamic column combination generation
\item Flexible pair transformation
\item Nested data structure creation
}

Transformation Process:
\itemize{
\item Validate input parameters and column specifications
\item Convert numeric indices to column names if necessary
\item Generate column combinations
\item Create subset data tables
\item Merge and nest transformed data
}

Column Specification:
\itemize{
\item Supports both column names and numeric indices
\item Numeric indices must be within valid range (1 to ncol)
\item Column names must exist in the dataset
\item Flexible specification for both cols2bind and by parameters
}
}
\note{
Key Operation Constraints:
\itemize{
\item Requires non-empty input data
\item Column specifications must be valid (either names or indices)
\item Supports flexible combination strategies
\item Computational complexity increases with combination size
}
}
\examples{
# Example data preparation: Define column names for combination
col_names <- c("Sepal.Length", "Sepal.Width", "Petal.Length")

# Example 1: Basic column-to-pairs nesting with custom separator
c2p_nest(
  iris,                   # Input iris dataset
  cols2bind = col_names,  # Columns to be combined as pairs
  pairs_n = 2,            # Create pairs of 2 columns
  sep = "&"               # Custom separator for pair names
)
# Returns a nested data.table where:
# - pairs: combined column names (e.g., "Sepal.Length&Sepal.Width")
# - data: list column containing data.tables with value1, value2 columns

# Example 2: Column-to-pairs nesting with numeric indices and grouping
c2p_nest(
  iris,                   # Input iris dataset
  cols2bind = 1:3,        # First 3 columns to be combined
  pairs_n = 2,            # Create pairs of 2 columns
  by = 5                  # Group by 5th column (Species)
)
# Returns a nested data.table where:
# - pairs: combined column names
# - Species: grouping variable
# - data: list column containing data.tables grouped by Species
}
\seealso{
\itemize{
\item \code{\link[utils:combn]{utils::combn()}} Combination generation
}
}
