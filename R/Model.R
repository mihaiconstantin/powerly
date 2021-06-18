Model <- R6::R6Class("Model",
    public = list(
        # Create true model parameters.
        create = function(...) {
            stop(.__ERRORS__$not_implemented)
        },

        # Generate data from the true model.
        generate = function(sample_size, true_parameters, ...) {
            stop(.__ERRORS__$not_implemented)
        },

        # Estimate the true model.
        estimate = function(data, ...) {
            stop(.__ERRORS__$not_implemented)
        },

        # Compare true model with an estimated model of the same type.
        evaluate = function(true_parameters, estimated_parameters, measure, ...) {
            stop(.__ERRORS__$not_implemented)
        }
    )
)
