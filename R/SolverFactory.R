#' @include OsqpSolver.R QuadprogSolver.R

SolverFactory <- R6::R6Class("SolverFactory",
    public = list(
        get_solver = function(type) {
            return(
                switch(type,
                    osqp = OsqpSolver$new(),
                    quadprog = QuadprogSolver$new(),
                    stop(.__ERRORS__$not_developed)
                )
            )
        }
    )
)
