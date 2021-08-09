#' @include ModelFactory.R StatisticFactory.R

StepOne <- R6::R6Class("StepOne",
    private = list(
        .range = NULL,
        .replications = NULL,
        .measure_value = NULL,
        .statistic_value = NULL,

        .measure = NULL,
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
            env$measure <- private$.measure

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

            # Run simulation.
            private$.measures <- matrix(
                backend$sapply(samples, monte_carlo, generate, estimate, evaluate, true_model_parameters, measure),
                replications,
                available_samples
            )
        }
    ),

    public = list(
        # Set the range object.
        set_range = function(range) {
            private$.range <- range
        },

        # Set the true model based on the type.
        set_model = function(type) {
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
            private$.measure <- measure
            private$.measure_value <- value
        },

        # Set the statistic computed on the measure values.
        set_statistic = function(statistic, value) {
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

            # Compute how long the simulation took.
            private$.duration <- Sys.time() - start_time
        },

        # Compute the statistics for the Monte Carlo simulations.
        compute = function() {
            private$.statistics <- private$.statistic$apply(private$.measures, private$.measure_value)
        },

        # Plot the results of current class instance.
        plot = function() {
            # Revert changes on exit.
            on.exit({
                # Reset layout.
                layout(1:1)

                # Reset margins.
                par(mar = c(5.1, 4.1, 4.1, 2.1))
            })

            # Set layout.
            layout(matrix(c(1, 2, 3, 3), 2, 2, byrow = TRUE))

            # Adjust margins for layout.
            par(mar = c(5.1, 4.1, 4.1, 2.1) + 1)

            # True model.
            qgraph::qgraph(
                input = private$.true_model_parameters,
                layout = "spring",
                color = .__GRAPHICS__$node.color,
                posCol = .__GRAPHICS__$positive.edge.color,
                negCol = .__GRAPHICS__$negative.edge.color,
                edge.labels = TRUE,
                edge.label.cex = .9,
                edge.label.bg = TRUE,
                edge.label.color = "black"
            )
            title(
                main = paste("True Model"),
                cex.main = 1,
                cex.lab = 1,
                adj = 0
            )
            title(
                xlab = ifelse(
                    !is.null(private$.true_model_options),
                    paste("Generated from", paste0("(", names(private$.true_model_options), " = ", private$.true_model_options, ")", collapse = " & ")),
                    "Specified"
                ),
                cex.lab = 1,
                line = 4
            )

            # Measures.
            boxplot(
                private$.measures,
                names = private$.range$partition,
                xlab = "",
                ylab = "",
                las = 2,
                cex.axis = .9
            )
            title(
                main = "Monte Carlo Replicated Measures",
                ylab = paste0("Values for measure '", toupper(private$.measure), "'"),
                cex.main = 1,
                cex.lab = 1
            )
            title(
                xlab = "Replicated sample sizes",
                cex.lab = 1,
                line = 4
            )
            abline(
                h = private$.measure_value,
                col = "#2c2c2c",
                lty = 2
            )

            # Statistics.
            plot(
                self$range$partition,
                self$statistics,
                col = "royalblue",
                pch = 19,
                xlab = "",
                ylab = "",
                xaxt = "n",
                yaxt = "n",
                cex = 1
            )
            title(
                main = "Computed Statistics",
                ylab = paste0("Values for statistic '", toupper(sub("Statistic", "", class(private$.statistic)[1])), "'"),
                cex.main = 1,
                cex.lab = 1
            )
            title(
                xlab = "Sample sizes",
                cex.lab = 1,
                line = 4
            )
            axis(
                side = 1,
                at = private$.range$partition,
                tck = -0.01,
                las = 2,
                cex.axis = .9
            )
            axis(
                side = 2,
                cex.axis = .9,
                las = 1
            )
            abline(
                h = private$.statistic_value,
                col = "#2c2c2c",
                lty = 2
            )
        }
    ),

    active = list(
        range = function() { return(private$.range) },
        replications = function() { return(private$.replications) },
        measure_value = function() { return(private$.measure_value) },
        statistic_value = function() { return(private$.statistic_value) },
        measure = function() { return(private$.measure) },
        statistic = function() { return(private$.statistic) },
        model = function() { return(private$.model) },
        true_model_parameters = function() { return(private$.true_model_parameters) },
        measures = function() { return(private$.measures) },
        statistics = function() { return(private$.statistics) },
        duration = function() { return(private$.duration) }
    )
)
