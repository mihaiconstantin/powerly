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
        cat("\n", "Method run completed (", as.numeric(round(method$duration, 4)), " sec):", sep = "")
        cat("\n", " - converged: ", ifelse(method$converged, "yes", "no"), sep = "")
        cat("\n", " - iterations: ", method$iteration, sep = "")
        cat("\n", " - recommendation: ", method$step_3$samples["50%"], "\n", sep = "")
    }

    return(method)
}


#' @title
#' Validate a sample size analysis
#'
#' @description
#' This function can be used to validate the recommendation obtained from a
#' sample size analysis.
#'
#' @param method An object of class `Method` produced by running
#' [powerly::powerly()].
#'
#' @param replications A single positive integer representing the number of
#' Monte Carlo simulations to perform for the recommended sample size. The
#' default is `1000`. Whenever possible, a value of `10000` should be preferred
#' for a higher accuracy of the validation results.
#'
#' @param cores A single positive positive integer representing the number of
#' cores to use for running the validation in parallel, or `NULL`. If `NULL`
#' (the default) the validation will run sequentially.
#'
#' @param backend_type A character string indicating the type of cluster to
#' create for running the validation in parallel, or `NULL`. Possible values are
#' `"psock"` and `"fork"`. If `NULL` the backend is determined based on the
#' computer architecture (i.e., `fork` for Unix and MacOS and `psock` for
#' Windows).
#'
#' @param verbose A logical value indicating whether information about the
#' status of the validation should be printed while running. The default is
#' `TRUE`.
#'
#' @details
#' The sample sizes used during the validation procedure is automatically extracted
#' from the `method` argument.
#'
#' @return
#' An [R6::R6Class()] instance of `Validation` class that contains the results
#' of the validation.
#'
#' Main fields:
#' - `$sample`: The sample size used for the validation.
#' - `$measures`: The performance measures observed during validation.
#' - `$statistic`: The statistic computed on the performance measures.
#' - `$percentile_value`: The performance measure value at the desired percentile.
#' - `$validator`: An [R6::R6Class()] instance of `StepOne` class.
#'
#' The `plot` method can be called on the return value to visualize the results.
#' - `plot(validation)`
#'
#' \if{html}{
#' Example of a plot:
#' \itemize{\item \figure{example-validation.png}{options: width=500 alt="Example Validation" style="vertical-align:middle"}}
#' }
#'
#' @examples
#' \donttest{
#'
#' # Perform a sample size analysis.
#' results <- powerly(
#'     range_lower = 300,
#'     range_upper = 1000,
#'     samples = 30,
#'     replications = 20,
#'     measure = "sen",
#'     statistic = "power",
#'     measure_value = .6,
#'     statistic_value = .8,
#'     model = "ggm",
#'     nodes = 10,
#'     density = .4,
#'     cores = 2,
#'     verbose = TRUE
#' )
#'
#' # Validate the recommendation obtained during the analysis.
#' validation <- validate(results, cores = 2)
#'
#' # Plot the validation results.
#' plot(validation)
#'
#' # To see a summary of the validation procedure, we can use the `summary` S3 method.
#' summary(validation)
#' }
#'
#' @seealso [powerly::powerly()], [powerly::generate_model()]
#'
#' @export
validate <- function(method, replications = 3000, cores = NULL, backend_type = NULL, verbose = TRUE) {
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
        cat("\n", "Validation completed (", as.numeric(round(validation$validator$duration, 4)), " sec):", sep = "")
        cat("\n", " - sample: ", validation$sample, sep = "")
        cat("\n", " - statistic: ", validation$statistic, sep = "")
        cat("\n", " - measure at ", validation$percentile, " pert.: ", round(validation$percentile_value, 3), sep = "")
    }

    return(validation)
}


#' @title Generate true model parameters
#'
#' @description
#' Generate matrices of true model parameters for the supported true models.
#' These matrices are intended to passed to the `model_matrix` argument of
#' [powerly::powerly()].
#'
#' @param type Character string representing the type of true model. Possible
#' values are `"ggm"` (the default).
#'
#' @param ... Required arguments used for the generation of the true model. See
#' the **True Models** section of [powerly::powerly()] for the arguments
#' required for each true model.
#'
#' @return
#' A matrix containing the model parameters.
#'
#' @seealso [powerly::powerly()], [powerly::validate()]
#'
#' @export
generate_model <- function(type, ...) {
    # Create a model factory.
    factory <- ModelFactory$new()

    # Get a model from the factory.
    model <- factory$get_model(type)

    # Generate true model parameters.
    true_parameters <- model$create(...)

    return(true_parameters)
}
