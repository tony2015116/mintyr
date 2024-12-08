# WARNING - Generated by {fusen} from dev/flat_teaching.Rmd: do not edit by hand

#' Get path to mintyr examples
#' 
#' mintyr comes bundled with a number of sample files in
#' its `inst/extdata` directory. Use `mintyr_example()` to retrieve the path to one
#' example.
#' 
#' @param path Name of file.
#' @seealso [mintyr::mintyr_examples()]
#' @export
#' @examples
#' mintyr_example("csv_test1.csv")
mintyr_example <- function(path) {
  # Call system.file with validated parameters
  system.file("extdata", path, package = "mintyr", mustWork = TRUE)
}
