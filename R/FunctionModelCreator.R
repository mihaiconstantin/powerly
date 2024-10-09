#' @include ModelCreator.R ModelImplementation.R

#' @title
#' FunctionModelCreator
#'
#' @description
#' This class is a concrete implementation of the [`powerly::ModelCreator`]
#' abstract class. This class is used internally by the framework to dynamically
#' create model implementations at runtime from provided functions for
#' specifying true model parameters, generating data, estimating model
#' parameters, and evaluating the estimated model parameters.
#'
#' @seealso
#' [`powerly::ModelCreator`], [`powerly::ModelImplementation`], and
#' [`powerly::RuntimeModel`], and [`powerly::ModelService`].
#'
#' @export
FunctionModelCreator <- R6::R6Class("FunctionModelCreator",
    inherit = ModelCreator,

    public = list(
        #' @description
        #' Create a new [`powerly::FunctionModelCreator`] object.
        #'
        #' @return
        #' An object of class [`powerly::FunctionModelCreator`].
        initialize = function() { invisible() },

        #' @description
        #' Create a [`powerly::ModelImplementation`] instance from provided
        #' functions.
        #'
        #' @param specify A function that specifies the true model parameters.
        #' The function must match the signature and return type of the
        #' `specify` method in the [`powerly::ModelService`] class.
        #'
        #' @param generate A function that generates a sample from the true
        #' model. The function must match the signature and return type of the
        #' `generate` method in the [`powerly::ModelService`] class.
        #'
        #' @param estimate A function that estimates the model parameters. The
        #' function must match the signature and return type of the `estimate`
        #' method in the [`powerly::ModelService`] class.
        #'
        #' @param evaluate A function that evaluates the estimation performance.
        #' The function must match the signature and return type of the
        #' `evaluate` method in the [`powerly::ModelService`] class.
        #'
        #' @return
        #' An object of class [`powerly::ModelImplementation`].
        create_implementation = function(specify, generate, estimate, evaluate) {
            # Create a model implementation instance.
            implementation <- ModelImplementation$new()

            # # Set the implementation details on the instance.
            implementation$set_specify(specify)
            implementation$set_generate(generate)
            implementation$set_estimate(estimate)
            implementation$set_evaluate(evaluate)

            # Return the implementation.
            return(implementation)
        }
    )
)
