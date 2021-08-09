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

            # Run bootstrap.
            private$.boot_statistics <- t(
                backend$sapply(seq_len(boots), boot, available_samples, measures, measure_value, replications, extended_basis, statistic, solver)
            )
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
            # Compute the confidence intervals via the percentile method.
            private$.ci <- t(
                backend$apply(private$.boot_statistics, 2, quantile, probs = c(0, lower_ci, .5, upper_ci, 1), na.rm = TRUE)
            )

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
            private$.duration <- Sys.time() - start_time
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
            private$.duration <- Sys.time() - start_time

            # Extract the confidence intervals for the sufficient sample sizes.
            private$.extract_sufficient_samples(private$.step_2$step_1$statistic_value)
        },

        # Get bootstrapped spline values for a given sample size.
        get_statistics = function(sample) {
            return(private$.boot_statistics[, which(private$.step_2$interpolation$x == sample)])
        },

        # Plot.
        plot = function() {
            # Revert the changes on exit.
            on.exit({
                # Restore layout.
                layout(1:1)

                # Restore margins to default.
                par(mar = c(5.1, 4.1, 4.1, 2.1))
            })

            # Layout.
            layout(matrix(c(1, 1, 2, 3), 2, 2, byrow = TRUE))

            # Adjust margins for layout.
            par(mar = c(5.1, 4.1, 4.1, 2.1) + 1)

            # Plot spline and confidence intervals.
            plot(
                NULL,
                xlim = c(min(private$.step_2$step_1$range$partition), max(private$.step_2$step_1$range$partition)),
                ylim = c(min(private$.ci) - 0.2, max(private$.ci) + 0.2),
                xlab = "",
                ylab = "",
                xaxt = "n",
                yaxt = "n",
                cex = 1
            )
            title(
                main = paste0("Bootstrap CI | Distance: ", private$.samples[self$upper_ci_string] - private$.samples[self$lower_ci_string], " sample sizes"),
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
                at = round(seq(min(private$.ci), max(private$.ci), length.out = 10), 2),
                side = 2,
                las = 2,
                cex.axis = .9
            )
            abline(
                h = private$.step_2$step_1$statistic_value,
                v = private$.samples["50%"],
                col = "#2c2c2c",
                lty = 3
            )
            polygon(
                x = c(private$.step_2$interpolation$x, private$.step_2$interpolation$x[order(private$.step_2$interpolation$x, decreasing = TRUE)]),
                y = c(private$.ci[, "0%"], private$.ci[, "100%"][order(private$.ci[, "100%"], decreasing = TRUE)]),
                col = "#bc8f8f52",
                border = NA
            )
            polygon(
                x = c(private$.step_2$interpolation$x, private$.step_2$interpolation$x[order(private$.step_2$interpolation$x, decreasing = TRUE)]),
                y = c(private$.ci[, self$lower_ci_string], private$.ci[, self$upper_ci_string][order(private$.ci[, self$upper_ci_string], decreasing = TRUE)]),
                col = "#4683b48e",
                border = NA
            )
            points(
                col = "#00000070",
                private$.step_2$step_1$range$partition,
                private$.step_2$step_1$statistics,
                pch = 19,
                cex = .8
            )
            lines(
                private$.step_2$interpolation$x,
                private$.step_2$interpolation$fitted,
                col = "#000000ad",
                lwd = 2
            )

            # Display CI for current statistic value.
            segments(
                x0 = c(private$.samples[self$lower_ci_string], private$.samples[self$upper_ci_string]),
                y0 = c(min(private$.ci), min(private$.ci)) + 0.0,
                x1 = c(private$.samples[self$lower_ci_string], private$.samples[self$upper_ci_string]),
                y1 = c(private$.step_2$step_1$statistic_value, private$.step_2$step_1$statistic_value),
                col = "#1c5b8f",
                lty = 3,
                lwd = 2
            )
            segments(
                x0 = private$.samples[self$lower_ci_string],
                y0 = private$.step_2$step_1$statistic_value,
                x1 = private$.samples[self$upper_ci_string],
                y1 = private$.step_2$step_1$statistic_value,
                col = "#1c5b8f",
                lty = 3,
                lwd = 2
            )
            text(
                c(private$.samples[self$lower_ci_string], private$.samples[self$upper_ci_string]),
                c(min(private$.ci), min(private$.ci)) - 0.1,
                c(private$.samples[self$lower_ci_string], private$.samples[self$upper_ci_string]),
                col = "#000000",
                font = 2,
                cex = .9,
                srt = 90,
                offset = 0
            )
            legend(
                "topleft",
                title = expression(bold("Bootstrapped splines")),
                legend = c("0% to 100%", paste0(self$lower_ci_string, " to ", self$upper_ci_string)),
                fill = c("#bc8f8f52", "#4683b455"),
                density = c(NA, NA),
                bty = "n",
                border = c("#bc8f8f52", "#4683b48e"),
                cex = 1
            )

            # Sample size of interest.
            sample <- private$.samples["50%"]

            # Bootstrapped statistics values for the sample size of interest.
            boot_statistics <- self$get_statistics(sample)

            # Median and confidence intervals.
            boot_statistics_median <- quantile(boot_statistics, .5)
            boot_statistics_ci <- quantile(boot_statistics, c(0.025, 0.975))

            # Plot histogram of statistics.
            hist(
                boot_statistics,
                col = "#00000023",
                border = FALSE,
                main = paste0("Sample: ", sample, " | ", "Quantile: ", 0.5 * 100, "th"),
                xaxt = "n",
                xlab = ""
            )
            title(
                xlab = "Bootstrapped statistics",
                line = 4.5,
                cex.main = 1,
                cex.lab = 1
            )
            axis(
                side = 1,
                at = round(seq(min(boot_statistics), max(boot_statistics), by = 0.001), 2),
                line = 1.5,
                las = 2,
                cex.axis = .9
            )
            # Confidence intervals.
            abline(v = boot_statistics_ci, col = "#5f5f5f", lty = 3)
            mtext(round(boot_statistics_ci, 3), side = 1, at = boot_statistics_ci, col = "rosybrown", font = 2, line = 0.3, cex = .8)
            # Median.
            abline(v = boot_statistics_median, col = "#5f5f5f", lty = 3)
            mtext(round(boot_statistics_median, 3), side = 1, at = boot_statistics_median, col = "rosybrown",  font = 2, line = 0.3, cex = .9)

            # Plot quantiles of bootstrapped statistics.
            plot(
                private$.step_2$step_1$range$sequence,
                private$.ci[, "50%"],
                type = "l",
                lwd = 2,
                main = paste0("Quantiles (", 0.5 * 100, "th)"),
                ylab = paste0("Bootstrapped statistics"),
                xlab = "",
                xaxt = "n",
                yaxt = "n"
            )
            title(
                xlab = "Sample sizes",
                line = 4.5,
                cex.lab = 1,
                cex.main = 1
            )
            axis(
                side = 1,
                at = floor(seq(min(private$.step_2$step_1$range$sequence), max(private$.step_2$step_1$range$sequence), length.out = 15)),
                line = 1.5,
                las = 2,
                cex.axis = .9
            )
            axis(
                side = 2,
                at = round(seq(min(private$.ci[, "50%"]), max(private$.ci[, "50%"]), length.out = 10), 2),
                las = 2,
                cex.axis = .9
            )
            abline(h = private$.step_2$step_1$statistic_value, v = sample, lty = 2, col = "#5f5f5f")
            mtext(sample, side = 1, at = sample, col = "darkgreen", font = 2, line = 0.3, cex = .9)
        }
    ),

    active = list(
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
