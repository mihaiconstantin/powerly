#' @include Backend.R Method.R

#' @title
#' Perform sample size analysis
#'
#' @description Run an iterative three-step Monte Carlo method and return the
#' sample sizes required to obtain a certain value for a performance measure of
#' interest (e.g., sensitivity) given a hypothesized network structure.
#'
#' @param range_lower A single positive integer representing the lower bound of
#' the candidate sample size range.
#'
#' @param range_upper A single positive integer representing the upper bound of
#' the candidate sample size range.
#'
#' @param samples A single positive integer representing the number of sample
#' sizes to select from the candidate sample size range.
#'
#' @param replications A single positive integer representing the number of
#' Monte Carlo replications to perform for each sample size selected from the
#' candidate range.
#'
#' @param model A character string representing the type of true model to find a
#' sample size for. Possible values are `"ggm"` (the default).
#'
#' @param ... Required arguments used for the generation of the true model. See
#' the **True Models** section for the arguments required for each true model.
#'
#' @param model_matrix A square matrix representing the true model. See the
#' **True Models** section for what this matrix should look like depending on
#' the true model selected.
#'
#' @param measure A character string representing the type of performance
#' measure of interest. Possible values are `"sen"` (i.e., sensitivity; the
#' default), `"spe"` (i.e., specificity), `"mcc"` (i.e., Matthews correlation),
#' and `"rho"` (i.e., Pearson correlation). See the **True Models** section for
#' the performance measures available for each type of true model supported.
#'
#' @param statistic A character string representing the type of statistic to be
#' computed on the values obtained for the performance measures. Possible values
#' are `"power"` (the default).
#'
#' @param measure_value A single numerical value representing the desired value
#' for the performance measure of interest. The default is `0.6` (i.e., for the
#' `measure = "sen"`). See the **Performance Measures** section for the range of
#' values allowed for each performance measure.
#'
#' @param statistic_value A single numerical value representing the desired
#' value for the statistic of interest. The default is `0.8` (i.e., for the
#' `statistic = "power"`). See the **"Statistics"** section for the range of
#' values allowed for each statistic.
#'
#' @param monotone A logical value indicating whether a monotonicity assumption
#' should be placed on the values of the performance measure. The default is
#' `TRUE` meaning that the performance measure changes as a function of sample
#' size (i.e., either by increasing or decreasing as the sample size goes up).
#' The alternative `FALSE` indicates that the performance measure it is not
#' assumed to change as a function a sample size.
#'
#' @param increasing A logical value indicating whether the performance measure
#' is assumed to follow a non-increasing or non-decreasing trend. `TRUE` (the
#' default) indicates a non-decreasing trend (i.e., the performance measure
#' increases as the sample size goes up). `FALSE` indicates a non-increasing
#' trend (i.e., the performance measure decreases as the sample size goes up).
#'
#' @param spline_df A vector of positive integers representing the degrees of
#' freedom considered for constructing the spline basis, or `NULL`. The best
#' degree of freedom is selected based on Leave One Out Cross-Validation. If
#' `NULL` (the default) is provided, a vector of degrees of freedom is
#' automatically created with all integers between `3` and `20`.
#'
#' @param solver_type A character string representing the type of the quadratic
#' solver used for estimating the spline coefficients. Possible values are
#' `"quadprog"` (the default) and `"osqp"`. Currently, the "`osqp`" solver does
#' not play nicely with `R`'s [`parallel::parallel`] package and cannot be used
#' when powerly is ran in parallel.
#'
#' @param boots A positive integer representing the number of bootstrap runs to
#' perform on the matrix of performance measures in order to obtained
#' bootstrapped values for the statistic of interest. The default is `10000`.
#'
#' @param lower_ci A single numerical value indicating the lower bound for the
#' confidence interval to be computed on the bootstrapped statistics. The
#' default is `0.025` (i.e., 2.5%).
#'
#' @param upper_ci A single numerical value indicating the upper bound for the
#' confidence to be computed on the bootstrapped statistics. The default is
#' `0.975` (i.e., 97.5%).
#'
#' @param tolerance A single positive integer representing the width at the
#' candidate sample size range at which the algorithm is considered to have
#' converge. The default is `50`, meaning that the algorithm will stop running
#' when the difference between the upper and the lower bound of the candidate
#' range shrinks to 50 sample sizes.
#'
#' @param iterations A single positive integer representing the number of
#' iterations the algorithm is allowed to run. The default is `10`.
#'
#' @param cores A single positive positive integer representing the number of
#' cores to use for running the algorithm in parallel, or `NULL`. If `NULL` (the
#' default) the algorithm will run sequentially.
#'
#' @param backend_type A character string indicating the type of cluster to
#' create for running the algorithm in parallel, or `NULL`. Possible values are
#' `"psock"` and `"fork"`. If `NULL` the backend is determined based on the
#' computer architecture (i.e., `fork` for Unix and MacOS and `psock` for
#' Windows).
#'
#' @param save_memory A logical value indicating whether to save memory by only
#' storing the results for the last iteration of the method. The default `TRUE`
#' indicates that only the last iteration should be saved.
#'
#' @param verbose A logical value indicating whether information about the
#' status of the algorithm should be printed while running. The default is
#' `TRUE`.
#'
#' @details
#' This function represents the implementation of the method introduced by
#' [Constantin et al. (2021)](https://arxiv.org) for performing a priori
#' sample size analysis in the context of network models. The method takes the
#' form of a three-step recursive algorithm designed to find an optimal sample
#' size value given a model specification and an outcome measure of interest
#' (e.g., sensitivity). It starts with a Monte Carlo simulation step for
#' computing the outcome of interest at various sample sizes. It continues with
#' a monotone non-decreasing curve-fitting step for interpolating the outcome.
#' The final step employs a stratified bootstrapping scheme to account for the
#' uncertainty around the recommendation provided. The method runs the three
#' steps recursively until the candidate sample size range used for the search
#' shrinks below a specified value.
#'
#' @section True Models:
#' **Gaussian Graphical Model (GGM)**
#' - type: cross-sectional
#' - symbol: `ggm`
#' - `...` arguments:
#'     - `nodes`: A single positive integer representing the number of nodes in the network (e.g., `10`).
#'     - `density`: A single numerical value indicating the density of the network (e.g., `0.4`).
#' - supported performance measures: `sen`, `spe`, `mcc`, `rho`
#'
#' @section Performance Measures:
#'
#' | **Performance Measure**  | **Symbol** | **Lower**   | **Upper**  |
#' | :----------------------- | :--------: | ----------: | ---------: |
#' | Sensitivity              | `sen`      | `0.00`      | `1.00`     |
#' | Specificity               | `spe`      | `0.00`      | `1.00`     |
#' | Matthews correlation     | `mcc`      | `-1.00`     | `1.00`     |
#' | Pearson correlation      | `rho`      | `-1.00`     | `1.00`     |
#'
#' @section Statistics:
#'
#' | **Statistics**  | **Symbol** | **Lower**  | **Upper**  |
#' | :---------------| :--------: | ---------: | ---------: |
#' | Power           | `power`    | `0.00`     | `1.00`     |
#'
#' @section Requests:
#' - If you would like to support a new model, performance measure, or
#'   statistic, please open a pull request on GitHub at
#'   [github.com/mihaiconstantin/powerly/pulls](https://github.com/mihaiconstantin/powerly/pulls).
#' - To request a new model, performance measure, or statistic, please submit
#'   your request at
#'   [github.com/mihaiconstantin/powerly/issues](https://github.com/mihaiconstantin/powerly/issues).
#'   If possible, please also include references discussing the topics you are
#'   requesting.
#' - Alternatively, you can get in touch at `mihai at mihaiconstantin dot com`.
#'
#' @return
#' An [R6::R6Class()] instance of `Method` class that contains the results for
#' each step of the method for the last and previous iterations.
#'
#' Main fields:
#' - `$duration`: The time elapsed during the method run.
#' - `$iteration`: The number of iterations performed.
#' - `$converged`: Whether the method converged.
#' - `$previous`: The results during the previous iteration.
#' - `$range`: The candidate sample size range.
#' - `$step_1`: The results for Step 1.
#' - `$step_2`: The results for Step 2.
#' - `$step_3`: The results for Step 3.
#' - `$recommendation`: The sample size recommendation(s).
#'
#' The `plot` method can be called on the return value to visualize the results.
#' - for Step 1: `plot(results, step = 1, last = TRUE)`
#' - for Step 2: `plot(results, step = 2, last = TRUE)`
#' - for Step 3: `plot(results, step = 3, last = TRUE)`
#'
#' \if{html}{
#' Example of a plots:
#' \itemize{
#' \item Step 1 \itemize{\item \figure{example-step-1.png}{options: width=500 alt="Example Step 1" style="vertical-align:middle"}}
#' \item Step 2 \itemize{\item \figure{example-step-2.png}{options: width=500 alt="Example Step 2" style="vertical-align:middle"}}
#' \item Step 3 \itemize{\item \figure{example-step-3.png}{options: width=500 alt="Example Step 3" style="vertical-align:middle"}}
#' }}
#'
#' @references
#' Constantin, M. A., Schuurman, N. K., & Vermunt, J. (2021). A General Monte
#' Carlo Method for Sample Size Analysis in the Context of Network Models.
#' PsyArXiv. \doi{10.31234/osf.io/j5v7u}
#'
#' @examples
#' \donttest{
#'
#' # Suppose we want to find the sample size for observing a sensitivity of `0.6`
#' # with a probability of `0.8`, for a GGM true model consisting of `10` nodes
#' # with a density of `0.4`.
#'
#' # We can run the method for an arbitrarily generated true model that matches
#' # those characteristics (i.e., number of nodes and density).
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
#' # Or we omit the `nodes` and `density` arguments and specify directly the edge
#' # weights matrix via the `model_matrix` argument.
#'
#' # To get a matrix of edge weights we can use the `generate_model()` function.
#' true_model <- generate_model(type = "ggm", nodes = 10, density = .4)
#'
#' # Then, supply the true model to the algorithm directly.
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
#'     model_matrix = true_model,
#'     cores = 2,
#'     verbose = TRUE
#' )
#'
#' # To visualize the results, we can use the `plot` function and indicating the
#' # step that should be plotted.
#' plot(results, step = 1, last = TRUE)
#' plot(results, step = 2, last = TRUE)
#' plot(results, step = 3, last = TRUE)
#'
#' # The argument `last = TRUE` indicates that the plot should be constructed for
#' # the last iteration of the algorithm.
#'
#' # To see a summary of the results, we can use the `summary` S3 method.
#' summary(results)
#' }
#'
#' @seealso [powerly::validate()], [powerly::generate_model()]
#'
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
