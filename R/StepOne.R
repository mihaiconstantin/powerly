#' @include ModelFactory.R StatisticFactory.R

StepOne <- R6::R6Class("StepOne",
    private = list(
        .range = NULL,
        .replications = NULL,
        .measure_value = NULL,
        .statistic_value = NULL,

        .measure_type = NULL,
        .statistic_type = NULL,
        .model_type = NULL,

        .statistic = NULL,
        .model = NULL,

        .true_model_parameters = NULL,
        .true_model_options = NULL,

        .measures = NULL,
        .statistics = NULL,

        .duration = NULL,

        # Expose data in an environment for faster access.
        .expose_data = function(env) {
            # Expose data in the parent environment for fast access.
            env$available_samples <- private$.range$available_samples
            env$replications <- private$.replications
            env$partition <- private$.range$partition
            env$true_model_parameters <- private$.true_model_parameters
            env$measure <- private$.measure_type

            # Function calls.
            env$monte_carlo <- private$.monte_carlo
            env$generate <- private$.model$generate
            env$estimate <- private$.model$estimate
            env$evaluate <- private$.model$evaluate
        },

        # Reset any previously computed measures and statistics.
        .clear_measures = function() {
            private$.measures <- NULL
            private$.statistics <- NULL
        },

        .set_model = function(type) {
            private$.model = ModelFactory$new()$get_model(type = type)
        },

        .set_statistic = function(type) {
            private$.statistic = StatisticFactory$new()$get_statistic(type = type)
        },

        # Perform a single Monte Carlo run for a single sample size.
        .monte_carlo = function(sample_size, generate, estimate, evaluate, true_model_parameters, measure) {
            # Generate data.
            data <- generate(sample_size, true_model_parameters)

            # Estimate model.
            estimated_model_parameters <- estimate(data)

            # Compute measure.
            measure <- evaluate(true_model_parameters, estimated_model_parameters, measure)

            return(measure)
        },

        # Replicate the MC simulations for several sample sizes sequentially.
        .simulate = function() {
            # Expose data needed in the current environment for fast access while looping.
            private$.expose_data(environment())

            # Pre-allocate storage for the results.
            measures <- matrix(NA, replications, available_samples)

            for (i in 1:available_samples) {
                for (j in 1:replications) {
                    measures[j, i] <- monte_carlo(partition[i], generate, estimate, evaluate, true_model_parameters, measure)
                }
            }

            # Store measures.
            private$.measures <- measures
        },

        # Replicate the MC simulations in parallel.
        .simulate_parallel = function(backend) {
            # Expose data for fast access.
            private$.expose_data(environment())

            # Replicated sample sizes.
            samples <- sort(rep(partition, replications))

            # Execute the task in parallel.
            results <- parabar::par_sapply(
                # That parallel backend injected.
                backend = backend,

                # The sequence of replicated sample sizes.
                x = samples,

                # The task function.
                fun = monte_carlo,

                # Additional arguments for the task function.
                generate, estimate, evaluate, true_model_parameters, measure
            )

            # Create the matrix of results.
            private$.measures <- matrix(
                data = results,
                nrow = replications,
                ncol = available_samples
            )
        },

        # Remove missing values from the measures.
        .remove_missing = function() {
            # Replace missing values with 0.
            private$.measures[is.na(private$.measures)] <- 0
        }
    ),

    public = list(
        # Set the range object.
        set_range = function(range) {
            private$.range <- range
        },

        # Set the true model based on the type.
        set_model = function(type) {
            # Record the type.
            private$.model_type <- type

            # Create instance based on the type via the factory.
            private$.set_model(type)
        },

        # Set the true model parameters, by specifying or creating them.
        set_true_model_parameters = function(..., matrix = NULL) {
            if(is.null(matrix)) {
                # Create the parameters.
                private$.true_model_parameters <- private$.model$create(...)

                # Record the creating options.
                private$.true_model_options <- list(...)
            } else {
                # Fix the model parameters.
                private$.true_model_parameters <- matrix
            }
        },

        # Set the measure of interest (e.g., sensitivity).
        set_measure = function(measure, value) {
            private$.measure_type <- measure
            private$.measure_value <- value
        },

        # Set the statistic computed on the measure values.
        set_statistic = function(statistic, value) {
            # Record the statistic type.
            private$.statistic_type = statistic

            # Create an instance of the statistic via the factory.
            private$.set_statistic(statistic)

            # Set the statistic value of interest.
            private$.statistic_value <- value
        },

        # Perform Monte Carlo simulations given the current configuration.
        simulate = function(replications, backend = NULL) {
            # Time when the simulation started.
            start_time <- Sys.time()

            # Reset any previous simulation before engaging in a new one.
            private$.clear_measures()

            # Set replications.
            private$.replications <- replications

            # Decide whether to run in a cluster or sequentially.
            if (!is.null(backend)){
                # Replicate Monte Carlo runs in parallel.
                private$.simulate_parallel(backend)
            } else {
                # Replicate Monte Carlo runs sequentially.
                private$.simulate()
            }

            # Remove missing values.
            private$.remove_missing()

            # Compute how long the simulation took.
            private$.duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
        },

        # Compute the statistics for the Monte Carlo simulations.
        compute = function() {
            private$.statistics <- private$.statistic$apply(private$.measures, private$.measure_value)
        }
    ),

    active = list(
        range = function() { return(private$.range) },
        statistic = function() { return(private$.statistic) },
        model = function() { return(private$.model) },
        measure_type = function() { return(private$.measure_type) },
        statistic_type = function() { return(private$.statistic_type) },
        model_type = function() { return(private$.model_type) },
        measure_value = function() { return(private$.measure_value) },
        statistic_value = function() { return(private$.statistic_value) },
        true_model_parameters = function() { return(private$.true_model_parameters) },
        measures = function() { return(private$.measures) },
        statistics = function() { return(private$.statistics) },
        replications = function() { return(private$.replications) },
        duration = function() { return(private$.duration) }
    )
)
