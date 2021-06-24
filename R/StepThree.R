#' @include Spline.R

StepThree <- R6::R6Class("StepThree",
    private = list(
        .step_2 = NULL,
        .boots = NULL,
        .duration = NULL,

        .boot_splines = NULL,
        .spline_ci = NULL,
        .sufficient_samples = NULL,

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
            private$.boot_splines <- NULL
        },

        # Reset any previously computed confidence intervals.
        .clear_ci = function() {
            private$.spline_ci <- NULL
            private$.sufficient_samples = NULL
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
            splines <- matrix(0, boots, sequence_length)

            for (i in 1:boots) {
                # Store bootstrapped spline.
                splines[i, ] <- boot(i, available_samples, measures, measure_value, replications, extended_basis, statistic, solver)
            }

            # Store bootstrapped splines.
            private$.boot_splines <- splines
        },

        # Performing the bootstrapping procedure in parallel.
        .bootstrap_parallel = function(boots, cores) {
            # Expose data for fast access.
            private$.expose_data(environment())

            # Make cluster.
            cluster <- parallel::makePSOCKcluster(cores)

            # Stop the cluster on exit.
            on.exit(parallel::stopCluster(cluster))

            # Run bootstrap.
            private$.boot_splines <- t(parallel::parSapply(cluster, seq_len(boots), boot,
                available_samples, measures, measure_value, replications, extended_basis, statistic, solver
            ))
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
        .compute_spline_ci = function(lower, upper) {
            # Compute the confidence intervals via the percentile method.
            private$.spline_ci <- t(apply(private$.boot_splines, 2, quantile, probs = c(0, lower, .5, upper, 1), na.rm = TRUE))

            # Add row names for clarity.
            rownames(private$.spline_ci) <- private$.step_2$interpolation$x
        },

        # Compute confidence intervals.
        .compute_spline_ci_parallel = function(lower, upper, cores) {
            # Make cluster.
            cluster <- parallel::makePSOCKcluster(cores)

            # Stop the cluster on exit.
            on.exit(parallel::stopCluster(cluster))

            # Compute the confidence intervals via the percentile method.
            private$.spline_ci <- t(parallel::parApply(cluster, private$.boot_splines, 2, quantile, probs = c(0, lower, .5, upper, 1), na.rm = TRUE))

            # Add row names for clarity.
            rownames(private$.spline_ci) <- private$.step_2$interpolation$x
        },

        # Extract the spline CI for sufficient samples at a particular statistic value.
        .extract_sufficient_samples = function(statistic_value) {
            # Find CI at statistic value.
            sufficient_samples_ci <- apply(private$.spline_ci, 2, function(ci) {
                private$.step_2$interpolation$x[private$.selection_rule(ci, statistic_value, private$.step_2$spline$basis$monotone, private$.step_2$spline$solver$increasing)]
            })

            # Reverse values names, i.e., 1 - percentile.
            sufficient_samples_ci <- sufficient_samples_ci[rev(1:length(sufficient_samples_ci))]
            names(sufficient_samples_ci) <- rev(names(sufficient_samples_ci))

            # Store the CI for the sufficient samples.
            private$.sufficient_samples <- sufficient_samples_ci
        }
    ),

    public = list(
        initialize = function(step_2) {
            # Store a pointer to the previous step.
            private$.step_2 <- step_2
        },

        # Perform the bootstrap.
        bootstrap = function(boots = 3000, cores = NULL) {
            # Time when the bootstrap started.
            start_time <- Sys.time()

            # Reset any previous bootstrapped values before engaging a new one.
            private$.clear_bootstrap()

            # Set boots.
            private$.boots <- boots

            # Decide whether to run in a cluster or sequentially.
            if (!is.null(cores) && cores > 1) {
                # How many cores are available on the machine?
                max_cores <- parallel::detectCores()

                # Validate number of cores provided.
                if (cores >= max_cores) {
                    # Set to max available cores less one.
                    cores <- max_cores - 1
                }

                # Run the bootstrap in parallel.
                private$.bootstrap_parallel(boots, cores)
            } else {
                # Run the bootstrap sequentially.
                private$.bootstrap(boots)
            }

            # Compute how long the bootstrap took.
            private$.duration <- Sys.time() - start_time
        },

        # Compute confidence intervals.
        compute = function(lower = 0.025, upper = 0.975, cores = NULL) {
            # Time when the bootstrap started.
            start_time <- Sys.time()

            # Reset any previous CI before computing new ones.
            private$.clear_ci()

            # Decide whether to run in a cluster or sequentially.
            if (!is.null(cores) && cores > 1) {
                # How many cores are available on the machine?
                max_cores <- parallel::detectCores()

                # Validate number of cores provided.
                if (cores >= max_cores) {
                    # Set to max available cores less one.
                    cores <- max_cores - 1
                }

                # Compute confidence intervals for the entire spline in parallel.
                private$.compute_spline_ci_parallel(lower, upper, cores)
            } else {
                # Compute confidence intervals for the entire spline sequentially.
                private$.compute_spline_ci(lower, upper)
            }

            # Compute how long the bootstrap took.
            private$.duration <- Sys.time() - start_time

            # Extract the confidence intervals for the sufficient sample sizes.
            private$.extract_sufficient_samples(private$.step_2$step_1$statistic_value)
        },

        plot = function() {
            # Revert the changes on exit.
            on.exit({
                # Restore layout.
                layout(1:1)

                # Restore margins to default.
                par(mar = c(5.1, 4.1, 4.1, 2.1))
            })

            # Layout.
            layout_matrix <- matrix(1, 3, 3)
            layout_matrix[3, 3] <- 2
            layout(layout_matrix)

            # Adjust margins for layout.
            par(mar = c(5.1, 4.1, 4.1, 2.1) + 1)

            # Plot spline and confidence intervals.
            plot(
                NULL,
                xlim = c(min(private$.step_2$step_1$range$partition), max(private$.step_2$step_1$range$partition)),
                ylim = c(min(private$.spline_ci), max(private$.spline_ci) + 0.15),
                xlab = "",
                ylab = "",
                xaxt = "n",
                yaxt = "n"
            )
            title(
                main = paste0("Bootstrap CI (Percentile Method)"),
                ylab = paste0("Value for statistic '", toupper(sub("Statistic", "", class(private$.step_2$step_1$statistic)[1])), "'"),
                cex.lab = 1,
                cex.main = 1
            )
            title(
                xlab = "Sample size",
                cex.lab = 1,
                line = 4
            )
            axis(
                side = 1,
                at = private$.step_2$step_1$range$partition,
                las = 2,
                cex.axis = .9
            )
            axis(
                side = 2,
                cex.axis = .9
            )
            abline(
                h = private$.step_2$step_1$statistic_value,
                col = "#2c2c2c",
                lty = 3
            )
            polygon(
                x = c(private$.step_2$interpolation$x, private$.step_2$interpolation$x[order(private$.step_2$interpolation$x, decreasing = TRUE)]),
                y = c(private$.spline_ci[, "0%"], private$.spline_ci[, "100%"][order(private$.spline_ci[, "100%"], decreasing = TRUE)]),
                col = "#bc8f8f52",
                border = NA
            )
            polygon(
                x = c(private$.step_2$interpolation$x, private$.step_2$interpolation$x[order(private$.step_2$interpolation$x, decreasing = TRUE)]),
                y = c(private$.spline_ci[, "2.5%"], private$.spline_ci[, "97.5%"][order(private$.spline_ci[, "97.5%"], decreasing = TRUE)]),
                col = "#4683b455",
                border = NA
            )
            points(
                private$.step_2$step_1$range$partition,
                private$.step_2$step_1$statistics,
                pch = 19
            )
            lines(
                private$.step_2$interpolation$x,
                private$.step_2$interpolation$fitted,
                col = "darkred",
                lwd = 2
            )

            # Display CI for current statistic value.
            segments(
                x0 = c(private$.sufficient_samples["2.5%"], private$.sufficient_samples["97.5%"]),
                y0 = c(min(private$.spline_ci), min(private$.spline_ci)) + 0.05,
                x1 = c(private$.sufficient_samples["2.5%"], private$.sufficient_samples["97.5%"]),
                y1 = c(private$.step_2$step_1$statistic_value, private$.step_2$step_1$statistic_value),
                col = "#1c5b8f",
                lty = 2,
                lwd = 2
            )
            segments(
                x0 = c(private$.sufficient_samples["0%"], private$.sufficient_samples["100%"]),
                y0 = c(min(private$.spline_ci), min(private$.spline_ci)),
                x1 = c(private$.sufficient_samples["0%"], private$.sufficient_samples["100%"]),
                y1 = c(private$.step_2$step_1$statistic_value, private$.step_2$step_1$statistic_value),
                col = "#bc8f8fb9",
                lty = 3,
                lwd = 1
            )
            segments(
                x0 = private$.sufficient_samples["2.5%"],
                y0 = private$.step_2$step_1$statistic_value,
                x1 = private$.sufficient_samples["97.5%"],
                y1 = private$.step_2$step_1$statistic_value,
                col = "#1c5b8f",
                lty = 2,
                lwd = 2
            )
            segments(
                x0 = private$.sufficient_samples["0%"],
                y0 = private$.step_2$step_1$statistic_value,
                x1 = private$.sufficient_samples["2.5%"],
                y1 = private$.step_2$step_1$statistic_value,
                col = "darkred",
                lty = 3,
                lwd = 1
            )
            segments(
                x0 = private$.sufficient_samples["97.5%"],
                y0 = private$.step_2$step_1$statistic_value,
                x1 = private$.sufficient_samples["100%"],
                y1 = private$.step_2$step_1$statistic_value,
                col = "darkred",
                lty = 3,
                lwd = 1
            )
            text(
                c(private$.sufficient_samples["2.5%"], private$.sufficient_samples["97.5%"]),
                c(min(private$.spline_ci), min(private$.spline_ci)),
                c(private$.sufficient_samples["2.5%"], private$.sufficient_samples["97.5%"]),
                col = "#1c5b8f",
                font = 2,
                cex = 1,
                srt = 90
            )
            legend(
                "topleft",
                title = expression(bold("Bootstrapped splines")),
                legend = c("0% to 100%", "2.5% to 97.5%"),
                fill = c("#bc8f8f52", "#4683b455"),
                density = c(NA, NA),
                bty = "n",
                border = c("#bc8f8f52", "#4683b455"),
                cex = 1
            )
        }
    ),

    active = list(
        step_2 = function() { return(private$.step_2) },
        boots = function() { return(private$.boots) },
        boot_splines = function() { return(private$.boot_splines) },
        spline_ci = function() { return(private$.spline_ci) },
        sufficient_samples = function() { return(private$.sufficient_samples) },
        duration = function() { return(private$.duration) }
    )
)
