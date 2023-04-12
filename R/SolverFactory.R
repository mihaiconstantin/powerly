#' @include QuadprogSolver.R

SolverFactory <- R6::R6Class("SolverFactory",
    public = list(
        get_solver = function(type) {
            return(
                switch(type,
                    quadprog = QuadprogSolver$new(),
                    stop(.__ERRORS__$not_developed)
                )
            )
        }
    )
)
