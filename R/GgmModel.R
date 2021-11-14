#' @include Model.R

GgmModel <- R6::R6Class("GgmModel",
    inherit = Model,

    public = list(
        create = function(nodes, density) {
            return(bootnet::genGGM(nodes, p = density, propPositive = .5, graph = "random"))
        },

        generate = function(sample_size, true_parameters, levels = 5) {
            # Convert partial correlations to correlations.
            true_parameters <- cov2cor(solve(diag(ncol(true_parameters)) - true_parameters))

            # Sample data.
            data <- mvtnorm::rmvnorm(sample_size, sigma = true_parameters)

            # Split the data into item steps (i.e., Likert scale).
            for (i in seq_len(ncol(data))) {
                data[, i] <- as.numeric(cut(data[, i], sort(c(-Inf, rnorm(levels - 1), Inf))))
            }

            return(data)
        },

        estimate = function(data, gamma = 0.5) {
            # Ensure all variables show variance.
            if (sum(apply(data, 2, sd) == 0) > 0) {
                stop("Variable(s) with SD = 0 detected. Increase the sample size.")
            }

            # Estimate network using `qgraph`.
            network <- suppressMessages(suppressWarnings(
                qgraph::EBICglasso(
                    S = cov(data),
                    n = nrow(data),
                    gamma = gamma,
                    verbose = FALSE
                )
            ))

            return(network)
        },

        evaluate = function(true_parameters, estimated_parameters, measure) {
            # Extract the true and estimated parameters from the weights matrices.
            true <- true_parameters[upper.tri(true_parameters)]
            esti <- estimated_parameters[upper.tri(estimated_parameters)]

            # Check if model dimensions do not match.
            if(length(true) != length(esti)) return(NA)

            # Compute true/ false | positive/ negative rates.
            tp <- sum(true != 0 & esti != 0)
            fp <- sum(true == 0 & esti != 0)
            tn <- sum(true == 0 & esti == 0)
            fn <- sum(true != 0 & esti == 0)

            # Compute correct measure.
            return(
                switch(measure,
                    sen = tp / (tp + fn),
                    spe = tn / (tn + fp),
                    mcc = (tp * tn - fp * fn) / sqrt((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn)),
                    rho = cor(true, esti),
                    stop(.__ERRORS__$not_developed)
                )
            )
        }
    )
)
