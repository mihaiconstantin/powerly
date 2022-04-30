#' @include Range.R StepOne.R

Validation <- R6::R6Class("Validation",
    private = list(
        .backend = NULL,
        .recommendation = NULL,
        .validator = NULL,

        # Extract the recommendation for `StepThree` samples.
        .set_recommendation = function(step_3, ci = 0.5) {
            private$.recommendation <- step_3$samples[paste0(ci * 100, "%")]
        },

        # Configure new `StepOne` instance (aka `validator`) based on previous one.
        .configure_validator = function(step_3) {
            # Create instance of `StepOne` that will act as the validator.
            private$.validator <- StepOne$new()

            # Set set the `validator` instance based on the configuration used to obtain the current results.
            private$.validator$set_model(step_3$step_1$model_type)
            private$.validator$set_true_model_parameters(matrix = step_3$step_1$true_model_parameters)
            private$.validator$set_measure(step_3$step_1$measure_type, step_3$step_1$measure_value)
            private$.validator$set_statistic(step_3$step_1$statistic_type, step_3$step_1$statistic_value)
        },

        # Run the validation for a request sample size.
        .run = function(sample, replications) {
            # Create `Range` instance with the recommended sample size.
            range <- Range$new(sample, sample, tolerance = -1)

            # Feed the range to the validator.
            private$.validator$set_range(range)

            # Run the validation.
            private$.validator$simulate(replications, private$.backend)

            # Compute the statistics.
            private$.validator$compute()
        }
    ),

    public = list(
        # Register backend.
        register_backend = function(backend) {
            # Make sure we are provided an active backend.
            if (!is.null(backend) && !backend$active) {
                # Warn the users.
                warning("Please provide an active backend. Will not use this one.")
            } else {
                # Register the backend.
                private$.backend <- backend
            }
        },

        # Prepare for validation.
        configure_validator = function(step_3, ci = 0.5) {
            # Extract and store the recommended sample size.
            private$.set_recommendation(step_3, ci)

            # Configure the `validator` instance.
            private$.configure_validator(step_3)
        },

        # Perform the validation.
        run = function(sample, replications = 3000) {
            # If no sample is provided, then use the recommendation.
            if(missing(sample)) {
                sample <- private$.recommendation
            }

            # Run.
            private$.run(sample, replications)
        }
    ),

    active = list(
        recommendation = function() { return(private$.recommendation) },
        validator = function() { return(private$.validator) },
        measures = function() { return(private$.validator$measures) },
        statistic = function() { return(private$.validator$statistics) },
        sample = function() { return(private$.validator$range$partition) },

        # The desired percentile as a string.
        percentile = function() {
            return(paste0((1 - private$.validator$statistic_value) * 100, "th"))
        },

        # The performance measure value at the desired percentile.
        percentile_value = function() {
            return(quantile(private$.validator$measures, probs = 1 - private$.validator$statistic_value))
        }
    )
)


#' @template summary-Validation
#' @export
summary.Validation <- function(object, ...) {
    cat("\n", "Validation completed (", round(object$validator$duration, 4), " sec):", sep = "")
    cat("\n", " - sample: ", object$sample, sep = "")
    cat("\n", " - statistic: ", object$statistic, sep = "")
    cat("\n", " - measure at ", object$percentile, " pert.: ", round(object$percentile_value, 3), sep = "")
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
