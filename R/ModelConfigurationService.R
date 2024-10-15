#' @include Exception.R

#' @title
#' ModelConfigurationService
#'
#' @description
#' This is an interface that defines the methods required for configuring
#' arguments passed to concrete model implementations of the
#' [`powerly::ModelService`] interface.
#'
#' @seealso
#' [`powerly::ModelConfiguration`] and [`powerly::ModelService`].
#'
#' @export
ModelConfigurationService <- R6::R6Class("ModelConfigurationService",
    public = list(
        #' @description
        #' Create a new [`powerly::ModelConfigurationService`] object.
        #'
        #' @return
        #' Instantiating this class will throw an error.
        initialize = function() {
            Exception$abstract_class_not_instantiable(self)
        },

        #' @description
        #' Configure the arguments for the `specify` operation.
        #'
        #' @param ... Arguments for the `specify` operation.
        #'
        #' @return
        #' This method returns void.
        configure_specify = function(...) {
            Exception$method_not_implemented()
        },

        #' @description
        #' Configure the arguments for the `generate` operation.
        #'
        #' @param ... Arguments for the `generate` operation.
        #'
        #' @return
        #' This method returns void.
        configure_generate = function(...) {
            Exception$method_not_implemented()
        },

        #' @description
        #' Configure the arguments for the `estimate` operation.
        #'
        #' @param ... Arguments for the `estimate` operation.
        #'
        #' @return
        #' This method returns void.
        configure_estimate = function(...) {
            Exception$method_not_implemented()
        },

        #' @description
        #' Configure the arguments for the `evaluate` operation.
        #'
        #' @param ... Arguments for the `evaluate` operation.
        #'
        #' @return
        #' This method returns void.
        configure_evaluate = function(...) {
            Exception$method_not_implemented()
        }
    )
)
