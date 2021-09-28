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
#'@importFrom patchwork plot_layout

#' @include logo.R

#' @title
#' Sample Size Analysis for Psychological Networks and More
#'
#' @description
#' `powerly` is a package that implements the method by [Constantin et al.
#' (2021)](https://arxiv.org) for conducting sample size analysis for
#' network models.
#'
#' @details
#' The method implemented is implemented in the main function [powerly()]. The
#' implementation takes the form of a three-step recursive algorithm designed to
#' find an optimal sample size value given a model specification and an outcome
#' measure of interest. It starts with a Monte Carlo simulation step for
#' computing the outcome at various sample sizes. It continues with a monotone
#' curve-fitting step for interpolating the outcome. The final step employs
#' stratified bootstrapping to quantify the uncertainty around the fitted curve.
#'
#' @aliases powerly-package
#'
#' @keywords internal
"_PACKAGE"


# On package attach or load.
.onAttach <- function(libname, pkgname) {
    # Only show the logo if this is a human-handled session.
    if(interactive()) {
        # Print the logo.
        packageStartupMessage(LOGO)
    }
}
