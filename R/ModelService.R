#' @include Exception.R

#' @title
#' ModelService
#'
#' @description
#' This is an interface that defines the operations a statistical model must
#' implement in order to be receive sample size analysis support. Models are
#' created and handled internally by the framework. For registering a new model
#' with the framework, please use the public `API` [`powerly::register_model`]
#' and [`powerly::validate_model`].
#'
#' @seealso
#' [`powerly::RuntimeModel`], [`powerly::ModelImplementation`],
#' [`powerly::ModelCreator`], [`powerly::FunctionModelCreator`],
#' [`powerly::register_model`], and [`powerly::validate_model`].
#'
#' @export
ModelService <- R6::R6Class("ModelService",
    public = list(
        #' @description
        #' Create a new [`powerly::ModelService`] object.
        #'
        #' @return
        #' Instantiating this class will throw an error.
        initialize = function() {
            Exception$abstract_class_not_instantiable(self)
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
            Exception$method_not_implemented()
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
            Exception$method_not_implemented()
        },

        #' @description
        #' Estimate the model parameters from the generated sample. The output
        #' of this method serves as part of the input for the `evaluate` method.
        #'
        #' @param generation A list of variable length, representing the output
        #' of the `generate` method.
        #'
        #' @param ... Optional arguments passed from the global environment
        #' required for estimating the model parameters.
        #'
        #' @return
        #' A list of variable length, containing the estimated model parameters.
        #' The output of this method serves as part of the input for the
        #' `evaluate` method.
        estimate = function(generation, ...) {
            Exception$method_not_implemented()
        },


        #' @description
        #' Compute a performance measure of interest by comparing the true model
        #' parameters with the estimated model parameters.
        #'
        #' @param specification A list of variable length, representing the
        #' output of the `specify` method.
        #'
        #' @param estimation A list of variable length, representing the output
        #' of the `estimate` method.
        #'
        #' @param ... Optional arguments passed from the global environment
        #' required for computing the performance measure.
        #'
        #' @return
        #' A list of variable length, containing the performance measure of
        #' interest.
        evaluate = function(specification, estimation, ...) {
            Exception$method_not_implemented()
        }
    )
)
