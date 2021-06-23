Solver <- R6::R6Class("Solver",
    public = list(
        # Setup solver.
        setup = function(basis, y, increasing, ...) {
            stop(.__ERRORS__$not_implemented)
        },

        # Solve the problem give the data.
        solve = function(...) {
            stop(.__ERRORS__$not_implemented)
        },

        # Solve an updated problem
        solve_update = function(y_new, ...) {
            stop(.__ERRORS__$not_implemented)
        }
    )
)
