# WARNING - Generated by {fusen} from dev/flat_teaching.Rmd: do not edit by hand

#' Reshape Wide Data to Long Format and Nest by Specified Columns
#' 
#' @description
#' The `w2l_nest` function reshapes wide-format data into long-format and nests it by specified columns.
#' It handles both `data.frame` and `data.table` objects and provides options for grouping and nesting the data.
#' 
#' @param data A `data.frame` or `data.table`. The input data in wide format.
#' @param cols2l A numeric or character vector. Specifies the columns to reshape from wide to long format.
#'   Can be either numeric indices or column names.
#' @param by An optional character vector. Specifies the columns to group by. Default is `NULL`.
#' @param nest_type A character string, either `"dt"` or `"df"`. Specifies the type of object to nest in the
#'   result: `"dt"` for `data.table`, `"df"` for `data.frame`. Default is `"dt"`.
#'
#' @return A `data.table` with nested data in long format, grouped by specified columns if provided.
#' Each row contains a nested `data.table` or `data.frame` under the column `data`, depending on `nest_type`.
#' \itemize{
#'   \item If `by` is `NULL`, returns a `data.table` nested by `name`.
#'   \item If `by` is specified, returns a `data.table` nested by `name` and the grouping variables.
#' }
#' 
#' @details
#' The function performs the following key operations:
#' \enumerate{
#'   \item Melts the specified wide columns into long format
#'   \item Nests the resulting data by the `name` column
#'   \item Optionally groups by additional variables specified in `by`
#'   \item Allows flexible output format (`data.table` or `data.frame`)
#' }
#' 
#' Transformation Strategy:
#' \itemize{
#'   \item Converts input to `data.table` if necessary
#'   \item Validates input columns and grouping variables
#'   \item Reshapes data using `data.table::melt()`
#'   \item Nests data with flexible grouping options
#' }
#' 
#' @note
#' Important Considerations:
#' \itemize{
#'   \item The `cols2l` parameter should be either numeric indices or a character vector of column names present in `data`.
#'   \item Ensure all grouping variables specified in `by` are present in `data`.
#'   \item The function converts `data.frame` to `data.table` if necessary.
#'   \item The `nest_type` parameter controls whether nested data are `data.table` (`"dt"`) or `data.frame` (`"df"`) objects.
#'   \item If `nest_type` is not `"dt"` or `"df"`, the function will stop with an error.
#' }
#' 
#' @import data.table
#' @export
#' @examples
#' w2l_nest(data = iris, cols2l = 1:4)
#' w2l_nest(data = iris, cols2l = c("Sepal.Length", "Sepal.Width", "Petal.Length"), by = "Species")
w2l_nest <- function(data, cols2l, by = NULL, nest_type = "dt") {
  . <- name <- NULL

  # Ensure the data is a data.table object
  if (!data.table::is.data.table(data)) {
    if (is.data.frame(data)) {
      data <- data.table::as.data.table(data)  # Convert data.frame to data.table if necessary
    } else {
      stop("Data must be either a data.frame or a data.table.")  # Stop if data is not a data.table or data.frame
    }
  }

  # Process grouping variables
  if (!is.null(by)) {
    missing_by_vars <- by[!by %in% names(data)]
    if (length(missing_by_vars) > 0) {
      stop("Grouping variables not present in data: ", paste(missing_by_vars, collapse=", "))
    }
  }

  # Check the validity of cols2l based on its type
  if (is.numeric(cols2l)) {
    if (any(cols2l < 1 | cols2l > ncol(data))) {
      stop("Numeric indices in cols2l are out of bounds.")  # Corrected the condition
    }
  } else if (is.character(cols2l)) {
    if (!all(cols2l %in% names(data))) {
      missing_cols <- cols2l[!cols2l %in% names(data)]
      stop("Some columns specified in cols2l are not present in the data: ", paste(missing_cols, collapse=", "))
    }
  } else {
    stop("cols2l should be either numeric indices or character vector of column names.")  # Ensure cols2l is either numeric or character
  }

  # Melt the data
  #id_vars <- setdiff(names(data), cols2l)  # Use all other columns as id variables
  melted_data <- data.table::melt(
    data,
    #id.vars = id_vars,
    measure.vars = cols2l,
    variable.name = "name",
    value.name = "value"
  )  # Melt the data using specified cols2l

  # Determine grouping variables for nesting
  if (!is.null(by) && length(by) > 0) {
    groupby <- c("name", by)
  } else {
    groupby <- "name"
  }

  # # Nest the data based on nest_type
  if (nest_type == "dt") {
    result <- melted_data[, .(data = list(.SD)), by = groupby]
  } else if (nest_type == "df") {
    result <- melted_data[, .(data = list(as.data.frame(.SD))), by = groupby]
  } else {
    stop("Invalid nest_type provided. It must be either 'dt' or 'df'.")
  }

  # Return the result
  return(result)
}
