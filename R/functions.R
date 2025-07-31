

#' Get unique values
#'
#' Get number of unique values of a vector
#' 
#' @param x the vector
#' @param na.rm count instances of NA in x?
#'
#' @returns Number of unique values of x
#' @export
nodup <- function(x, na.rm = FALSE) {
  if (na.rm) {
    x2 <- na.omit(x)
  } else {
    x2 <- x
  }
  return(sum(!duplicated(x2)))
}
