#' @include SimulationService.R

#' @title
#' ModelSimulation
#'
#' @description
#' This class implements the [`powerly::SimulationService`] interface for
#' running a simulation using a [`powerly::ModelService`] implementation
#' as a backend.
#'
#' @seealso
#' [`powerly::SimulationService`], [`powerly::ModelService`], and
#' [`powerly::ModelConfiguration`].
#'
#' @export
ModelSimulation <- R6::R6Class("ModelSimulation",
    inherit = SimulationService,

    private = list(
        # The model specification (i.e., true model parameters).
        .specification = list()
    ),

    public = list(
        #' @field model An object of a class implementing the
        #' [`powerly::ModelService`] interface.
        model = NULL,

        #' @field configuration An object of a class implementing the
        #' [`powerly::ModelConfigurationService`].
        configuration = NULL,

        #' @description
        #' Create a new [`powerly::ModelSimulation`] object.
        #'
        #' @param model An object of a class implementing the
        #' [`powerly::ModelService`] interface.
        #'
        #' @param configuration An object of a class implementing the
        #' [`powerly::ModelConfigurationService`] interface.
        #'
        #' @return
        #' An object of class [`powerly::ModelSimulation`].
        initialize = function(model, configuration) {
            # Set the model.
            self$model <- model

            # Set the configuration.
            self$configuration <- configuration
        },

        #' @description
        #' Configure the arguments for a specific model operation defined by the
        #' [`powerly::ModelService`] interface.
        #'
        #' @param operation A character string specifying the model operation to
        #' configure.
        #'
        #' @param ... The arguments that will be passed to the model operation
        #' when called during the simulation. The arguments are specific to the
        #' model operation being configured and to the specific model
        #' implementation. Registering a new model with the framework can be
        #' done through the public `API` [`powerly::register_model`] and
        #' [`powerly::validate_model`].
        #'
        #' @return
        #' This method returns void. The updated list of arguments can be
        #' accessed via the appropriate field in the `configuration` object.
        configure = function(operation, ...) {
            # Configure the appropriate model operation.
            switch(operation,

                # Configure the `specify` operation.
                specify = self$configuration$configure_specify(...),

                # Configure the `generate` operation.
                generate = self$configuration$configure_generate(...),

                # Configure the `estimate` operation.
                estimate = self$configuration$configure_estimate(...),

                # Configure the `evaluate` operation.
                evaluate = self$configuration$configure_evaluate(...),

                # Throw an error if the operation is not recognized.
                Exception$unknown_model_operation(what)
            )
        },

        #' @description
        #' Run the simulation using the specific model and configuration
        #' implementations.
        #'
        #' @param ... Optional arguments controlling the simulation flow. Note
        #' that these are not passed to the model operations (i.e., see the
        #' `configure` method for that). These arguments are currently not in
        #' use.
        #'
        #' @return
        #' This method returns a list of variable length, containing the results
        #' of a single simulation run.
        run = function(...) {
            # If the model has not been specified.
            if (length(private$.specification) == 0) {
                # Specify the true model.
                private$.specification <- do.call(
                    # The model operation.
                    self$model$specify,

                    # The optional arguments for the model specification.
                    self$configuration$specify
                )
            }

            # Generate data.
            generation <- do.call(
                # The model operation.
                self$model$generate, c(
                    list(
                        # The model specification.
                        specification = private$.specification
                    ),

                    # The optional arguments for the data generation
                    self$configuration$generate
                )
            )

            # Estimate the model.
            estimation = do.call(
                # The model operation.
                self$model$estimate, c(
                    list(
                        # The data.
                        generation = generation
                    ),

                    # The optional arguments for the model estimation.
                    self$configuration$estimate
                )
            )

            # Evaluate the model.
            evaluation = do.call(
                # The model operation.
                self$model$evaluate, c(
                    list(
                        # The model specification.
                        specification = private$.specification,

                        # The model estimation.
                        estimation = estimation
                    ),

                    # The optional arguments for the model evaluation.
                    self$configuration$evaluate
                )
            )

            # Return the simulation output.
            return(evaluation)
        }
    )
)
