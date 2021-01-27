#' @title Run method.
#' @export
run.method <- function(model, range, replications, measure = "sen", target = .8, statistic = "power", criterion = .8, n.samples = 10, tolerance = 50, boots = 1e4, monotone = TRUE, non.increasing = FALSE, runs = 10, ..., verbose = TRUE) {
    # User feedback.
    if(verbose) cat("Starting procedure...", "\n")

    # Create storage for the iterrations.
    results <- list()

    # Record convergence.
    converged = FALSE

    # Start the counter.
    iteration = 1

    while(iteration <= runs) {
        # User feedback.
        if(verbose) cat("\n", "-> iteration: ", iteration, "/", runs, ".", "\n", sep = "")

        # Select sample sizes.
        selected.sample.sizes <- unique(floor(seq(range[1], range[2], length.out = n.samples)))

        # Determine the inner knots.
        inner.knots <- selected.sample.sizes[2:(length(selected.sample.sizes) - 1)]

        # Run Step 1.
        step.1 <- run.step.1(model = model, selected.sample.sizes = selected.sample.sizes, replications = replications, performance.measure = measure, performance.measure.target = target, statistic.definition = statistic, statistic.criterion = criterion, ..., verbose = verbose)

        if(step.1$improper.sample.sizes) {
            # Warn.
            if(verbose) cat("Sample range [", range[1], "...", range[2], "] too small. Changing to [", range[2], "...", range[2] * 2, "].", "\n", sep = "")

            # Update previous range.
            range[1] <- range[2]
            range[2] <- range[2] * 2

            # Increment iterations.
            iteration = iteration + 1

            # Indicate failure of iteration.
            results[[iteration]] <- list(
                iteration = iteration,
                step.1 = step.1,
                failed = TRUE
            )

            # Break current interation.
            next
        }

        # Run Step 2.
        step.2 <- run.step.2(step.1, inner.knots = inner.knots, monotone = monotone, non.increasing = non.increasing, verbose = verbose)

        # Run Step 3.
        step.3 <- run.step.3(step.1, step.2, n.boots = boots, verbose = verbose)

        # Compute the updated range.
        range <- update.range(step.3)

        # Store current iteration.
        results[[iteration]] <- list(
            iteration = iteration,
            failed = FALSE,
            step.1 = step.1,
            step.2 = step.2,
            step.3 = step.3
        )

        # Break if converged.
        if((range[2] - range[1]) <= tolerance) {
            # User feedback.
            if(verbose) cat("Algorithm converged on iteration: ", iteration, ".", "\n", sep = "")

            # Update convergence.
            converged = TRUE

            # Break free.
            break
        }

        # Increment iterations.
        iteration = iteration + 1
    }

    # User feedback.
    if(verbose && !converged) cat("Failed to converge.", "\n")

    # Add class.
    class(results) <- "splower.result"

    return(results)
}
