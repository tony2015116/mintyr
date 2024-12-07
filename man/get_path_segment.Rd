% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_path_segment.R
\name{get_path_segment}
\alias{get_path_segment}
\title{Advanced File Path Segment Extraction}
\usage{
get_path_segment(paths, n = 1)
}
\arguments{
\item{paths}{A 'character vector' containing file system paths
\itemize{
\item Must be non-empty
\item Path segments separated by forward slash \code{'/'}
\item Supports absolute and relative paths
\item Handles complex path structures
}}

\item{n}{Numeric index for segment selection
\itemize{
\item Positive values: Select from path start
\item Negative values: Select from path end
\item Cannot be \code{0}
\item Default is \code{1} (first segment)
}}
}
\value{
'character vector' with extracted path segments
\itemize{
\item Matching segments for valid indices
\item \code{NA_character_} for segments beyond path length
}
}
\description{
A robust utility for precise segment extraction from file system paths
with flexible indexing and comprehensive error handling.
}
\details{
Sophisticated Path Segment Extraction Mechanism:
\enumerate{
\item Input validation and preprocessing
\item Robust path segmentation
\item Flexible indexing strategy
\item Intelligent segment retrieval
\item Graceful handling of edge cases
}

Indexing Behavior:
\itemize{
\item Positive \code{n}: Forward indexing from path start
- \code{n = 1}: First segment
- \code{n = 2}: Second segment
\item Negative \code{n}: Reverse indexing from path end
- \code{n = -1}: Last segment
- \code{n = -2}: Second-to-last segment
}

Path Parsing Characteristics:
\itemize{
\item Ignores consecutive \code{'/'} delimiters
\item Removes empty path segments
\item Returns \code{NA_character_} for non-existent segments
\item Supports complex path structures
}
}
\note{
Critical Operational Constraints:
\itemize{
\item Requires non-empty 'paths' input
\item \code{n} must be non-zero integer
\item Supports cross-platform path representations
\item Minimal computational overhead
}
}
\examples{
# Example usage demonstrations
paths <- c("/home/user/documents", "/var/log/system", "/usr/local/bin")
# Positive index example
get_path_segment(paths, 2)
# Negative index example
get_path_segment(paths, -2)
}
\seealso{
\itemize{
\item \code{\link[base:strsplit]{base::strsplit()}} String splitting utility
\item \code{\link[tools:fileutils]{tools::file_path_sans_ext()}} File extension manipulation
}
}
