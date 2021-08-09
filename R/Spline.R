Spline <- R6::R6Class("Spline",
    private = list(
        .basis = NULL,
        .solver = NULL,
        .alpha = NULL,
        .fitted = NULL,

        .estimate_alpha = function() {
            private$.alpha <- private$.solver$solve()
        },

        .predict_values = function() {
            private$.fitted <- private$.basis$matrix %*% private$.alpha
        }
    ),

    public = list(
        initialize = function(basis, solver) {
            private$.basis <- basis
            private$.solver <- solver
        },

        estimate_alpha = function() {
            private$.estimate_alpha()
        },

        predict_values = function() {
            private$.predict_values()
        }
    ),

    active = list(
        alpha = function() { return(private$.alpha) },
        fitted = function() { return(private$.fitted) },
        basis = function() { return(private$.basis) },
        solver = function() { return(private$.solver) }
    )
)
