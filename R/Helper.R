#' @include Options.R

#' @title
#' Package Helpers
#'
#' @description
#' This class contains static helper methods.
#'
#' @format
#' \describe{
#'   \item{\code{Helper$get_class_name(object)}}{Helper for getting the class of a given object.}
#'   \item{\code{Helper$is_of_class(object, class)}}{Check if an object is of a certain class.}
#'   \item{\code{Helper$get_option(option)}}{Get package option, or corresponding default value.}
#'   \item{\code{Helper$set_option(option, value)}}{Set package option.}
#'   \item{\code{Helper$check_object_type(object, expected_type)}}{Check the type of a given object.}
#'   \item{\code{Helper$update_list(x, ...)}}{Append new arguments to a list or overwrite existing ones.}
#' }
#'
#' @export
Helper <- R6::R6Class("Helper",
    cloneable = FALSE
)

# Helper for getting the class of a given instance.
Helper$get_class_name <- function(object) {
    return(class(object)[1])
}

# Helper to check if object is of certain class.
Helper$is_of_class <- function(object, class) {
    return(class(object)[1] == class)
}

# Get package option, or corresponding default value.
Helper$get_option <- function(option) {
    # Get the `Options` instance from the global options, or create a new one.
    options <- getOption("powerly", default = Options$new())

    # If the requested option is unknown.
    if (!option %in% ls(options)) {
        # Throw an error.
        Exception$unknown_package_option(option)
    }

    # Return the value.
    return(options[[option]])
}

# Set package option.
Helper$set_option <- function(option, value) {
    # Get the `Options` instance from the global options, or create a new one.
    options <- getOption("powerly", default = Options$new())

    # If the requested option is unknown.
    if (!option %in% ls(options)) {
        # Throw an error.
        Exception$unknown_package_option(option)
    }

    # Set the value.
    options[[option]] <- value

    # Set the `Options` instance in the global options.
    options(powerly = options)
}

# Helper for performing a type check on a given object.
Helper$check_object_type <- function(object, expected_type) {
    # If the object does not inherit from the expected type.
    if (!inherits(object, expected_type)) {
        # Get object class name.
        type <- Helper$get_class_name(object)

        # Throw incorrect type error.
        Exception$type_not_assignable(type, expected_type)
    }
}

# Append new arguments to a list or overwrite existing ones.
Helper$update_list <- function(x, ...) {
    # Capture the new arguments as a list.
    new <- list(...)

    # If there are no new arguments.
    if (length(new) == 0) {
        # Return the original list.
        return(x)
    }

    # Extract the names of the new arguments.
    names_new <- names(new)

    # Check if any of the new argument names are empty.
    if (any(names_new == "")) {
        # Throw an error.
        Exception$unnamed_argument_not_allowed()
    }

    # Find the duplicate arguments.
    duplicates <- duplicated(names_new, fromLast = TRUE)

    # Check for duplicate argument names in the new arguments.
    if (any(duplicates)) {
        # Find the duplicate argument names.
        duplicate_names <- unique(names_new[duplicates])

        # Warn the user.
        Warning$duplicate_arguments(duplicate_names)

        # Keep only the last occurrence of each duplicate.
        new <- new[!duplicates]

        # Update the names of the new arguments.
        names_new <- names(new)
    }

    # Update existing arguments and add new ones.
    x[names_new] <- new

    # Return updated list.
    return(x)
}
