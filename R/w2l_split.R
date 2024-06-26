# WARNING - Generated by {fusen} from dev/flat_teaching.Rmd: do not edit by hand

#' Convert Wide Data to Long Format and Split into List of Data Tables
#' 
#' The `w2l_split` function reshapes wide-format data to long-format and splits it into a list of data tables,
#' each corresponding to one of the specified columns.
#' 
#' @param data data.frame or data.table. The input data in wide format.
#' @param cols2l numeric or character vector. Specifies the columns to reshape from wide to long format. Can be either numeric indices or column names.
#'
#' @return A list of data tables. Each data table in the list corresponds to one of the specified columns, reshaped into long format.
#' 
#' @import data.table
#' 
#' @export
#' 
#' @note
#' \itemize{
#'   \item The `cols2l` parameter should be either numeric indices or a character vector of column names.
#'   \item Ensure all specified columns in `cols2l` are present in the data.
#'   \item The function converts `data.frame` to `data.table` if necessary.
#' }
#' @examples
#' w2l_split(data = iris, cols2l = 1:3)
#' w2l_split(data = iris, cols2l = c("Sepal.Length", "Sepal.Width"))
w2l_split <- function(data, cols2l) {
  # Validate that data is present and either a data.frame or data.table
  if (missing(data)) stop("data parameter is missing")

  if (is.data.frame(data)) {
    data <- as.data.table(data)  # Convert data.frame to data.table
  } else if (!is.data.table(data)) {
    stop("data must be a data.table or data.frame")
  }

  # Validate that cols2l is provided and of correct type and values
  if (missing(cols2l)) stop("cols2l parameter is missing")

  if (is.numeric(cols2l)) {
    if (any(length(cols2l) < 1 | length(cols2l) > ncol(data))) {
      stop("Numeric indices in cols2l are out of bounds.")  # Check bounds for numeric indices
    }
  } else if (is.character(cols2l)) {
    if (!all(cols2l %in% names(data))) {
      stop("Some columns specified in cols2l are not present in the data.")  # Check existence for character names
    }
  } else {
    stop("cols2l should be either numeric indices or character vector of column names.")  # Enforce type restrictions
  }

  # Convert the data from wide format to long format
  dt_long <- melt(data, measure.vars = cols2l, variable.name = "variable", value.name = "value")

  # Split the long-format data table into a list of data tables, grouped by the 'variable' column
  dt_list <- split(dt_long, dt_long$variable, drop = TRUE)

  # Return the list of data.tables
  return(dt_list)
}
