#' @include Range.R StepOne.R

Validation <- R6::R6Class("Validation",
    private = list(
        .backend = NULL,
        .recommendation = NULL,
        .method = NULL,
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

            # Construct the method iteration progress bar message.
            run_message <- paste0(
                "Validating for sample `", sample, "`"
            )

            # Progress bar for Step 1.
            parabar::configure_bar(
                format = paste0(run_message, " | ", "[:bar] [:percent] [:elapsed]")
            )

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
                warning("Parallelization backend not active. The validation will run sequentially.")
            } else {
                # Register the backend.
                private$.backend <- backend
            }
        },

        # Prepare for validation.
        configure_validator = function(method, ci = 0.5) {
            # Store the method for convenience.
            private$.method <- method

            # Extract and store the recommended sample size.
            private$.set_recommendation(method$step_3, ci)

            # Configure the `validator` instance.
            private$.configure_validator(method$step_3)
        },

        # Perform the validation.
        run = function(sample = NULL, replications = 3000) {
            # If no sample is provided, then use the recommendation.
            if(is.null(sample)) {
                sample <- private$.recommendation
            }

            # Run.
            private$.run(sample, replications)
        }
    ),

    active = list(
        recommendation = function() { return(private$.recommendation) },
        method = function() { return(private$.method) },
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
