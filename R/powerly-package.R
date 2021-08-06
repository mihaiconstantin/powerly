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

#' @include logo.R

#' \code{powerly}: Sample size analysis for complex models.
#'
#' @docType package
#' @name powerly
"_PACKAGE"

# On package attach or load.
.onAttach <- function(libname, pkgname) {
    # Print the logo.
    packageStartupMessage(LOGO)
}
