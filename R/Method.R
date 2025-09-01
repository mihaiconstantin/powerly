#' @include Range.R StepOne.R StepTwo.R StepThree.R

Method <- R6::R6Class("Method",
    private = list(
        .start_time = NULL,
        .end_time = NULL,

        .previous = NULL,
        .range = NULL,
        .step_1 = NULL,
        .step_2 = NULL,
        .step_3 = NULL,
        .backend = NULL,

        .iteration = NULL,
        .max_iterations = NULL,

        .verbose = NULL,
        .save_memory = NULL,

        # Set the verbosity level.
        .set_verbosity = function(verbose) {
            # Set verbosity.
            private$.verbose <- verbose
        },

        # Commit the current state at this point in time.
        .commit = function() {
            private$.previous <- private$.step_3$clone(deep = TRUE)
        },

        # Update the iteration counter.
        .update_counter = function() {
            private$.iteration <- private$.iteration + 1
        },

        # Run an iteration.
        .iterate = function(replications, monotone, increasing, df, solver_type, boots, lower_ci, upper_ci) {
            # Construct the method iteration progress bar message.
            run_message <- paste0(
                "Run: ", private$.iteration + 1, "/ ", private$.max_iterations
            )

            # Progress bar for Step 1.
            parabar::configure_bar(
                format = paste0(run_message, " | ", "Step 1: [:bar] [:percent] [:elapsed]")
            )

            # Perform Monte Carlo simulation.
            private$.step_1$simulate(replications, private$.backend)

            # Compute statistics.
            private$.step_1$compute()

            # Fit a spline to the statistics.upper_ci
            private$.step_2$fit(monotone, increasing, df, solver_type)

            # Progress bar for Step 3 (bootstrapping).
            parabar::configure_bar(
                format = paste0(run_message, " | ", "Step 3 (bootstraps): [:bar] [:percent] [:elapsed]")
            )

            # Bootstrap the spline.
            private$.step_3$bootstrap(boots, private$.backend)

            # Progress bar for Step 3 (CIs).
            parabar::configure_bar(
                format = paste0(run_message, " | ", "Step 3 (CIs): [:bar] [:percent] [:elapsed]")
            )

            # Compute the confidence intervals.
            private$.step_3$compute(lower_ci, upper_ci, private$.backend)
        },

        # Run the method.
        .run = function(replications, monotone, increasing, df, solver_type, boots, lower_ci, upper_ci) {
            # Iterate.
            private$.iterate(replications, monotone, increasing, df, solver_type, boots, lower_ci, upper_ci)

            # Update convergence status.
            private$.range$update_convergence(private$.step_3)

            # Increase the counter.
            private$.update_counter()

            while((private$.iteration < private$.max_iterations) && !private$.range$converged) {
                # Store previous results if desired.
                if (!private$.save_memory) private$.previous <- private$.commit()

                # Update the range for a new iteration.
                private$.range$update_bounds(private$.step_3, lower_ci, upper_ci)

                # Iterate.
                private$.iterate(replications, monotone, increasing, df, solver_type, boots, lower_ci, upper_ci)

                # Update convergence status.
                private$.range$update_convergence(private$.step_3)

                # Increase the counter.
                private$.update_counter()
            }
        }
    ),

    public = list(
        initialize = function(max_iterations = 10, verbose = TRUE, save_memory = FALSE) {
            # Set the maximum number of allowed iterations.
            private$.max_iterations <- max_iterations

            # Set the initial iteration counter.
            private$.iteration <- 0

            # Set the verbosity level.
            private$.set_verbosity(verbose)

            # Set the memory preference.
            private$.save_memory <- save_memory
        },

        # Register parallelization backend.
        register_backend = function(backend) {
            # Make sure we are provided an active backend.
            if (!is.null(backend) && !backend$active) {
                # Warn the users.
                warning("Parallelization backend not active. The method will run sequentially.")
            } else {
                # Register the backend.
                private$.backend <- backend
            }
        },

        # Setup

        # Configure range.
        configure_range = function(lower, upper, samples = 20, tolerance = 50) {
            # Make the range.
            private$.range <- Range$new(lower, upper, samples, tolerance)
        },

        # Configure Step 1.
        configure_step_1 = function(model = "ggm", measure = "sen", statistic = "power", measure_value = 0.6, statistic_value = 0.8, ..., matrix = NULL) {
            # Make the step.
            private$.step_1 <- StepOne$new()

            # Configure the step.
            private$.step_1$set_range(private$.range)
            private$.step_1$set_model(model)
            private$.step_1$set_true_model_parameters(..., matrix = matrix)
            private$.step_1$set_measure(measure, measure_value)
            private$.step_1$set_statistic(statistic, statistic_value)
        },

        # Configure Step 2.
        configure_step_2 = function() {
            # Make step.
            private$.step_2 <- StepTwo$new(private$.step_1)
        },

        # Configure Step 3.
        configure_step_3 = function() {
            # Make step.
            private$.step_3 <- StepThree$new(private$.step_2)
        },

        # Run method.
        run = function(replications, monotone = TRUE, increasing = TRUE, df = NULL, solver_type = "quadprog", boots = 3000, lower_ci = 0.025, upper_ci = 0.975) {
            # Do not allow the method to be ran several times.
            if (private$.iteration > 0) {
                stop("Method already ran. Create a new instance to run again.")
            }

            # Start the clock.
            private$.start_time <- Sys.time()

            # Run the method.
            private$.run(replications, monotone, increasing, df, solver_type, boots, lower_ci, upper_ci)

            # Stop the clock.
            private$.end_time <- Sys.time()
        }
    ),

    active = list(
        # Time elapsed until converged.
        duration = function() {
            return(
                as.numeric(difftime(private$.end_time, private$.start_time, units = "secs"))
            )
        },

        # Number of iterations performed.
        iteration = function() { return(private$.iteration) },

        # Convergence status.
        converged = function() { return(private$.range$converged) },

        # Get results from last iteration.
        previous = function() { return(private$.previous) },

        # Get the steps.
        range = function() { return(private$.range) },
        step_1 = function() { return(private$.step_1) },
        step_2 = function() { return(private$.step_2) },
        step_3 = function() { return(private$.step_3) },

        # Get the recommended sample sizes.
        recommendation = function() { return(private$.step_3$samples) }
    )
)
