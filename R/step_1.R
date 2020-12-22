#' @title Step 1.
#' @export
run.step.1 <- function(selected.sample.sizes, replications, performance.measure = "sen", performance.measure.target = .8, statistic.definition = "power", ..., verbose = TRUE) {
    # User feedback.
    if(verbose) cat("Starting step 1...", "\n")

    # Create result environment.
    e <- new.env()

    # Attach meta information for step 1.
    e$selected.sample.sizes <- selected.sample.sizes
    e$total.selected.samples <- length(selected.sample.sizes)
    e$replications <- replications
    e$performance.measure <- performance.measure
    e$performance.measure.target <- performance.measure.target
    e$statistic.definition <- statistic.definition

    # Create progress bar.
    pb <- progress::progress_bar$new(total = e$total.selected.samples)

    # Store matrix of outcome.
    outcomes <- array(NA, dim = c(replications, e$total.selected.samples), dimnames = list(
        reps = 1:replications,
        samples = selected.sample.sizes
    ))

    # User feedback.
    if(verbose) cat("Running the MC replications...", "\n")

    for(i in 1:e$total.selected.samples) {
        # Increment progress.
        pb$tick()

        # Replicate sample size.
        outcomes[, i] <- replicate.mc.run(replications = replications, n = selected.sample.sizes[i], performance.measure = performance.measure, ...)
    }

    # User feedback.
    if(verbose) cat("Computing the statistic...", "\n")

    # Compute the statistic.
    if(statistic.definition == "power") {
        e$statistic <- statistic.power(outcomes, performance.measure.target)
    } else {
        e$statistic <- statistic.mean(outcomes)
    }

    # Attach outcomes.
    e$outcomes <- outcomes

    # Add class.
    class(e) <- "step.1"

    # User feedback.
    if(verbose) cat("Step 1 completed.", "\n\n\n")

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
    fit <- estimate(data)

    # Compute performance measure.
    outcomes <- evaluate(model, fit)[[performance.measure]]

    return(outcomes)
}
