#' @include SimulationService.R

#' @title SimulationDecorator
#'
#' @description
#' This class acts as a base decorator for a concrete implementation of the
#' [`powerly::SimulationService`] stored as a private field. It respects the
#' [`powerly::SimulationService`] interface and simply forwards method calls to
#' the set simulation instance. Additional behavior can be added to the
#' simulation instance by extending this base decorator and overriding the
#' methods of interest defined in the [`powerly::SimulationService`] interface.
#'
#' @seealso
#' [`powerly::SimulationService`] and [`powerly::ModelSimulation`].
#'
#' @export
SimulationDecorator <- R6::R6Class("SimulationDecorator",
    inherit = SimulationService,

    private = list(
        # The simulation instance.
        .simulation = NULL
    ),

    public = list(
        #' @description
        #' Set the simulation instance.
        #'
        #' @param simulation An object of class [`powerly::SimulationService`].
        #'
        #' @return
        #' This method returns void.
        set_simulation = function(simulation) {
            # Check the type.
            Helper$check_object_type(simulation, "SimulationService")

            # Set the simulation instance.
            private$.simulation <- simulation
        },

        #' @description
        #' Configure the simulation arguments. This method class the
        #' corresponding method on the simulation instance.
        #'
        #' @param ... Optional arguments for configuring the simulation.
        #'
        #' @return
        #' This method returns void.
        configure = function(...) {
            # Forward the configuration to the simulation instance.
            private$.simulation$configure(...)
        },

        #' @description
        #' Run the simulation. This method calls the corresponding method on the
        #' simulation instance.
        #'
        #' @param ... Optional arguments for running the simulation.
        #'
        #' @return
        #' This method returns a list of variable length, containing the results
        #' of a single simulation run.
        run = function(...) {
            # Forward the execution to the simulation instance.
            private$.simulation$run(...)
        }
    ),

    active = list(
        simulation = function() {
            # Get the simulation instance.
            return(private$.simulation)
        }
    )
)
