# ------------------------------------------------------------------------------
# # # # Model functions.
# ------------------------------------------------------------------------------

# Contains environments with models that can be used with the algorithm.

# ------------------------------------------------------------------------------
# # # The GGM model.
# ------------------------------------------------------------------------------


#' @title Create GGM class.
#' @export
ggm <- new.env()


# Random mechanism.
ggm$create <- function(nodes, density, architecture = "random", proportion.positive.edges = .5) {
    return(bootnet::genGGM(nodes, p = density, propPositive = proportion.positive.edges, graph = architecture))
}


# Generate data.
ggm$generate <- function(n, model, levels = 5) {
    # To correlations.
    model <- cov2cor(solve(diag(ncol(model)) - model))

    # Sample data.
    data <- mvtnorm::rmvnorm(n, sigma = model)

    # Split the data into item steps.
    for (i in seq_len(ncol(data))) {
        data[, i] <- as.numeric(cut(data[, i], sort(c(-Inf, rnorm(levels - 1), Inf))))
    }

    return(data)
}


# Estimator.
ggm$estimate <- function(data, ...) {
    return(
        suppressWarnings(
            suppressMessages(
                bootnet::estimateNetwork(data, default = "EBICglasso", verbose = FALSE, ...)$graph
            )
        )
    )
}


# Compute outcomes.
ggm$evaluate <- function(true, esti) {
    # Get the true and estimated edges.
    true <- true[upper.tri(true)]
    esti <- esti[upper.tri(esti)]

    # True/ false | positive/ negative rates.
    TP <- sum(true != 0 & esti != 0)
    FP <- sum(true == 0 & esti != 0)
    TN <- sum(true == 0 & esti == 0)
    FN <- sum(true != 0 & esti == 0)

    # Compute indicators based on the rates.
    sen <- TP / (TP + FN)
    spe <- TN / (TN + FP)
    mcc <- (TP * TN - FP * FN) / sqrt((TP + FP) * (TP + FN) * (TN + FP) * (TN + FN))
    rho <- ifelse((length(true) == length(esti)) && ((var(true) != 0) && (var(esti) != 0)), cor(true, esti), NA)

    return(list(
        sen = sen,
        spe = spe,
        mcc = mcc,
        rho = rho
    ))
}
