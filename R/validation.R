#' @title Validate recommendation.
#' @export
validate.recommendation <- function(model, recommendation, replications = 100, measure = "sen", target = .8, statistic = "power", ..., verbose = TRUE) {
    # User feedback.
    if(verbose) cat("Starting validation...", "\n")

    # Validate.
    validation <- run.step.1(model = model, selected.sample.sizes = recommendation, replications = replications,  performance.measure = measure, performance.measure.target = target, statistic.definition = statistic, ..., verbose = verbose)

    # Add class.
    class(validation) <- "validation"

    # User feedback.
    if(verbose) cat("Validation completed.", "\n")

    return(validation)
}