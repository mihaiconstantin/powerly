#' @title Step 1.
#' @export
run.step.1 <- function(selected.sample.sizes, replications, performance.measures = c("sen", "spe", "rho"), ..., verbose = TRUE) {
    # User feedback.
    if(verbose) cat("Starting step 1...", "\n")

    # Create progress bar.
    pb <- progress::progress_bar$new(total = length(selected.sample.sizes))

    # Create result environment.
    e <- new.env()

    # Attach meta information for step 1.
    e$selected.sample.sizes <- selected.sample.sizes
    e$replications <- replications
    e$performance.measures <- performance.measures

    # Store matrix of outcome.
    outcomes <- array(NA, dim = c(replications, length(selected.sample.sizes), length(performance.measures)), dimnames = list(
        replications = paste0("r.", 1:replications, sep = ""),
        samples = paste0("s.", selected.sample.sizes, sep = ""),
        measures = performance.measures
    ))

    for(n in selected.sample.sizes) {
        # Increment progress.
        pb$tick()

        # Replicate sample size.
        outcomes[,which(selected.sample.sizes == n), ] <- replicate.mc.run(replications = replications, n = n, performance.measures = performance.measures, ...)
    }

    # Attach results.
    e$outcomes <- outcomes

    # Add class.
    class(e) <- "step.1"

    # User feedback.
    if(verbose) cat("Step 1 completed.", "\n\n\n")

    return(e)
}


#' @title Replicate Monte Carlo simulation.
replicate.mc.run <- function(replications, n, performance.measures, ...) {
    # Store outcomes for current sample size.
    outcomes <- matrix(NA, nrow = replications, ncol = length(performance.measures), dimnames = list(
        sample = rep(10, replications),
        measures = performance.measures
    ))

    for(i in 1:replications) {
        # Run the MC step.
        outcomes[i, ] <- mc.run(n = n, performance.measures = performance.measures, ...)
    }

    return(outcomes)
}


#' @title Monte Carlo simulation.
mc.run <- function(model, n, performance.measures, generate = ggm$generate, estimate = ggm$estimate, evaluate = ggm$evaluate, ...) {
    # Create model model if not provided.
    if(is.function(model)) model <- model(...)

    # Generate data.
    data <- generate(n, model)

    # Estimate model.
    fit <- estimate(data)

    # Compute performance measure.
    outcomes <- unlist(evaluate(model, fit)[performance.measures])

    return(outcomes)
}
