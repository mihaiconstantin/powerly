#' @include RuntimeModel.R

#' @title
#' ModelCreator
#'
#' @description
#' This is an abstract class that defines the algorithm for creating a
#' [`powerly::RuntimeModel`] instance from a [`powerly::ModelImplementation`]
#' instance. Concrete implementations of this class must handle the creation of
#' [`powerly::ModelImplementation`] instances (e.g., from a set of functions
#' provided in the global environment). For registering a new model with the
#' framework, it is recommended to use use the public `API` facades
#' [`powerly::register_model`] and [`powerly::validate_model`].
#'
#' @seealso
#' [`powerly::ModelService`], [`powerly::ModelImplementation`],
#' [`powerly::RuntimeModel`], and [`powerly::FunctionModelCreator`].
#'
#' @export
ModelCreator <- R6::R6Class("ModelCreator",
    public = list(
        #' @description
        #' Create a new [`powerly::ModelCreator`] object.
        #'
        #' @return
        #' Instantiating this class will throw an error.
        initialize = function() {
            Exception$abstract_class_not_instantiable(self)
        },

        #' @description
        #' An abstract method for creating a [`powerly::ModelImplementation`]
        #' instance from a set of arguments.
        #'
        #' @param ... Arguments passed from the global environment for creating
        #' a [`powerly::ModelImplementation`] instance.
        #'
        #' @return
        #' An object of class [`powerly::ModelImplementation`].
        create_implementation = function(...) {
            Exception$method_not_implemented()
        },

        #' @description
        #' Create a [`powerly::RuntimeModel`] instance from a set of arguments.
        #'
        #' @param ... Arguments passed from the global environment that are
        #' provided to the `create_implementation` method.
        #'
        #' @return
        #' An object of class [`powerly::RuntimeModel`].
        create = function(...) {
            # Create a model implementation instance.
            implementation <- self$create_implementation(...)

            # Create a runtime model instance.
            model <- RuntimeModel$new()

            # Register the implementation.
            model$set_implementation(implementation)

            # Return the implementation.
            return(model)
        }
    )
)
