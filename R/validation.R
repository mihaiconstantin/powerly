#' @title Validate recommendation.
#' @export
validate.recommendation <- function(model, recommendation, replications = 100, performance.measure = "sen", performance.measure.target = .8, statistic.definition = "power", ..., verbose = TRUE) {
    # User feedback.
    if(verbose) cat("Starting validation...", "\n")

    # Validate.
    validation <- run.step.1(model = model, selected.sample.sizes = recommendation, replications = replications,  performance.measure = performance.measure, performance.measure.target = performance.measure.target, statistic.definition = statistic.definition, ..., verbose = verbose)

    # Add class.
    class(validation) <- "validation"

    # User feedback.
    if(verbose) cat("Validation completed.", "\n")

    return(validation)
}