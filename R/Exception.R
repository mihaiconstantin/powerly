#' @include Helper.R

#' @title
#' Package Exceptions
#'
#' @description
#' This class contains static methods for throwing exceptions with informative
#' messages.
#'
#' @format
#' \describe{
#'   \item{\code{Exception$abstract_class_not_instantiable(object)}}{Exception for instantiating abstract classes or interfaces.}
#'   \item{\code{Exception$method_not_implemented()}}{Exception for calling methods without an implementation.}
#'   \item{\code{Exception$feature_not_developed()}}{Exception for running into things not yet developed.}
#'   \item{\code{Exception$type_not_assignable(actual, expected)}}{Exception for when providing incorrect object types.}
#'   \item{\code{Exception$unknown_package_option(option)}}{Exception for when requesting unknown package options.}
#' }
#'
#' @export
Exception <- R6::R6Class("Exception",
    cloneable = FALSE
)

# Exception for instantiating abstract classes or interfaces.
Exception$abstract_class_not_instantiable <- function(object) {
    if (missing(object)) {
        # Throw the error.
        stop("Abstract class cannot to be instantiated.", call. = FALSE)
    } else {
        # Construct exception message.
        message <- paste0("Abstract class '", Helper$get_class_name(object), "' cannot to be instantiated.")

        # Throw the error.
        stop(message, call. = FALSE)
    }
}

# Exception for calling methods without an implementation (i.e., lacking override).
Exception$method_not_implemented <- function() {
    # Throw the error.
    stop("Abstract method is not implemented.", call. = FALSE)
}

# Exception for running into things not yet developed.
Exception$feature_not_developed <- function() {
    # Throw the error.
    stop("Not supported. Please request at 'https://github.com/mihaiconstantin/powerly/issues'.", call. = FALSE)
}

# Exception for when providing incorrect object types.
Exception$type_not_assignable <- function(actual, expected) {
    # Construct exception message.
    message = paste0("Argument of type '", actual, "' is not assignable to parameter of type '", expected, "'.")

    # Throw the error.
    stop(message, call. = FALSE)
}

# Exception for when requesting unknown package options.
Exception$unknown_package_option <- function(option) {
    # Construct exception message.
    message = paste0("Unknown package option '", option, "'.")

    # Throw the error.
    stop(message, call. = FALSE)
}
