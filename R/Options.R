#' @title
#' Class for Package Options
#'
#' @description
#' This class holds public fields that represent the package
#' [`options`][base::options()] used to configure the default behavior of the
#' functionality [`powerly::powerly`] provides.
#'
#' @details
#' An instance of this class is automatically created and stored in the session
#' [`base::.Options`] at load time. This instance can be accessed and changed
#' via [`getOption("powerly")`][base::getOption()]. Specific package
#' [`options`][base::options()] can be retrieved using the helper function
#' [powerly::get_option()].
#'
#' @examples
#' # Set the default package options (i.e., automatically set at load time).
#' set_default_options()
#'
#' # ...
#'
#' # Restore the defaults.
#' set_default_options()
#'
#' @seealso [powerly::get_option()], [powerly::set_option()], and
#' [powerly::set_default_options()].
#'
#' @export
Options <- R6::R6Class("Options",
    cloneable = FALSE,

    public = list(
        #' @field verbose A logical value indicating whether progress messages
        # are printed to the console. The default value is `TRUE`.
        verbose = TRUE
    )
)
