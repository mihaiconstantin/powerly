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
#' @importFrom R6 R6Class
#' @importFrom bootnet genGGM ggmGenerator
#' @importFrom qgraph EBICglasso
#' @importFrom quadprog solve.QP
#' @importFrom splines2 iSpline bSpline
#' @importFrom mvtnorm rmvnorm
#' @importFrom parabar get_option set_option configure_bar
#' @importFrom parabar start_backend stop_backend par_sapply par_apply

# Imports for plotting.
#' @importFrom ggplot2 theme_bw element_line geom_boxplot geom_density
#' @importFrom ggplot2 element_text geom_ribbon scale_fill_manual
#' @importFrom ggplot2 scale_alpha_manual element_rect geom_segment annotate
#' @importFrom ggplot2 coord_cartesian geom_line geom_text ggsave
#' @importFrom ggplot2 scale_x_continuous geom_histogram ggplot stat_ecdf
#' @importFrom ggplot2 geom_vline geom_hline geom_point aes scale_y_continuous
#' @importFrom ggplot2 labs theme margin
#' @importFrom rlang .data .env
#' @importFrom patchwork plot_layout

#' @include logo.R

#' @title
#' Sample Size Analysis for Psychological Networks and More
#'
#' @description
#' `powerly` is a package that implements the method by Constantin et al. (2023;
#' see \doi{10.1037/met0000555}) for conducting sample size analysis for network
#' models.
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
