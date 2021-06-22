Basis <- R6::R6Class("Basis",
    private = list(
        .x = NULL,
        .matrix = NULL,
        .attrs = NULL,

        .df = NULL,
        .monotone = NULL,
        .degree = NULL,

        .set_attributes = function() {
            # What to exclude.
            exclude = c("x", "class", "dimnames")

            # Spline basis attributes.
            attrs <- attributes(private$.matrix)

            # Set the relevant ones.
            private$.attrs <- attrs[!names(attrs) %in% exclude]
        },

        .make_basis = function(...) {
            if (private$.monotone) {
                # Create basis matrix with `degree - 1` (see Ramsay, 1988 and https://github.com/wenjie2wang/splines2/issues/6).
                private$.matrix <- splines2::iSpline(private$.x, df = private$.df, intercept = TRUE, degree = private$.degree - 1, ...)

                # Set extract Spline basis attributes.
                private$.attrs <- private$.set_attributes()

                # Add an intercept term for I-Splines, otherwise it starts at 0.
                private$.matrix <- cbind(1, private$.matrix)
            } else {
                private$.matrix <- splines2::bSpline(private$.x, df = private$.df, intercept = TRUE, degree = private$.degree, ...)
                private$.attrs <- private$.set_attributes()
            }
        }
    ),

    public = list(
        initialize = function(x, df, monotone = TRUE, degree = 3, ...) {
            # Store config.
            private$.x <- x
            private$.df <- df
            private$.monotone <- monotone
            private$.degree <- degree

            # Make basis.
            private$.make_basis(...)
        },

        extend = function(x_new, ...) {
            if (private$.monotone) {
                matrix_new <- do.call(splines2::iSpline, c(list(x = x_new), private$.attrs, list(...)))
                matrix_new <- cbind(1, matrix_new)
            } else {
                matrix_new <- do.call(splines2::bSpline, c(list(x = x_new), private$.attrs, list(...)))
            }
            return(matrix_new)
        }
    ),

    active = list(
        x = function() { return(private$.x) },
        matrix = function() { return(private$.matrix) },
        df = function() { return(private$.df) },
        monotone = function() { return(private$.monotone) },
        attrs = function() { return(private$.attrs) }
    )
)
