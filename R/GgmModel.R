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

        # Todo: replace with `bootnet` estimators, also for the data generation.
        estimate = function(data, n_lambda = 100, lambda_min_ratio = .01, gamma = 0.5) {
            # Compute correlation matrix (i.e., inline with 'qgraph').
            S <- cor(data)

            # Compute the number of respondents.
            n <- nrow(data)

            # Compute the number of variables.
            p <- nrow(S)

            # Compute range of tunning parameter to be tried.
            lambda_max = max(max(S - diag(p)), -min(S - diag(p)))
            lambda_min = lambda_min_ratio * lambda_max
            lambda = exp(seq(log(lambda_min), log(lambda_max), length = n_lambda))

            # Compute 'glasso' path for the corresponding tunning parameters.
            precision_matrices <- glasso::glassopath(S, lambda, trace = 0, penalize.diagonal = FALSE)

            # Compute EBIC values for the 'glasso' path matrices.
            ebic_values <- sapply(seq_along(lambda), function(i) {
                # Extract the current precision matrix for easier access.
                K <- precision_matrices$wi[, , i]

                # Compute log likelihood.
                L <- n / 2 * (log(det(K)) - sum(diag(K %*% S)))

                # Compute the edge set.
                E <- sum(K[lower.tri(K, diag = FALSE)] != 0)

                # Compute the EBIC.
                return(-2 * L + E * log(n) + 4 * E * gamma * log(p))
            })

            # Get precision matrix that minimizes the EBIC.
            K <- precision_matrices$wi[, , which.min(ebic_values)]

            # Standardize precision coefficients to get partial correlation coefficients.
            W <- -cov2cor(K)

            # Set diagonal to 0.
            diag(W) <- 0

            return(as.matrix(Matrix::forceSymmetric(W)))
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
