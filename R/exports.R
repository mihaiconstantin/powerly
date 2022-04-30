#' @include Backend.R Method.R

#' @template powerly
#' @export
powerly <- function(
    range_lower,
    range_upper,
    samples = 30,
    replications = 30,
    model = "ggm",
    ...,
    model_matrix = NULL,
    measure = "sen",
    statistic = "power",
    measure_value = .6,
    statistic_value = .8,
    monotone = TRUE,
    increasing = TRUE,
    spline_df = NULL,
    solver_type = "quadprog",
    boots = 10000,
    lower_ci = 0.025,
    upper_ci = 0.975,
    tolerance = 50,
    iterations = 10,
    cores = NULL,
    backend_type = NULL,
    save_memory = FALSE,
    verbose = TRUE
) {
    # Decide whether it is necessary to create a parallel backend.
    use_backend <- !is.null(cores) && cores > 1

    # Prepare backend if necessary.
    if (use_backend) {
        # Create backend instance.
        backend <- Backend$new()

        # Start it.
        backend$start(cores, type = backend_type)
    }

    # Close the backend no matter the execution status.
    on.exit({
        # Close the backend.
        if (use_backend) {
            backend$stop()
        }
    })

    # Create a method object.
    method <- Method$new(max_iterations = iterations, verbose = verbose, save_memory = save_memory)

    # Register the backend.
    if (use_backend) {
        method$register_backend(backend)
    }

    # Configure the range.
    method$configure_range(
        lower = range_lower,
        upper = range_upper,
        samples = samples,
        tolerance = tolerance
    )

    # Configure Step 1.
    method$configure_step_1(
        model = model,
        measure = measure,
        statistic = statistic,
        measure_value = measure_value,
        statistic_value = statistic_value,
        ...,
        matrix = model_matrix
    )

    # Configure Step 2.
    method$configure_step_2()

    # Configure Step 3.
    method$configure_step_3()

    # Run the method.
    method$run(
        replications = replications,
        monotone = monotone,
        increasing = increasing,
        df = spline_df,
        solver_type = solver_type,
        boots = boots,
        lower_ci = lower_ci,
        upper_ci = upper_ci
    )

    # Inform the user about the method status.
    if (verbose) {
        cat("\n", "Method run completed (", round(method$duration, 4), " sec):", sep = "")
        cat("\n", " - converged: ", ifelse(method$converged, "yes", "no"), sep = "")
        cat("\n", " - iterations: ", method$iteration, sep = "")
        cat("\n", " - recommendation: ", method$step_3$samples["50%"], "\n", sep = "")
    }

    return(method)
}


#' @template validate
#' @export
validate <- function(
    method,
    replications = 3000,
    cores = NULL,
    backend_type = NULL,
    verbose = TRUE
) {
    # Check if the method argument is of correct type.
    if (!"Method" %in% class(method)) stop(.__ERRORS__$incorrect_type)

    # Announce the starting of the validation.
    if (verbose) cat("Running the validation...", "\n")

    # Decide whether it is necessary to create a parallel backend.
    use_backend <- !is.null(cores) && cores > 1

    # Prepare backend if necessary.
    if (use_backend) {
        # Create backend instance.
        backend <- Backend$new()

        # Start it.
        backend$start(cores, type = backend_type)
    }

    # Create a validation object.
    validation <- Validation$new()

    # Register the backend.
    if (use_backend) {
        validation$register_backend(backend)
    }

    # Configure the validator.
    validation$configure_validator(method$step_3)

    # Run the validation.
    validation$run(replications = replications)

    # Close the backend.
    if (use_backend) {
        backend$stop()
    }

    # Information regarding the results of the validation.
    if (verbose) {
        cat("\n", "Validation completed (", round(validation$validator$duration, 4), " sec):", sep = "")
        cat("\n", " - sample: ", validation$sample, sep = "")
        cat("\n", " - statistic: ", validation$statistic, sep = "")
        cat("\n", " - measure at ", validation$percentile, " pert.: ", round(validation$percentile_value, 3), sep = "")
    }

    return(validation)
}


#' @template generate_model
#' @export
generate_model <- function(
    type,
    ...
) {
    # Create a model factory.
    factory <- ModelFactory$new()

    # Get a model from the factory.
    model <- factory$get_model(type)

    # Generate true model parameters.
    true_parameters <- model$create(...)

    return(true_parameters)
}
