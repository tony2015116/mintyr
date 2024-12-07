# WARNING - Generated by {fusen} from dev/flat_teaching.Rmd: do not edit by hand

#' Advanced File Path Segment Extraction
#'
#' @description
#' A robust utility for precise segment extraction from file system paths
#' with flexible indexing and comprehensive error handling.
#'
#' @param paths A 'character vector' containing file system paths
#'   - Must be non-empty
#'   - Path segments separated by forward slash `'/'`
#'   - Supports absolute and relative paths
#'   - Handles complex path structures
#'
#' @param n Numeric index for segment selection
#'   - Positive values: Select from path start
#'   - Negative values: Select from path end
#'   - Cannot be `0`
#'   - Default is `1` (first segment)
#'
#' @details
#' Sophisticated Path Segment Extraction Mechanism:
#' \enumerate{
#'   \item Input validation and preprocessing
#'   \item Robust path segmentation
#'   \item Flexible indexing strategy
#'   \item Intelligent segment retrieval
#'   \item Graceful handling of edge cases
#' }
#'
#' Indexing Behavior:
#' \itemize{
#'   \item Positive `n`: Forward indexing from path start
#'     - `n = 1`: First segment
#'     - `n = 2`: Second segment
#'   \item Negative `n`: Reverse indexing from path end
#'     - `n = -1`: Last segment
#'     - `n = -2`: Second-to-last segment
#' }
#'
#' Path Parsing Characteristics:
#' \itemize{
#'   \item Ignores consecutive `'/'` delimiters
#'   \item Removes empty path segments
#'   \item Returns `NA_character_` for non-existent segments
#'   \item Supports complex path structures
#' }
#'
#' @return 'character vector' with extracted path segments
#'   - Matching segments for valid indices
#'   - `NA_character_` for segments beyond path length
#'
#' @note Critical Operational Constraints:
#' \itemize{
#'   \item Requires non-empty 'paths' input
#'   \item `n` must be non-zero integer
#'   \item Supports cross-platform path representations
#'   \item Minimal computational overhead
#' }
#'
#' @seealso
#' \itemize{
#'   \item [`base::strsplit()`] String splitting utility
#'   \item [`tools::file_path_sans_ext()`] File extension manipulation
#' }
#'
#' @export
#' @examples
#' # Example usage demonstrations
#' paths <- c("/home/user/documents", "/var/log/system", "/usr/local/bin")
#' # Positive index example
#' get_path_segment(paths, 2)
#' # Negative index example
#' get_path_segment(paths, -2)
get_path_segment <- function(paths, n = 1) {
  # Check if paths parameter is provided
  if (missing(paths)) stop("Parameter 'paths' cannot be empty")
  
  # Validate paths is a character vector
  if (!is.character(paths)) stop("'paths' must be character")
  
  # Return empty character vector if paths is empty
  if (length(paths) == 0) return(character(0))
  
  # Validate n is numeric
  if (!is.numeric(n)) stop("'n' must be numeric")
  
  # Prevent zero index
  if (n == 0) stop("'n' cannot be 0")
  
  # Split paths into segments and remove empty strings
  segments <- strsplit(paths, "/")
  segments <- lapply(segments, function(x) x[x != ""])
  
  # Extract specific path segments
  result <- sapply(segments, function(x) {
    if (n > 0) {
      # Positive index: count from the beginning
      # Return segment if index exists, otherwise return NA
      if (length(x) >= n) x[n] else NA_character_
    } else {
      # Negative index: count from the end
      # Convert negative index to positive position
      pos <- length(x) + n + 1
      
      # Return segment if position is valid, otherwise return NA
      if (pos > 0 && pos <= length(x)) x[pos] else NA_character_
    }
  })
  
  return(result)
}
