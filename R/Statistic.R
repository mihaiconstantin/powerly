Statistic <- R6::R6Class("Statistic",
    public = list(
        # Compute statistic for a vector of measures.
        compute = function(measures_vector, ...) {
            stop(.__ERRORS__$not_implemented)
        },

        # Apply statistic to a matrix of measures.
        apply = function(measures_matrix, ...) {
            stop(.__ERRORS__$not_implemented)
        }
    )
)
