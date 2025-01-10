#' @title
#' ModelConfiguration
#'
#' @description
#' This class is an implementation of the [`powerly::ModelConfigurationService`]
#' interface that provides a way to configure the arguments for the `specify`,
#' `generate`, `estimate`, and `evaluate` operations defined by the
#' [`powerly::ModelService`] interface.
#'
#' @seealso
#' [`powerly::ModelConfigurationService`] and [`powerly::ModelService`].
#'
#' @export
ModelConfiguration <- R6::R6Class("ModelConfiguration",
    inherit = ModelConfigurationService,

    private = list(
        # Arguments for `specify`.
        .specify = list(),

        # Arguments for `generate`.
        .generate = list(),

        # Arguments for `estimate`.
        .estimate = list(),

        # Arguments for `evaluate`.
        .evaluate = list()
    ),

    public = list(
        #' @description
        #' Create a new [`powerly::ModelConfiguration`] object.
        #'
        #' @return
        #' An object of class [`powerly::ModelConfiguration`].
        initialize = function() { invisible() },

        #' @description
        #' Configure the arguments for the `specify` operation.
        #'
        #' @param ... Arguments for the `specify` operation.
        #'
        #' @return
        #' This method returns void. The updated list of arguments can be
        #' accessed via the `specify` field.
        configure_specify = function(...) {
            # Update the `specify` arguments.
            private$.specify <- Helper$update_list(private$.specify, ...)
        },

        #' @description
        #' Configure the arguments for the `generate` operation.
        #'
        #' @param ... Arguments for the `generate` operation.
        #'
        #' @return
        #' This method returns void. The updated list of arguments can be
        #' accessed via the `generate` field.
        configure_generate = function(...) {
            # Update the `generate` arguments.
            private$.generate <- Helper$update_list(private$.generate, ...)
        },

        #' @description
        #' Configure the arguments for the `estimate` operation.
        #'
        #' @param ... Arguments for the `estimate` operation.
        #'
        #' @return
        #' This method returns void. The updated list of arguments can be
        #' accessed via the `estimate` field.
        configure_estimate = function(...) {
            # Update the `estimate` arguments.
            private$.estimate <- Helper$update_list(private$.estimate, ...)
        },

        #' @description
        #' Configure the arguments for the `evaluate` operation.
        #'
        #' @param ... Arguments for the `evaluate` operation.
        #'
        #' @return
        #' This method returns void. The updated list of arguments can be
        #' accessed via the `evaluate` field.
        configure_evaluate = function(...) {
            # Update the `evaluate` arguments.
            private$.evaluate <- Helper$update_list(private$.evaluate, ...)
        }
    ),

    active = list(
        #' @field specify A list of arguments for the `specify` operation.
        specify = function() { return(private$.specify) },

        #' @field generate A list of arguments for the `generate` operation.
        generate = function() { return(private$.generate) },

        #' @field estimate A list of arguments for the `estimate` operation.
        estimate = function() { return(private$.estimate) },

        #' @field evaluate A list of arguments for the `evaluate` operation.
        evaluate = function() { return(private$.evaluate) }
    )
)
