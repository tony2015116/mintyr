% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/top_perc.R
\name{top_perc}
\alias{top_perc}
\title{Select Top Percentage of Data and Compute Summary Statistics}
\usage{
top_perc(data, perc, trait, by = NULL, type = "mean_sd", keep_data = FALSE)
}
\arguments{
\item{data}{data.frame. The input data frame.}

\item{perc}{numeric vector. A vector of percentages to select the top data. Each element should be a numeric value between -1 and 1.}

\item{trait}{character. The name of the column in \code{data} on which to base the selection.}

\item{by}{character vector, optional. The names of the columns to group by. Default is NULL.}

\item{type}{type of summary statistics. Possible values include: \code{"full",
"common", "robust",  "five_number", "mean_sd", "mean_se", "mean_ci",
"median_iqr", "median_mad", "quantile", "mean", "median",  "min", "max"}}

\item{keep_data}{logical, optional. If TRUE, the function returns both the summary statistics and the selected top data. Default is FALSE.}
}
\value{
A list or data frame:
\itemize{
\item If \code{keep_data} is FALSE, a data frame with summary statistics.
\item If \code{keep_data} is TRUE, a list where each element is a list containing summary statistics (\code{stat}) and the selected top data (\code{data}).
}
}
\description{
The \code{top_perc} function selects the top percentage of data based on a specified trait and computes summary statistics.
It allows for grouping by additional columns and offers flexibility in the type of statistics calculated.
The function can also retain the selected data if needed.
}
\note{
\itemize{
\item The \code{perc} parameter accepts values between -1 and 1. Positive values select the top percentage, while negative values select the bottom percentage.
\item The function performs initial checks to ensure required arguments are provided and valid.
\item Grouping by additional columns (\code{by}) is optional and allows for more granular analysis.
\item The \code{type} parameter specifies the type of summary statistics to compute, with "mean_sd" as the default.
\item If \code{keep_data} is set to TRUE, the function will return both the summary statistics and the selected top data for each percentage.
}
}
\examples{
top_perc(iris, perc = 0.5, trait = "Petal.Width", by = "Species")
}
