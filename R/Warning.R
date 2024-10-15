#' @include Helper.R

#' @title
#' Package Warnings
#'
#' @description
#' This class contains static methods for throwing warnings with informative
#' messages.
#'
#' @format
#' \describe{
#'   \item{\code{Warning$duplicate_arguments(names)}}{Warning for providing duplicate arguments in the `...` construct.}
#' }
#'
#' @export
Warning <- R6::R6Class("Warning",
    cloneable = FALSE
)

# Warning for duplicate arguments in `...`.
Warning$duplicate_arguments <- function(names) {
    # Construct warning message.
    message = paste0(
        "Duplicate names detected for argument(s): ",
        paste0("'", names, "'", collapse = ", "), ". ",
        "Only the last occurrence(s) will be used."
    )

    # Display the warning.
    warning(message, call. = FALSE)
}
