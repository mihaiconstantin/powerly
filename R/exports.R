#' @include Method.R

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
    cluster_type = "psock",
    save_memory = FALSE,
    verbose = TRUE
) {
    # Create a method object.
    method <- Method$new(
        max_iterations = iterations,
        verbose = verbose,
        save_memory = save_memory
    )

    # Decide whether it is necessary to create a backend for parallelization
    use_backend <- !is.null(cores) && cores > 1

    # Prepare backend if necessary.
    if (use_backend) {
        # Get the user's progress tracking preference.
        user_progress <- parabar::get_option("progress_track")

        # Same goes for the progress bar configuration (i.e., `run` will update it per step).
        user_progress_bar_config <- parabar::get_option("progress_bar_config")

        # Sync the progress tracking.
        parabar::set_option("progress_track", verbose)

        # Restore on exit (i.e., per `CRAN` policy).
        on.exit({
            # Set the progress tracking to the user's preference.
            parabar::set_option("progress_track", user_progress)

            # Also restore the user's progress bar configuration.
            parabar::set_option("progress_bar_config", user_progress_bar_config)
        })

        # Determine the backend type.
        backend_type <- if (verbose) "async" else "sync"

        # Start a `parabar` backend.
        backend <- parabar::start_backend(
            # The number of cores.
            cores = cores,

            # The cluster type.
            cluster_type = cluster_type,

            # The backend type.
            backend_type = backend_type
        )

        # On function exit free the resources.
        on.exit({
            # Forcefully stop the backend.
            parabar::stop_backend(backend)
        }, add = TRUE)

        # Register the backend.
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
        # Summarize the results.
        summary(method)
    }

    return(method)
}


#' @template validate
#' @export
validate <- function(
    method,
    replications = 3000,
    sample = NULL,
    cores = NULL,
    cluster_type = "psock",
    verbose = TRUE
) {
    # Check if the method argument is of correct type.
    if (!"Method" %in% class(method)) stop(.__ERRORS__$incorrect_type)

    # Create a validation object.
    validation <- Validation$new()

    # Decide whether it is necessary to create a parallel backend.
    use_backend <- !is.null(cores) && cores > 1

    # Decide whether it is necessary to create a backend for parallelization
    use_backend <- !is.null(cores) && cores > 1

    # Prepare backend if necessary.
    if (use_backend) {
        # Get the user's progress tracking preference.
        user_progress <- parabar::get_option("progress_track")

        # Same goes for the progress bar configuration (i.e., `run` will update it).
        user_progress_bar_config <- parabar::get_option("progress_bar_config")

        # Sync the progress tracking.
        parabar::set_option("progress_track", verbose)

        # Restore on exit (i.e., per `CRAN` policy).
        on.exit({
            # Set the progress tracking to the user's preference.
            parabar::set_option("progress_track", user_progress)

            # Also restore the user's progress bar configuration.
            parabar::set_option("progress_bar_config", user_progress_bar_config)
        })

        # Determine the backend type.
        backend_type <- if (verbose) "async" else "sync"

        # Start a `parabar` backend.
        backend <- parabar::start_backend(
            # The number of cores.
            cores = cores,

            # The cluster type.
            cluster_type = cluster_type,

            # The backend type.
            backend_type = backend_type
        )

        # On function exit free the resources.
        on.exit({
            # Forcefully stop the backend.
            parabar::stop_backend(backend)
        }, add = TRUE)

        # Register the backend.
        validation$register_backend(backend)
    }

    # Configure the validator.
    validation$configure_validator(method)

    # Run the validation.
    validation$run(sample = sample, replications = replications)

    # Information regarding the results of the validation.
    if (verbose) {
        # Summarize the results.
        summary(validation)
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
