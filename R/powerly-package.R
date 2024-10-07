# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                            _            #
#                                           | |           #
#   _ __     ___   __      __   ___   _ __  | |  _   _    #
#  | '_ \   / _ \  \ \ /\ / /  / _ \ | '__| | | | | | |   #
#  | |_) | | (_) |  \ V  V /  |  __/ | |    | | | |_| |   #
#  | .__/   \___/    \_/\_/    \___| |_|    |_|  \__, |   #
#  | |                                            __/ |   #
#  |_|                                           |___/    #
#                                                         #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Author: Mihai A. Constantin                             #
# Contact: mihai@mihaiconstantin.com                      #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Imports.
#' @importFrom parabar BackendFactory ContextFactory BarFactory Specification
#' @importFrom R6 R6Class


#' @include powerly-logo.R

#' @title
#' Sample Size Analysis Framework
#'
#' @description
#' ...
#'
#' @details
#' ...
#'
#' @aliases powerly-package
#'
#' @keywords internal
"_PACKAGE"


# On package load.
.onLoad <- function(libname, pkgname) {
    # Set package options.
    set_default_options()
}


# On package attach or load.
.onAttach <- function(libname, pkgname) {
    # Only show the logo if this is a human-handled session.
    if(interactive()) {
        # Print the logo.
        packageStartupMessage(LOGO)
    }
}


# On package unload.
.onUnload <- function(libpath) {
    # Remove package options.
    options(powerly = NULL)
}
