Interpolation <- R6::R6Class("Interpolation",
    private = list(
        .spline = NULL,
        .x = NULL,
        .basis_matrix = NULL,
        .fitted = NULL,

        .set_x = function() {
            private$.x <- min(private$.spline$basis$x):max(private$.spline$basis$x)
        }
    ),

    public = list(
        initialize = function(spline, ...) {
            private$.spline <- spline

            # Create interpolation range.
            private$.set_x()

            # Create basis for interpolation range.
            private$.basis_matrix <- private$.spline$basis$extend(private$.x, ...)

            # Get fitted values.
            private$.fitted <- private$.basis_matrix %*% private$.spline$alpha
        }
    ),

    active = list(
        x = function() { return(private$.x) },
        basis_matrix = function() { return(private$.basis_matrix) },
        fitted = function() { return(private$.fitted) }
    )
)
