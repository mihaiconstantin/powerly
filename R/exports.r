#' @include Options.R Helper.R Exception.R

#' @export
set_default_options <- function() {
    # Set `Options` instance.
    options(powerly = Options$new())

    # Remain silent.
    invisible(NULL)
}


#' @export
get_option <- function(option) {
    # Invoke the helper.
    Helper$get_option(option)
}


#' @export
set_option <- function(option, value) {
    # Invoke the helper.
    Helper$set_option(option, value)

    # Remain silent.
    invisible()
}
