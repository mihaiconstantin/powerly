#' @title Step 3.
#' @export
run.step.3 <- function(step.1, step.2, statistic.criterion = .8, n.boots = 1e4, verbose = TRUE) {
    # User feedback.
    if(verbose) cat("Starting step 3...", "\n")

    # Create results environment.
    e <- new.env()

    # Attach meta information.
    e$step.1 <- step.1
    e$step.2 <- step.2
    e$n.boots <- n.boots
    e$statistic.criterion <- statistic.criterion

    # Create progress bar.
    pb <- progress::progress_bar$new(total = n.boots)

    # Store the bootstrapped splines.
    boot.splines <- matrix(0, n.boots, length(step.2$interpolate$x))

    # Store the sufficient sample sizes that reached the statistic criteria.
    sufficient.samples <- vector(mode = "numeric", length = n.boots)

    # Pick the statistic to use.
    if(step.1$statistic.definition == "power") {
        statistic.function <- compute.power
    } else {
        statistic.function <- compute.mean
    }

    # User feedback.
    if(verbose) cat("Bootstrapping...", "\n")

    # Start bootstrapping.
    for(i in 1:n.boots) {
        # Increment progress.
        pb$tick()

        # Temporarely store the bootstrapped statistics.
        boot.statistic <- vector(mode = "numeric", length = step.1$total.selected.samples)

        # Resample performance measures computed during Step 1.
        for (j in 1:step.1$total.selected.samples) {
            boot.statistic[j] <- statistic.function(sample(step.1$outcomes[, j], step.1$replications, replace = TRUE), target = step.1$performance.measure.target)
        }

        # Fit the spline to the bootstrapped performance measures.
        boot.splines[i, ] <- spline.methdology(step.1$selected.sample.sizes, boot.statistic, inner.knots = step.2$fit$basis$inner.knots, monotone = step.2$fit$basis$monotone, non.increasing = step.2$fit$basis$non.increasing)$interpolate$spline

        # Record the sufficient sample size.
        if(step.2$fit$basis$non.increasing) {
            # Adjust the criteria for a non-increasing trend.
            sufficient.samples[i] <- step.2$interpolate$x[which(boot.splines[i, ] <= statistic.criterion)[1]]
        } else {
            sufficient.samples[i] <- step.2$interpolate$x[which(boot.splines[i, ] >= statistic.criterion)[1]]
        }
    }

    # Add bootstrapped splines to the result.
    e$boot.splines <- boot.splines

    # Add the sufficient sample sizes.
    e$sufficient.samples <- sufficient.samples

    # Add class.
    class(e) <- "step.3"

    # User feedback.
    if(verbose) cat("Step 3 completed.", "\n\n\n")

    return(e)
}


#' @title Update sample size range.
#' @export
update.range <- function(step.3) {
    # Get quamtiles.
    quantiles <- ceiling(quantile(step.3$sufficient.samples, probs = seq(0, 1, 0.05), na.rm = TRUE))

    # Get the new range.
    range <- c(quantiles[2], quantiles[length(quantiles) - 1])

    return(range)
}