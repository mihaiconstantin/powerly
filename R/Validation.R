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
        },

        # Plot the validation results.
        plot = function(save = FALSE, path = NULL, width = 14, height = 10, bins = 20, ...) {
            # Fetch plot settings.
            .__PLOT_SETTINGS__ <- plot_settings()

            # Make the histogram plot.
            plot_validation <- ggplot2::ggplot(mapping = ggplot2::aes(x = self$measures)) +
                ggplot2::geom_histogram(
                    bins = bins,
                    color = "#4d4d4d",
                    fill = "#4d4d4d",
                    alpha = 0.2
                ) +
                ggplot2::scale_x_continuous(
                    breaks = round(seq(min(self$measures), max(self$measures), by = 0.05), 2)
                ) +
                ggplot2::geom_vline(
                    xintercept = self$percentile_value,
                    color = "#8b0000",
                    size = .65
                ) +
                ggplot2::labs(
                    title = paste0(
                        "Sample: ", self$sample, " | ",
                        "Measure at ", self$percentile, " percentile: ", format(round(self$percentile_value, 3), nsmall = 3), " | ",
                        "Statistic: ", format(round(self$statistic, 3), nsmall = 3)
                    ),
                    y = "Count",
                    x = "Performance Measure Value"
                ) +
                .__PLOT_SETTINGS__

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


#' @title
#' Provide a summary of the validation results
#'
#' @description
#' This function summarizes the objects of class `Validation` and provides
#' information.
#'
#' @param object An object instance of class `Validation`.
#'
#' @keywords internal
#'
#' @export
summary.Validation <- function(object, ...) {
    cat("\n", "Validation completed (", as.numeric(round(object$validator$duration, 4)), " sec):", sep = "")
    cat("\n", " - sample: ", object$sample, sep = "")
    cat("\n", " - statistic: ", object$statistic, sep = "")
    cat("\n", " - measure at ", object$percentile, " pert.: ", round(object$percentile_value, 3), sep = "")
}
