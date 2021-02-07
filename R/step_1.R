#' @title Step 1.
#' @export
run.step.1 <- function(selected.sample.sizes, replications, performance.measure = "sen", performance.measure.target = .8, statistic.definition = "power", statistic.criterion = .8, ..., verbose = TRUE) {
    # Create result environment.
    e <- new.env()

    # Attach meta information for step 1.
    e$selected.sample.sizes <- selected.sample.sizes
    e$total.selected.samples <- length(selected.sample.sizes)
    e$replications <- replications
    e$performance.measure <- performance.measure
    e$performance.measure.target <- performance.measure.target
    e$statistic.definition <- statistic.definition
    e$statistic.criterion <- statistic.criterion
    e$improper.sample.sizes <- FALSE

    # Create progress bar.
    if(verbose) pb <- progress::progress_bar$new(total = e$total.selected.samples, force = TRUE)

    # Store matrix of outcome.
    outcomes <- array(NA, dim = c(replications, e$total.selected.samples), dimnames = list(
        reps = 1:replications,
        samples = selected.sample.sizes
    ))

    for(i in 1:e$total.selected.samples) {
        # Increment progress.
        if(verbose) pb$tick()

        # Replicate sample size.
        outcomes[, i] <- replicate.mc.run(replications = replications, n = selected.sample.sizes[i], performance.measure = performance.measure, ...)
    }

    # Compute the statistic.
    if(statistic.definition == "power") {
        e$statistic <- statistic.power(outcomes, performance.measure.target)
    } else {
        e$statistic <- statistic.mean(outcomes)
    }

    # Attach outcomes.
    e$outcomes <- outcomes

    # Check if any of sample sizes meets the requirement.
    if(all(e$statistic < statistic.criterion)) {
        e$improper.sample.sizes <- TRUE
    }

    # Add class.
    class(e) <- "step.1"

    return(e)
}


#' @title Replicate Monte Carlo simulation.
replicate.mc.run <- function(replications, n, performance.measure, ...) {
    # Store outcomes for current sample size.
    outcomes <- vector(mode = "numeric", length = replications)

    for(i in 1:replications) {
        # Run the MC step.
        outcomes[i] <- mc.run(n = n, performance.measure = performance.measure, ...)
    }

    return(outcomes)
}


#' @title Monte Carlo simulation.
mc.run <- function(model, n, performance.measure, generate = ggm$generate, estimate = ggm$estimate, evaluate = ggm$evaluate, ...) {
    # Create model model if not provided.
    if(is.function(model)) model <- model(...)

    # Generate data.
    data <- generate(n, model)

    # Estimate model.
    fit <- suppressWarnings(suppressMessages(estimate(data)))

    # Compute performance measure.
    outcomes <- evaluate(model, fit)[[performance.measure]]

    return(outcomes)
}
