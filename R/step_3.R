#' @title Step 3.
#' @export
run.step.3 <- function(step.1, step.2, statistic.criteria = c(.8, .8, .8), n.boots = 1e4, verbose = TRUE) {
    # User feedback.
    if(verbose) cat("Starting step 3...", "\n")

    # Create progress bar.
    pb <- progress::progress_bar$new(total = n.boots)

    # Create results environment.
    e <- new.env()

    # Attach meta information.
    e$n.boots <- n.boots
    e$statistic <- step.1$statistic.definition
    e$statistic.criteria <- statistic.criteria

    # Store bootstrapped statistics.
    boot.statistic <- array(NA, dim = c(n.boots, length(step.1$selected.sample.sizes), length(step.1$performance.measures)), dimnames = list(
        bootstraps = 1:n.boots,
        samples = step.1$selected.sample.sizes,
        measures = step.1$performance.measures
    ))

    # Store the sufficient sample sizes that reached the statistic criteria.
    sufficient.samples <- matrix(NA, n.boots, length(step.1$performance.measures), dimnames = list(
        bootstraps = 1:n.boots,
        measures = step.1$performance.measures
    ))

    # Start bootstrapping.
    for(i in 1:n.boots) {
        # Increment progress.
        pb$tick()

        # Resample performance measures computed during Step 1.
        for (j in 1:length(step.1$performance.measures)) {
            for (k in 1:length(step.1$selected.sample.sizes)) {
                if(step.1$statistic.definition == "power") {
                   boot.statistic[i, k, j] <- compute.power(sample(step.1$outcomes[, k, j], step.1$replications, replace = TRUE), target = step.1$performance.measures.targets[j])
                } else {
                   boot.statistic[i, k, j] <- mean(sample(step.1$outcomes[, k, j], step.1$replications, replace = TRUE), na.rm = TRUE)
                }
            }

            # Fit the spline to the bootstrapped performance measures.
            boot.spline <- spline.methdology(step.1$selected.sample.sizes, boot.statistic[i, , j], monotone = step.2[[step.1$performance.measures[j]]]$fit$basis$monotone, non.increasing = step.2[[step.1$performance.measures[j]]]$fit$basis$non.increasing)

            # Record the sufficient sample size.
            if(boot.spline$fit$basis$non.increasing) {
                # Adjust the criteria for a non-increasing trend.
                sufficient.samples[i, j] <- boot.spline$interpolate$x[which(boot.spline$interpolate$spline <= statistic.criteria[j])[1]]
            } else {
                sufficient.samples[i, j] <- boot.spline$interpolate$x[which(boot.spline$interpolate$spline >= statistic.criteria[j])[1]]
            }
        }
    }

    # Add statistic to results.
    e$boot.statistic <- boot.statistic

    # Add sufficient sample sizes to results.
    e$sufficient.samples <- sufficient.samples

    # Add class.
    class(e) <- "step.3"

    # User feedback.
    if(verbose) cat("Step 3 completed.", "\n\n\n")

    return(e)
}
