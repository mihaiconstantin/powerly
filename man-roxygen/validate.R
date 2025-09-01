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
#' @param sample A single positive integer representing the sample size to
#' perform the validation for. If `NULL` (the default) the validation will be
#' run for the sample size recommendation contained in the `method` argument
#' (i.e., the output of the [powerly::powerly()] function). Defaults to `NULL`.
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
#' The sample sizes used during the validation procedure is automatically
#' extracted from the `method` argument. User may also choose to provide a
#' specific sample size for the validation via the `sample` argument. In this
#' case, the validation will be run for the provided sample size instead.
#' Providing a specific `sample` value is akin to manually searching for an
#' optimal value.
#'
#' @return
#' An [R6::R6Class()] instance of `Validation` class that contains the results
#' of the validation.
#'
#' Main fields:
#' - **`$sample`**: The sample size used for the validation.
#' - **`$measures`**: The performance measures observed during validation.
#' - **`$statistic`**: The statistic computed on the performance measures.
#' - **`$percentile_value`**: The performance measure value at the desired percentile.
#' - **`$validator`**: An [R6::R6Class()] instance of `StepOne` class.
#'
#' The `plot` S3 method can be called on the return value to visualize the
#' validation results (i.e., see [powerly::plot.Validation()]).
#' - `plot(validation)`
#'
#' @examples
#' \donttest{# Perform a sample size analysis.
#' results <- powerly(
#'     range_lower = 300,
#'     range_upper = 1000,
#'     samples = 30,
#'     replications = 30,
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
#' @seealso [powerly::plot.Validation()], [powerly::summary.Validation()], [powerly::powerly()], [powerly::generate_model()]
