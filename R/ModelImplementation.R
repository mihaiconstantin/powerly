#' @title
#' ModelImplementation
#'
#' @description
#' An intermediary class that holds the implementation details for a statistical
#' model. This class is used internally by the framework to dynamically create
#' model implementations at runtime.
#'
#' @seealso
#' [`powerly::ModelService`], [`powerly::RuntimeModel`],
#' [`powerly::ModelCreator`], and [`powerly::FunctionModelCreator`].
#'
#' @export
ModelImplementation <- R6::R6Class("ModelImplementation",
    private = list(
        # The provided function for specifying the true model parameters.
        .specify = NULL,

        # The provided function for generating a sample from the true model.
        .generate = NULL,

        # The provided function for estimating the model parameters.
        .estimate = NULL,

        # The provided function for evaluating the estimation performance.
        .evaluate = NULL
    ),

    public = list(
        #' @description
        #' Set the function for specifying the true model parameters.
        #'
        #' @param specify A function that specifies the true model parameters.
        #' The function must match the signature and return type of the
        #' `specify` method in the [`powerly::ModelService`] class.
        #'
        #' @return
        #' This method returns void.
        set_specify = function(specify) {
            private$.specify <- specify
        },

        #' @description
        #' Set the function for generating a sample from the true model.
        #'
        #' @param generate A function that generates a sample from the true
        #' model. The function must match the signature and return type of the
        #' `generate` method in the [`powerly::ModelService`] class.
        #'
        #' @return
        #' This method returns void.
        set_generate = function(generate) {
            private$.generate <- generate
        },

        #' @description
        #' Set the function for estimating the model parameters.
        #'
        #' @param estimate A function that estimates the model parameters. The
        #' function must match the signature and return type of the `estimate`
        #' method in the [`powerly::ModelService`] class.
        #'
        #' @return
        #' This method returns void.
        set_estimate = function(estimate) {
            private$.estimate <- estimate
        },

        #' @description
        #' Set the function for evaluating the estimation performance by a
        #' performance measure of interest.
        #'
        #' @param evaluate A function that evaluates the estimation performance.
        #' The function must match the signature and return type of the
        #' `evaluate` method in the [`powerly::ModelService`] class.
        #'
        #' @return
        #' This method returns void.
        set_evaluate = function(evaluate) {
            private$.evaluate <- evaluate
        }
    ),

    active = list(
        #' @field specify The provided function for specifying the true model
        #' parameters.
        specify = function() { return(private$.specify) },

        #' @field generate The provided function for generating a sample from
        #' the true model parameters.
        generate = function() { return(private$.generate) },

        #' @field estimate The provided function for estimating the model
        #' parameters.
        estimate = function() { return(private$.estimate) },

        #' @field evaluate The provided function for evaluating the estimation
        #' performance.
        evaluate = function() { return(private$.evaluate) }
    )
)
