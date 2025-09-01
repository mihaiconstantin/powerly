# `S3` methods.

#' @template plot-Step
#' @templateVar step_class StepOne
#' @templateVar step_number 1
#' @export
plot.StepOne <- function(x, save = FALSE, path = NULL, width = 14, height = 10, ...) {
    # Store a reference to `x` with a more informative name.
    object <- x

    # Fetch plot settings.
    .__PLOT_SETTINGS__  <- plot_settings()

    # Create data frame for the boxplot.
    data_measures <- data.frame(
        measure = as.numeric(object$measures),
        sample = as.factor(sort(rep(object$range$partition, object$replications)))
    )

    # Create data frame for the computed statistics.
    data_statistics <- data.frame(
        sample = as.factor(object$range$partition),
        statistic = object$statistics
    )

    # Common theme settings for both plots.
    .__PLOT_SETTINGS__ <- c(.__PLOT_SETTINGS__, list(
        ggplot2::scale_y_continuous(breaks = seq(0, 1, .1))
    ))

    # Create the measures plot.
    plot_measures <- ggplot2::ggplot(data_measures, ggplot2::aes(x = .data$sample, y = .data$measure)) +
        ggplot2::geom_boxplot(
            fill = "#e6e6e6",
            width = .6,
            outlier.colour = "#bebebe"
        ) +
        ggplot2::geom_hline(
            yintercept = object$measure_value,
            color = "#8b0000",
            linetype = "dotted",
            size = .65
        ) +
        ggplot2::labs(
            title = paste0("Monte Carlo Replications ", "(", object$replications, ")"),
            x = "Selected Sample Size",
            y = "Performance Measure Value"
        ) +
        .__PLOT_SETTINGS__

    plot_statistics <- ggplot2::ggplot(data_statistics, ggplot2::aes(x = .data$sample, y = .data$statistic)) +
        ggplot2::geom_point(
            fill = "#3f51b5",
            color = "#3f51b5",
            size = 1.5,
            shape = 23
        ) +
        ggplot2::geom_hline(
            yintercept = object$statistic_value,
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


#' @template plot-Step
#' @templateVar step_class StepTwo
#' @templateVar step_number 2
#' @export
plot.StepTwo <- function(x, save = FALSE, path = NULL, width = 14, height = 10, ...) {
    # Store a reference to `x` with a more informative name.
    object <- x

    # Data statistic.
    data_statistics <- data.frame(
        x = object$step_1$range$partition,
        observed = object$step_1$statistics,
        predicted = object$spline$fitted
    )

    # Data spline values.
    data_spline_values <- data.frame(
        x = object$interpolation$x,
        y = object$interpolation$fitted
    )

    # Data spline coefficients.
    data_spline_alpha <- data.frame(
        x = as.factor(1:ncol(object$spline$basis$matrix)),
        y = object$spline$alpha
    )

    # Data basis matrix.
    data_spline_basis <- data.frame(
        x = as.factor(rep(object$spline$basis$x, ncol(object$spline$basis$matrix))),
        y = as.numeric(object$spline$basis$matrix),
        basis = as.factor(sort(rep(1:ncol(object$spline$basis$matrix), nrow(object$spline$basis$matrix))))
    )

    # Data cross-validation.
    data_cv <- data.frame(
        df = sort(rep(object$cv$df, nrow(object$cv$se))),
        se = as.numeric(object$cv$se),
        sample = rep(object$spline$basis$x, ncol(object$cv$se)),
        mse_df = rep(object$cv$mse, each = nrow(object$cv$se)),
        mse_sample = rep(apply(object$cv$se, 1, mean), ncol(object$cv$se)),
        first_se_sample = rep(object$cv$se[, 1], ncol(object$cv$se)),
        first_se_df = rep(object$cv$se[1, ], each = nrow(object$cv$se))
    )

    # Common plot theme settings.
    .__PLOT_SETTINGS__ <- c(plot_settings(), list(
        ggplot2::theme(
            legend.position = "none"
        )
    ))

    # Spline plot.
    plot_spline <- ggplot2::ggplot(data_spline_values, ggplot2::aes(x = .data$x, y = .data$y)) +
        ggplot2::geom_line(
            size = 1,
            color = "rosybrown"
        ) +
        ggplot2::geom_point(
            data = data_statistics,
            mapping = ggplot2::aes(x = .data$x, y = .data$observed),
            fill = "#3f51b5",
            color = "#3f51b5",
            size = 1.5,
            shape = 23
        ) +
        ggplot2::geom_point(
            data = data_statistics,
            mapping = ggplot2::aes(x = .data$x, y = .data$predicted),
            fill = "#7c2929",
            color = "#7c2929",
            size = 1.5,
            shape = 19
        ) +
        ggplot2::geom_hline(
            yintercept = object$step_1$statistic_value,
            color = "#8b0000",
            linetype = "dotted",
            size = .65
        ) +
        ggplot2::labs(
            title = paste0("Fitted spline | DF = ",  object$spline$basis$df, " | SSQ = ", round(object$ssq, 4)),
            x = "Candidate Sample Size Range",
            y = "Statistic Value"
        ) +
        ggplot2::scale_y_continuous(
            breaks = seq(0, 1, .1)
        ) +
        ggplot2::scale_x_continuous(
            breaks = object$step_1$range$partition
        ) +
        .__PLOT_SETTINGS__

    plot_coefficients <- ggplot2::ggplot(data_spline_alpha, ggplot2::aes(x = .data$x, y = .data$y)) +
        ggplot2::geom_point(
            shape = 17,
            size = 1.5,
            color = "darkred",
            fill = "darkred"
        ) +
        ggplot2::geom_text(
            mapping = ggplot2::aes(y = .data$y - .04),
            label = round(data_spline_alpha$y, 2),
            fontface = "bold",
            size = 2.8
        ) +
        ggplot2::geom_hline(
            yintercept = 0,
            color = "#2c2c2c",
            linetype = "dotted",
            size = .65,
            alpha = .7
        ) +
        ggplot2::coord_cartesian(
            ylim = c(min(data_spline_alpha$y) - .2, max(data_spline_alpha$y) + .2)
        ) +
        ggplot2::scale_y_continuous(
            breaks = round(seq(min(data_spline_alpha$y) - .2, max(data_spline_alpha$y) + .2, .2), 2)
        ) +
        ggplot2::labs(
            title = "Spline coefficients",
            x = "Basis function",
            y = "Spline coefficient value"
        ) +
        .__PLOT_SETTINGS__

    plot_basis <- ggplot2::ggplot(data_spline_basis, ggplot2::aes(x = .data$x, y = .data$y, color = .data$basis, group = .data$basis)) +
        ggplot2::geom_line(
            mapping = ggplot2::aes(lty = .data$basis),
            size = .7
        ) +
        ggplot2::labs(
            title = "Basis matrix",
            x = "Sample size",
            y = "Basis function value"
        ) +
        .__PLOT_SETTINGS__

    plot_cv <- ggplot2::ggplot(data_cv, ggplot2::aes(x = .data$df, y = .data$se, color = as.factor(.data$sample))) +
        ggplot2::geom_line(
            size = .75,
            alpha = .15
        ) +
        ggplot2::geom_point(
            size = 1,
            shape = 19,
            alpha = .15,
        ) +
        ggplot2::geom_line(
            mapping = ggplot2::aes(
                y = .data$mse_df
            ),
            size = 1,
            color = "#000000"
        ) +
        ggplot2::geom_point(
            mapping = ggplot2::aes(
                y = .data$mse_df
            ),
            size = 1.5,
            shape = 19,
            color = "#000000"
        ) +
        ggplot2::geom_text(
            mapping = ggplot2::aes(
                x = min(.data$df) - .75,
                y = .data$first_se_sample,
                label = .data$sample
            ),
            size = 2.8,
            alpha = .05
        ) +
        ggplot2::geom_vline(
            xintercept = data_cv$df[which.min(data_cv$mse_df)],
            color = "#2c2c2c",
            linetype = "dotted",
            size = .65,
            alpha = .7
        ) +
        ggplot2::scale_x_continuous(
            breaks = unique(data_cv$df)
        ) +
        ggplot2::labs(
            title = "LOOCV | SE (color) | MSE (dark)",
            x = "Spline degrees of freedom",
            y = "Squared error"
        ) +
        .__PLOT_SETTINGS__

    plot_cv_error <- ggplot2::ggplot(data_cv, ggplot2::aes(x = .data$sample, y = .data$se, color = as.factor(.data$df))) +
        ggplot2::geom_line(
            size = .75,
            alpha = .15
        ) +
        ggplot2::geom_point(
            size = 1,
            shape = 19,
            alpha = .15,
        ) +
        ggplot2::geom_line(
            mapping = ggplot2::aes(
                y = .data$mse_sample
            ),
            size = 1,
            color = "#000000"
        ) +
        ggplot2::geom_point(
            mapping = ggplot2::aes(
                y = .data$mse_sample
            ),
            size = 1.5,
            shape = 19,
            color = "#000000"
        ) +
        ggplot2::geom_text(
            mapping = ggplot2::aes(
                x = min(.data$sample) - (.data$sample[2] - .data$sample[1]) * .6,
                y = .data$first_se_df,
                label = .data$df
            ),
            size = 2.8,
            alpha = .05
        ) +
        ggplot2::scale_x_continuous(
            breaks = object$step_1$range$partition
        ) +
        ggplot2::labs(
            title = "Training prediction | SE (color) | MSE (dark)",
            y = "Squared error",
            x = "Sample size"
        ) +
        .__PLOT_SETTINGS__

    # Define the margins.
    margin_plot_top <- ggplot2::theme(plot.margin = ggplot2::margin(t = 0, r = 0, b = 0, l = 0))
    margin_plot_left <- ggplot2::theme(plot.margin = ggplot2::margin(t = 15, r = 7.5, b = 0, l = 0))
    margin_plot_right <- ggplot2::theme(plot.margin = ggplot2::margin(t = 15, r = 0, b = 0, l = 7.5))

    # Adjust plot margins.
    plot_spline <- plot_spline & margin_plot_top
    plot_coefficients <- plot_coefficients & margin_plot_left
    plot_basis <- plot_basis & margin_plot_right
    plot_cv <- plot_cv & margin_plot_left
    plot_cv_error <- plot_cv_error & margin_plot_right

    # Prepare plot layout.
    plot_step_2 <- plot_spline /
        (plot_coefficients | plot_basis) /
        (plot_cv | plot_cv_error) +
        plot_layout(heights = c(1.5, 1, 1))

    # Save the plot.
    if (save) {
        if (is.null(path)) {
            # If no path is provided, create one.
            path <- paste0(getwd(), "/", "step-2", "_", gsub(":|\\s", "-", as.character(Sys.time()), perl = TRUE), ".pdf")
        }

        # Save the plot.
        ggplot2::ggsave(path, plot = plot_step_2, width = width, height = height, ...)
    } else {
        # Show the plot.
        plot(plot_step_2)
    }

    # Return the plot object silently.
    invisible(plot_step_2)
}


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
            paste0("0% - 100%", " (", abs(object$samples["100%"] - object$samples["0%"]), " sample sizes)"),
            paste0(object$lower_ci_string, " - ", object$upper_ci_string, " (", abs(object$samples[object$upper_ci_string] - object$samples[object$lower_ci_string]), " sample sizes)")
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

    # Legend position.
    if (object$step_2$spline$solver$increasing) {
        bands_legend_position <- c(0, 1)
        bands_legend_justification <- c(0, 1)
    } else {
        bands_legend_position <- c(1, 1)
        bands_legend_justification <- c(1, 1)
    }

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
            legend.position = bands_legend_position,
            legend.justification = bands_legend_justification,
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


#' @template plot-Validation
#' @export
plot.Validation <- function(x, save = FALSE, path = NULL, width = 14, height = 10, bins = 20, ...) {
    # Store a reference to `x` with a more informative name.
    object <- x

    # Fetch plot settings.
    .__PLOT_SETTINGS__ <- c(plot_settings(), list(
        ggplot2::scale_x_continuous(
            breaks = round(seq(min(object$measures), max(object$measures), by = .05), 2)
        )
    ))

    # Make histogram plot.
    plot_histogram <- ggplot2::ggplot(mapping = ggplot2::aes(x = .env$object$measures)) +
        ggplot2::geom_histogram(
            bins = 20,
            fill = "#4d4d4d",
            color = "#4d4d4d",
            alpha = .15
        ) +
        ggplot2::labs(
            title = paste0(
                "Performance Measure Distribution", " | ",
                "Sample: ", object$sample, " | ",
                "Statistic: ", format(round(object$statistic, 3), nsmall = 3)
            ),
            y = "Count",
            x = "Performance Measure Value"
        ) +
        .__PLOT_SETTINGS__

    # Make ECDF plot.
    plot_ecdf <- ggplot2::ggplot(mapping = ggplot2::aes(x = .env$object$measures)) +
        ggplot2::stat_ecdf(
            geom = "step",
            size = 1,
            linetype = "solid",
            pad = FALSE
        ) +
        ggplot2::geom_vline(
            xintercept = object$validator$measure_value,
            color = "#2c2c2c",
            linetype = "dotted",
            alpha = .7,
            size = .65
        ) +
        ggplot2::geom_hline(
            yintercept = 1 - object$validator$statistic_value,
            color = "#2c2c2c",
            linetype = "dotted",
            alpha = .7,
            size = .65
        ) +
        ggplot2::geom_point(
            mapping = ggplot2::aes(
                x = .env$object$validator$measure_value,
                y = 1 - .env$object$validator$statistic_value
            ),
            fill = "#7c2929",
            color = "#7c2929",
            size = 1.3,
            shape = 23
        ) +
        ggplot2::scale_y_continuous(
            breaks = seq(0, 1, .1)
        ) +
        ggplot2::labs(
            title = paste0(
                "ECDF", " | ",
                "Performance Measure Value at ", object$percentile, " Percentile: ", format(round(object$percentile_value, 3), nsmall = 3)
            ),
            y = "Probability",
            x = "Performance Measure Value"
        ) +
        .__PLOT_SETTINGS__

    # Set plot spacing.
    plot_histogram <- plot_histogram & ggplot2::theme(plot.margin = ggplot2::margin(t = 0, r = 0, b = 0, l = 0))
    plot_ecdf <- plot_ecdf & ggplot2::theme(plot.margin = ggplot2::margin(t = 15, r = 0, b = 0, l = 0))

    # Arrange the plots together.
    plot_validation <- plot_histogram /
        plot_ecdf

    # Save the plot.
    if (save) {
        if (is.null(path)) {
            # If no path is provided, create one.
            path <- paste0(getwd(), "/", "validation", "_", gsub(":|\\s", "-", as.character(Sys.time()), perl = TRUE), ".pdf")
        }

        # Save the plot.
        ggplot2::ggsave(path, plot = plot_validation, width = width, height = height, ...)
    } else {
        # Show the plot.
        plot(plot_validation)
    }

    # Return the plot object silently.
    invisible(plot_validation)
}


#' @template summary-Validation
#' @export
summary.Validation <- function(object, ...) {
    # Extract the measure type.
    measure <- object$method$step_1$measure_type

    # Extract the statistic type.
    statistic <- object$method$step_1$statistic_type

    # Extract the measure target.
    measure_target <- object$method$step_1$measure_value

    # Extract the statistic target.
    statistic_target <- object$method$step_1$statistic_value

    # Print the results.
    cat("\n", "Validation completed:", sep = "")
    cat("\n", " - duration: ", round(object$validator$duration, 2), " seconds", sep = "")
    cat("\n", " - sample: ", object$sample, sep = "")
    cat("\n", " - statistic: ", round(object$statistic, 3), " (target: ", statistic_target, ")", sep = "")
    cat("\n", " - measure at ", object$percentile, " percentile: ", round(object$percentile_value, 3), " (target: ", measure_target, ")", "\n", sep = "")

    # If the validation results are not satisfactory, inform the user.
    if (object$statistic < statistic_target || object$percentile_value < measure_target) {
        # Extract a larger recommended sample size.
        larger_sample <- object$method$recommendation["97.5%"]

        # Construct the feedback message.
        feedback <- paste0(
            "The validation results are below the target values.", "\n",
            "Consider running the validation with a larger sample size ",
            "(e.g., `sample = ", larger_sample, "`)."
        )

        # Print the message.
        message("\n", feedback, sep = "")
    }
}


#' @template plot-Method
#' @export
plot.Method <- function(x, step = 3, last = TRUE, save = FALSE, path = NULL, width = 14, height = 10, ...) {
    # Store a reference to `x` with a more informative name.
    object <- x

    # Determine which iteration should be plotted.
    if (last) {
        # Plot the right step from the last iteration.
        if (step == 1) {
            plot.StepOne(object$step_1, save = save, path = path, width = width, height = height, ...)
        } else if (step == 2) {
            plot.StepTwo(object$step_2, save = save, path = path, width = width, height = height, ...)
        } else if (step == 3) {
            plot.StepThree(object$step_3, save = save, path = path, width = width, height = height, ...)
        } else {
            stop("Incorrect step specification.")
        }
    } else {
        # Prevent plotting of previous results if it converged on first iteration.
        if (object$iteration > 1) {
            # Plot the right step from the previous iteration.
            if (step == 1) {
                plot.StepOne(object$previous$step_2$step_1, save = save, path = path, width = width, height = height, ...)
            } else if (step == 2) {
                plot.StepTwo(object$previous$step_2, save = save, path = path, width = width, height = height, ...)
            } else if (step == 3) {
                plot.StepThree(object$previous, save = save, path = path, width = width, height = height, ...)
            } else {
                stop("Incorrect step specification.")
            }
        } else {
            warning("No previous results. Method converged on first iteration.")
        }
    }
}


#' @template summary-Method
#' @export
summary.Method <- function(object, ...) {
    # Extract the measure type.
    measure <- object$step_1$measure_type

    # Extract the statistic type.
    statistic <- object$step_1$statistic_type

    # Extract the measure value.
    measure_value <- object$step_1$measure_value

    # Extract the statistic value.
    statistic_value <- object$step_1$statistic_value

    # Print the results.
    cat("\n", "Method completed:", sep = "")
    cat("\n", " - duration: ", round(object$duration, 2), " seconds", sep = "")
    cat("\n", " - converged: ", ifelse(object$converged, "yes", "no"), " (", object$iteration, " iterations)", sep = "")
    cat("\n", " - performance measure: `", measure, "` (target: ", measure_value, ")", sep = "")
    cat("\n", " - statistic: `", statistic, "` (target: ", statistic_value, ")", sep = "")
    cat("\n", " - sample size recommendation: ",
        paste(paste(
            names(object$step_3$samples[c("2.5%", "50%", "97.5%")]),
            "=", object$step_3$samples[c("2.5%", "50%", "97.5%")],
            sep = " "
        ), collapse = " | "),
        "\n",
        sep = ""
    )

    # Prepare user feedback messages.
    feedback <- character()

    # Warn the user about choosing a low performance measure target.
    if (measure_value < 0.8) {
        # Store the feedback.
        feedback <- c(feedback,
            paste0(
                "The performance measure target `measure_value = ", measure_value, "` may be too low for meaningful results."
            )
        )
    }

    # Warn the user about choosing a low statistic target.
    if (statistic_value < 0.8) {
        # Store the feedback.
        feedback <- c(feedback,
            paste0(
                "The statistic target `statistic_value = ", statistic_value, "` may be too low for reliable results."
            )
        )
    }

    # If warning feedback need to be printed.
    if (length(feedback) > 0) {
        # Print them.
        message("\n", paste(feedback, collapse = "\n"), sep = "")
    }
}
