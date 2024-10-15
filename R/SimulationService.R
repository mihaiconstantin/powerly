#' @include Exception.R

#' @title
#' SimulationService
#'
#' @description
#' This is an interface that defines the methods a simulation class must
#' implement.
#'
#' @seealso
#' [`powerly::ModelSimulation`], [`powerly::ModelService`], and
#' [`powerly::ModelConfigurationService`].
#'
#' @export
SimulationService <- R6::R6Class("SimulationService",
    public = list(
        #' @description
        #' Create a new [`powerly::SimulationService`] object.
        #'
        #' @return
        #' Instantiating this class will throw an error.
        initialize = function() {
            Exception$abstract_class_not_instantiable(self)
        },

        #' @description
        #' Configure the simulation arguments.
        #'
        #' @param ... Optional arguments for configuring the simulation.
        #'
        #' @return
        #' This method returns void.
        configure = function(...) {
            Exception$method_not_implemented()
        },

        #' @description
        #' Run the simulation.
        #'
        #' @param ... Optional arguments for running the simulation.
        #'
        #' @return
        #' This method returns a list of variable length, containing the results
        #' of a single simulation run.
        run = function(...) {
            Exception$method_not_implemented()
        }
    )
)
