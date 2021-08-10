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
        plot = function() {
            # Revert the changes on exit.
            on.exit({
                # Restore margins to default.
                par(mar = c(5.1, 4.1, 4.1, 2.1))
            })

            # Adjust margins for layout.
            par(mar = c(5.1, 4.1, 4.1, 2.1) + 1)

            # Plot histogram of performance measures.
            hist(
                private$.validator$measures,
                col = "#00000023",
                border = FALSE,
                main = paste0("Sample: ", private$.validator$range$partition, " | ",
                              "Measure at ", self$percentile, " pert.: ", round(self$percentile_value, 3), " | ",
                              "Statistic: ", round(private$.validator$statistics, 3)),
                xaxt = "n",
                xlab = ""
            )
            title(
                xlab = paste0("Performance measure values (", toupper(private$.validator$measure_type), ")"),
                line = 4.5,
                cex.main = 1,
                cex.lab = 1
            )
            axis(
                side = 1,
                at = round(seq(min(private$.validator$measures), max(private$.validator$measures), length.out = 15), 2),
                line = 1.5,
                las = 2,
                cex.axis = .9
            )
            # Value at percentile of interest,
            abline(v = self$percentile_value, lwd = 2, lty = 3, col = "darkred")
            mtext(round(self$percentile_value, 3), side = 1, at = self$percentile_value, col = "darkred", font = 2, line = 0.3, cex = 1)
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
