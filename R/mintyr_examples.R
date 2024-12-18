# WARNING - Generated by {fusen} from dev/flat_teaching.Rmd: do not edit by hand

#' List all available example files in mintyr package
#' 
#' `mintyr` comes bundled with a number of sample files in its `inst/extdata` 
#' directory. This function lists all available example files, optionally filtered
#' by a pattern.
#' 
#' @param pattern A regular expression to filter filenames. If `NULL` (default),
#'   all available files are returned.
#' @return A character vector containing the names of example files. If no files
#'   match the pattern or if the example directory is empty, returns a zero-length
#'   character vector.
#' @seealso [mintyr::mintyr_example()] to get the full path of a specific example file
#' @export
#' @examples
#' # List all example files
#' mintyr_examples()
mintyr_examples <- function(pattern = NULL) {
  # Validate pattern if provided
  if (!is.null(pattern)) {
    if (!is.character(pattern)) {
      stop("'pattern' must be a character string or NULL", call. = FALSE)
    }
  }
  
  # Get the example directory path
  example_dir <- system.file("extdata", package = "mintyr")
  
  # Check if directory exists
  if (example_dir == "") {
    return(character(0))
  }
  
  # Get and return matching files
  list.files(example_dir, pattern = pattern)
}
