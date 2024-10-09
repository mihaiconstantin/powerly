#' @include ModelService.R ModelImplementation.R

#' @title
#' RuntimeModel
#'
#' @description
#' This class is a concrete implementation of the [`powerly::ModelService`]
#' interface. It is used to dynamically create model implementations at runtime
#' that can be used to specify true model parameters, generate data, estimate
#' model parameters, and evaluate the estimated model parameters (i.e, by
#' computing performance measures of interest). The runtime model is dispatching
#' method calls to a [`powerly::ModelImplementation`] instance.
#'
#' @seealso
#' [`powerly::ModelService`], [`powerly::ModelImplementation`],
#' [`powerly::ModelCreator`], and [`powerly::FunctionModelCreator`].
#'
#' @export
RuntimeModel <- R6::R6Class("RuntimeModel",
    inherit = ModelService,

    private = list(
        # The model implementation instance.
        .implementation = NULL
    ),

    public = list(
        #' @description
        #' Create a new [`powerly::RuntimeModel`] object.
        #'
        #' @return
        #' An object of class [`powerly::RuntimeModel`].
        initialize = function() { invisible() },

        #' @description
        #' Set the [`powerly::ModelImplementation`] instance to be used by the
        #' [`powerly::RuntimeModel`] object.
        #'
        #' @param implementation An object of class
        #' [`powerly::ModelImplementation`].
        #'
        #' @return
        #' This method returns void.
        set_implementation = function(implementation) {
            private$.implementation <- implementation
        },

        #' @description
        #' Specify the true (i.e., population) model parameters. The output of
        #' this method is used as input for the `generate` and `evaluate`
        #' methods.
        #'
        #' @param ... Optional arguments passed from the global environment for
        #' creating a true model specification (i.e., the true model
        #' parameters).
        #'
        #' @return
        #' A list of variable length, containing the results of the model
        #' specification logic.
        specify = function(...) {
            private$.implementation$specify(...)
        },

        #' @description
        #' Generate a sample (i.e., data) from the true model specification.
        #'
        #' @param specification A list of variable length, representing the
        #' output of the `specify` method.
        #'
        #' @param ... Optional arguments passed from the global environment for
        #' generating a sample based on the true model specification.
        #'
        #' @return
        #' A list of variable length, containing the generated sample.
        generate = function(specification, ...) {
            private$.implementation$generate(specification, ...)
        },

        #' @description
        #' Estimate the model parameters from the generated sample. The output
        #' of this method serves as part of the input for the `evaluate` method.
        #'
        #' @param generation A list of variable length, representing the output
        #' of the `generate` method.
        #'
        #' @param ... Optional arguments passed from the global environment for
        #' estimating the model parameters.
        #'
        #' @return
        #' A list of variable length, containing the estimated model parameters.
        #' The output of this method serves as part of the input for the
        #' `evaluate` method.
        estimate = function(generation, ...) {
            private$.implementation$estimate(generation, ...)
        },

        #' Compute a performance measure of interest by comparing the true model
        #' parameters with the estimated model parameters.
        #'
        #' @param specification A list of variable length, representing the
        #' output of the `specify` method.
        #'
        #' @param estimation A list of variable length, representing the output
        #' of the `estimate` method.
        #'
        #' @param ... Optional arguments passed from the global environment for
        #' computing the performance measure.
        #'
        #' @return A list of variable length, containing the performance measure
        #' of interest.
        evaluate = function(specification, estimation, ...) {
            private$.implementation$evaluate(specification, estimation, ...)
        }
    ),

    active = list(
        #' @field implementation The [`powerly::ModelImplementation`] instance.
        implementation = function() { return(private$.implementation) }
    )
)
