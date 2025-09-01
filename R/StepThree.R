#' @include Spline.R

StepThree <- R6::R6Class("StepThree",
    private = list(
        .step_2 = NULL,
        .boots = NULL,
        .lower_ci = NULL,
        .upper_ci = NULL,
        .duration = NULL,

        .boot_statistics = NULL,
        .ci = NULL,
        .samples = NULL,

        # Expose data in a specified environment for faster access.
        .expose_data = function(env) {
            # Data.
            env$available_samples <- private$.step_2$step_1$range$available_samples
            env$measures <- private$.step_2$step_1$measures
            env$replications <- private$.step_2$step_1$replications
            env$measure_value <- private$.step_2$step_1$measure_value
            env$extended_basis <- private$.step_2$interpolation$basis_matrix
            env$sequence_length <- private$.step_2$step_1$range$sequence_length

            # Functions and instances.
            env$statistic <- private$.step_2$step_1$statistic$compute
            env$solver <- private$.step_2$spline$solver
            env$boot <- private$.boot
        },

        # Reset any previously computed bootstrapped splines.
        .clear_bootstrap = function() {
            private$.boots <- NULL
            private$.boot_statistics <- NULL
        },

        # Reset any previously computed confidence intervals.
        .clear_ci = function() {
            private$.lower_ci <- NULL
            private$.upper_ci <- NULL
            private$.ci <- NULL
            private$.samples = NULL
        },

        # Self-contained core of the bootstrap procedure.
        .boot = function(index, available_samples, measures, measure_value, replications, extended_basis, statistic, solver) {
            # Store bootstrapped statistics.
            boot_statistics <- vector(mode = "numeric", length = available_samples)

            # Resample.
            for (j in 1:available_samples) {
                boot_statistics[j] <- statistic(sample(measures[, j], replications, replace = TRUE), measure_value)
            }

            # Interpolate using estimated coefficients for the bootstrapped statistics.
            return(extended_basis %*% solver$solve_update(boot_statistics))
        },

        # Performing the bootstrapping procedure sequentially.
        .bootstrap = function(boots) {
            # One time copy to expose data needed in the loop for fast access.
            private$.expose_data(environment())

            # Storage for results.
            boot_statistics <- matrix(0, boots, sequence_length)

            for (i in 1:boots) {
                # Store bootstrapped spline.
                boot_statistics[i, ] <- boot(i, available_samples, measures, measure_value, replications, extended_basis, statistic, solver)
            }

            # Store bootstrapped statistics.
            private$.boot_statistics <- boot_statistics
        },

        # Performing the bootstrapping procedure in parallel.
        .bootstrap_parallel = function(boots, backend) {
            # Expose data for fast access.
            private$.expose_data(environment())

            # Execute the task in parallel.
            results <- parabar::par_sapply(
                # That parallel backend injected.
                backend = backend,

                # The sequence of bootstraps.
                x = seq_len(boots),

                # The task function.
                fun = boot,

                # Additional arguments for the task function.
                available_samples, measures, measure_value, replications, extended_basis, statistic, solver
            )

            # Store the transposed results
            private$.boot_statistics <- t(results)
        },

        # Rule for selecting sufficient sample sizes based on the shape of the spline.
        .selection_rule = function(spline, statistic_value, monotone, increasing) {
            # For non-monotone splines, simply return the first sample size that exceeded the statistic.
            if (!monotone) {
               increasing = TRUE
            }

            # Look for sample sizes where the spine is greater than the statistic.
            if(increasing) {
                test <- spline >= statistic_value

            # Look for sample sizes where the spine is smaller than the statistic.
            } else {
                test <- spline <= statistic_value
            }

            # Determine metadata about the spline check.
            length_test = length(test)
            sum_test = sum(test)

            # If no sample size satisfies the test then return the largest sample size.
            if (sum_test == 0) {
                return(length_test)

            # If all sample size satisfy the test then return the smallest one.
            } else if (sum_test == length_test) {
                return(1)

            # If some sample sizes satisfy the test, find the first one.
            } else {
                return(which.max(test))
            }
        },

        # Compute confidence intervals.
        .compute_ci = function(lower_ci, upper_ci) {
            # Compute the confidence intervals via the percentile method.
            private$.ci <- t(apply(private$.boot_statistics, 2, quantile, probs = c(0, lower_ci, .5, upper_ci, 1), na.rm = TRUE))

            # Add row names for clarity.
            rownames(private$.ci) <- private$.step_2$interpolation$x
        },

        # Compute confidence intervals.
        .compute_ci_parallel = function(lower_ci, upper_ci, backend) {
            # Execute the task in parallel.
            results <- parabar::par_apply(
                # That parallel backend injected.
                backend = backend,

                # The matrix of statistics.
                x = private$.boot_statistics,

                # The dimension to execute over.
                margin = 2,

                # The task function.
                fun = quantile,

                # The probabilities for the `quantile` task.
                probs = c(0, lower_ci, .5, upper_ci, 1),

                # Remove missing values.
                na.rm = TRUE
            )

            # Store the transposed results.
            private$.ci <- t(results)

            # Add row names for clarity.
            rownames(private$.ci) <- private$.step_2$interpolation$x
        },

        # Extract the spline CI for sufficient samples at a particular statistic value.
        .extract_sufficient_samples = function(statistic_value) {
            # Find CI at statistic value.
            sufficient_samples_ci <- apply(private$.ci, 2, function(ci) {
                private$.step_2$interpolation$x[private$.selection_rule(ci, statistic_value, private$.step_2$spline$basis$monotone, private$.step_2$spline$solver$increasing)]
            })

            # Reverse values names, i.e., 1 - percentile.
            sufficient_samples_ci <- sufficient_samples_ci[rev(1:length(sufficient_samples_ci))]
            names(sufficient_samples_ci) <- rev(names(sufficient_samples_ci))

            # Store the CI for the sufficient samples.
            private$.samples <- sufficient_samples_ci
        }
    ),

    public = list(
        initialize = function(step_2) {
            # Store a pointer to the previous step.
            private$.step_2 <- step_2
        },

        # Perform the bootstrap.
        bootstrap = function(boots = 3000, backend = NULL) {
            # Time when the bootstrap started.
            start_time <- Sys.time()

            # Reset any previous bootstrapped values before engaging a new one.
            private$.clear_bootstrap()

            # Set boots.
            private$.boots <- boots

            # Decide whether to run in a cluster or sequentially.
            if (!is.null(backend)) {
                # Run the bootstrap in parallel.
                private$.bootstrap_parallel(boots, backend)
            } else {
                # Run the bootstrap sequentially.
                private$.bootstrap(boots)
            }

            # Compute how long the bootstrap took.
            private$.duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
        },

        # Compute confidence intervals.
        compute = function(lower_ci = 0.025, upper_ci = 0.975, backend = NULL) {
            # Time when the bootstrap started.
            start_time <- Sys.time()

            # Reset any previous CI before computing new ones.
            private$.clear_ci()

            # Set the CI bounds.
            private$.lower_ci <- lower_ci
            private$.upper_ci <- upper_ci

            # Decide whether to run in a cluster or sequentially.
            if (!is.null(backend)) {
                # Compute confidence intervals for the entire spline in parallel.
                private$.compute_ci_parallel(lower_ci, upper_ci, backend)
            } else {
                # Compute confidence intervals for the entire spline sequentially.
                private$.compute_ci(lower_ci, upper_ci)
            }

            # Compute how long the bootstrap took.
            private$.duration <- private$.duration + as.numeric(difftime(Sys.time(), start_time, units = "secs"))

            # Extract the confidence intervals for the sufficient sample sizes.
            private$.extract_sufficient_samples(private$.step_2$step_1$statistic_value)
        },

        # Get bootstrapped spline values for a given sample size.
        get_statistics = function(sample) {
            return(private$.boot_statistics[, which(private$.step_2$interpolation$x == sample)])
        },

        # Make density plot given a sample size in the range.
        density_plot = function(sample) {
            # Extract the data.
            data <- self$get_statistics(sample)

            # Make the density plot
            plot_density <- ggplot2::ggplot(mapping = ggplot2::aes(data)) +
                ggplot2::geom_density(
                    fill = "#4d4d4d",
                    color = "#4d4d4d",
                    alpha = .15
                ) +
                ggplot2::geom_vline(
                    xintercept = mean(data),
                    color = "#8b0000",
                    linetype = "dotted",
                    size = .65
                ) +
                ggplot2::labs(
                    title = paste0("Sample: ", sample, " | ", "M = ", round(mean(data), 2), " | ", "SD = ", round(sd(data), 2)),
                    y = "Density",
                    x = "Statistic Value"
                ) +
                plot_settings() +
                ggplot2::theme(
                    axis.text.x = ggplot2::element_text(
                        angle = 0,
                        hjust = 0.5
                    )
                )

            return(plot_density)
        }
    ),

    active = list(
        step_1 = function() { return(private$.step_2$step_1) },
        step_2 = function() { return(private$.step_2) },
        boots = function() { return(private$.boots) },
        lower_ci = function() { return(private$.lower_ci) },
        upper_ci = function() { return(private$.upper_ci) },
        lower_ci_string = function() { return(paste0(private$.lower_ci * 100, "%")) },
        upper_ci_string = function() { return(paste0(private$.upper_ci * 100, "%")) },
        boot_statistics = function() { return(private$.boot_statistics) },
        ci = function() { return(private$.ci) },
        samples = function() { return(private$.samples) },
        duration = function() { return(private$.duration) }
    )
)
