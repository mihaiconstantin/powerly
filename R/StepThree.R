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


#' @template plot-Step
#' @templateVar step_class StepThree
#' @templateVar step_number 3
#' @export
plot.StepThree <- function(x, save = FALSE, path = NULL, width = 14, height = 10, ...) {
    # Store a reference to `x` with a more informative name.
    object <- x

    # Data confidence bands.
    data_bands = data.frame(
        x = rep(object$step_2$interpolation$x, 2),
        y = rep(object$step_2$interpolation$fitted, 2),
        lower = as.numeric(object$ci[, c("0%", object$lower_ci_string)]),
        upper = as.numeric(object$ci[, c("100%", object$upper_ci_string)]),
        ci = as.factor(sort(rep(c(
            paste0("0% - 100%", " (", object$samples["100%"] - object$samples["0%"], " sample sizes)"),
            paste0(object$lower_ci_string, " - ", object$upper_ci_string, " (", object$samples[object$upper_ci_string] - object$samples[object$lower_ci_string], " sample sizes)")
        ), nrow(object$ci))))
    )

    # Data segments for bands annotation.
    data_segments <- data.frame(
        x_start = c(object$samples[c(object$lower_ci_string, object$upper_ci_string)], object$samples[object$lower_ci_string]),
        x_end = c(object$samples[c(object$lower_ci_string, object$upper_ci_string)], object$samples[object$upper_ci_string]),
        y_start = c(rep(min(object$ci), 2), object$step_1$statistic_value),
        y_end = rep(object$step_1$statistic_value, 3)
    )

    # Data statistics values for recommended sample.
    data_statistics_recommendation <- object$get_statistics(object$samples["50%"])

    # Plot for the confidence bands.
    plot_bands <- ggplot2::ggplot(data_bands, ggplot2::aes(x = .data$x, y = .data$y)) +
        ggplot2::geom_ribbon(
            mapping = ggplot2::aes(
                ymin = .data$lower,
                ymax = .data$upper,
                fill = .data$ci,
                alpha = .data$ci
            )
        ) +
        ggplot2::geom_line(
            mapping = ggplot2::aes(x = .data$x, y = .data$y),
            size = 1,
            color = "#000000",
            linetype = "solid"
        ) +
        ggplot2::geom_hline(
            yintercept = object$step_1$statistic_value,
            color = "#8b0000",
            linetype = "dotted",
            size = .65
        ) +
        ggplot2::scale_y_continuous(
            breaks = seq(0, 1, .1)
        ) +
        ggplot2::scale_x_continuous(
            breaks = object$step_1$range$partition
        ) +
        ggplot2::scale_fill_manual(
            name = "Confidence Bands",
            values = c("#4d4d4d", "#3e78a7")
        ) +
        ggplot2::scale_alpha_manual(
            name = "Confidence Bands",
            values = c(0.2, 0.5)
        ) +
        ggplot2::labs(
            title = paste0("Bootstrapped Splines", " (", object$boots, " runs)"),
            x = "Sample Size Range",
            y = "Statistic Value"
        ) +
        plot_settings() +
        ggplot2::theme(
            legend.position = c(0.01, 0.99),
            legend.justification = c(0, 1),
            legend.background = ggplot2::element_rect(fill = NA)
        )

    # Add annotations to the bands plot.
    plot_bands <- plot_bands +
        ggplot2::geom_segment(
            data = data_segments,
            ggplot2::aes(
                x = .data$x_start,
                xend = .data$x_end,
                y = .data$y_start,
                yend = .data$y_end
            ),
            linetype = "dashed",
            color = "#265881",
            size = .5
        ) +
        ggplot2::geom_segment(
            ggplot2::aes(
                x = .env$object$samples["50%"],
                xend = .env$object$samples["50%"],
                y = min(.env$data_statistics_recommendation),
                yend = max(.env$data_statistics_recommendation)
            ),
            linetype = "dashed",
            color = "#4d4d4d",
            size = .5
        ) +
        ggplot2::annotate(
            "label",
            x = data_segments[1, 1],
            y = min(object$ci),
            label = data_segments[1, 1],
            color = "#265881"
        ) +
        ggplot2::annotate(
            "label",
            x = data_segments[2, 1],
            y = min(object$ci),
            label = data_segments[2, 1],
            color = "#265881"
        ) +
        ggplot2::annotate(
            "label",
            x = object$samples["50%"],
            y = min(data_statistics_recommendation),
            label = object$samples["50%"],
            color = "#757575"
        )

    # Make and adjust density plots margins.
    plot_density_lower <- object$density_plot(object$samples[object$lower_ci_string]) & ggplot2::theme(plot.margin = ggplot2::margin(t = 15, r = 7.5, b = 0, l = 0))
    plot_density_median <- object$density_plot(object$samples["50%"]) & ggplot2::theme(plot.margin = ggplot2::margin(t = 15, r = 7.5, b = 0, l = 7.5))
    plot_density_upper <- object$density_plot(object$samples[object$upper_ci_string]) & ggplot2::theme(plot.margin = ggplot2::margin(t = 15, r = 0, b = 0, l = 7.5))

    # Adjust margins for top plot.
    plot_bands <- plot_bands & ggplot2::theme(plot.margin = ggplot2::margin(t = 0, r = 0, b = 0, l = 0))

    # Prepare the main plot.
    plot_step_3 <- plot_bands /
        (plot_density_lower | plot_density_median | plot_density_upper) +
        plot_layout(heights = c(1.5, 1))

    # Save the plot.
    if (save) {
        if (is.null(path)) {
            # If no path is provided, create one.
            path <- paste0(getwd(), "/", "step-3", "_", gsub(":|\\s", "-", as.character(Sys.time()), perl = TRUE), ".pdf")
        }

        # Save the plot.
        ggplot2::ggsave(path, plot = plot_step_3, width = width, height = height, ...)
    } else {
        # Show the plot.
        plot(plot_step_3)
    }

    # Return the plot object silently.
    invisible(plot_step_3)
}
