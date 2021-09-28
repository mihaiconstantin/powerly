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

            # Run simulation.
            private$.measures <- matrix(
                backend$sapply(samples, monte_carlo, generate, estimate, evaluate, true_model_parameters, measure),
                replications,
                available_samples
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
            private$.duration <- Sys.time() - start_time
        },

        # Compute the statistics for the Monte Carlo simulations.
        compute = function() {
            private$.statistics <- private$.statistic$apply(private$.measures, private$.measure_value)
        },

        # Plot the results of current class instance.
        plot = function(save = FALSE, path = NULL, width = 14, height = 10, ...) {
            # Fetch plot settings.
            .__PLOT_SETTINGS__  <- plot_settings()

            # Create data frame for the boxplot.
            data_measures <- data.frame(
                measure = as.numeric(private$.measures),
                sample = as.factor(sort(rep(private$.range$partition, private$.replications)))
            )

            # Create data frame for the computed statistics.
            data_statistics <- data.frame(
                sample = as.factor(private$.range$partition),
                statistic = private$.statistics
            )

            # Common theme settings for both plots.
            .__PLOT_SETTINGS__ <- c(.__PLOT_SETTINGS__, list(
                ggplot2::scale_y_continuous(breaks = seq(0, 1, .1))
            ))

            # Create the measures plot.
            plot_measures <- ggplot2::ggplot(data_measures, ggplot2::aes(x = sample, y = measure)) +
                ggplot2::geom_boxplot(
                    fill = "#e6e6e6",
                    width = .6,
                    outlier.colour = "#bebebe"
                ) +
                ggplot2::geom_hline(
                    yintercept = private$.measure_value,
                    color = "#8b0000",
                    linetype = "dotted",
                    size = .65
                ) +
                ggplot2::labs(
                    title = "Monte Carlo Replications",
                    x = "Selected Sample Size",
                    y = "Performance Measure Value"
                ) +
                .__PLOT_SETTINGS__

            plot_statistics <- ggplot2::ggplot(data_statistics, ggplot2::aes(x = sample, y = statistic)) +
                ggplot2::geom_point(
                    fill = "#3f51b5",
                    color = "#3f51b5",
                    size = 1.5,
                    shape = 23
                ) +
                ggplot2::geom_hline(
                    yintercept = private$.statistic_value,
                    color = "#8b0000",
                    linetype = "dotted",
                    size = .65
                ) +
                ggplot2::labs(
                    title = "Computed Statistics",
                    x = "Candidate Sample Size Range",
                    y = "Statistic Value"
                ) +
                .__PLOT_SETTINGS__

            # Prepare plot spacing.
            plot_measures <- plot_measures & ggplot2::theme(plot.margin = ggplot2::margin(t = 0, r = 0, b = 0, l = 0))
            plot_statistics <- plot_statistics & ggplot2::theme(plot.margin = ggplot2::margin(t = 15, r = 0, b = 0, l = 0))

            # Arrange the plots together.
            plot_step_1 <- plot_measures /
                plot_statistics

            # Save the plot.
            if (save) {
                if (is.null(path)) {
                    # If no path is provided, create one.
                    path <- paste0(getwd(), "/", "step-1", "_", gsub(":|\\s", "-", as.character(Sys.time()), perl = TRUE), ".pdf")
                }

                # Save the plot.
                ggplot2::ggsave(path, plot = plot_step_1, width = width, height = height, ...)
            } else {
                # Show the plot.
                plot(plot_step_1)
            }

            # Return the plot object silently.
            invisible(plot_step_1)
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
