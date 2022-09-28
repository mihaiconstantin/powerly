#' @include Model.R

IsingModel <- R6::R6Class("IsingModel",
    inherit = Model,

    private = list(
        .minimum_sample_size = 100,

        .has_zero_variance = function(data) {
            return(any(apply(data, 2, sd) == 0))
        }
    ),

    public = list(
        create = function(nodes, density, positive = .9, ...) {
            # Compute the number of unique parameters.
            number_parameters = (nodes * (nodes - 1)) / 2

            # Determine the ratio of positive parameters.
            ratio <- sample(c(-1, 1), number_parameters, TRUE, prob = c(1 - positive, positive))

            # Generate random network structure.
            network <- as.matrix(
                igraph::get.adjacency(
                    igraph::erdos.renyi.game(
                        n = nodes,
                        p.or.m = density,
                        ...
                    )
                )
            )

            # Sample parameters with desired positive ratio.
            parameters <- ratio * abs(rnorm(number_parameters, mean = 0, sd = 1))

            # Map the parameters onto to the network structure.
            network[upper.tri(network)] <- network[upper.tri(network)] * parameters
            network[lower.tri(network)] <- t(network)[lower.tri(network)]

            # Sample thresholds based on network structure.
            diag(network) <- -abs(rnorm(nodes, colSums(network) / 2, abs(colSums(network) / 6)))

            return(network)
        },

        generate = function(sample_size, true_model) {
            # Prevent using a sample size smaller than 50.
            if (sample_size < private$.minimum_sample_size) {
                stop(paste0("Sample size must be greater than ", private$.minimum_sample_size, "."))
            }

            # Sample binary data.
            data <- IsingSampler:::IsingSamplerCpp(
                n = sample_size,
                graph = true_model,
                thresholds = diag(true_model),
                beta = 1,
                nIter = 100,
                responses = c(0, 1),
                exact = FALSE,
                constrain = matrix(NA, sample_size, ncol(true_model))
            )

            # Inform user about the status of the data.
            if (private$.has_zero_variance(data)) {
                stop("Variable(s) with SD = 0 detected. Increase sample size.")
            }

            return(data)
        },

        # Adapted from: https://github.com/cvborkulo/IsingFit.
        estimate = function(data, and = TRUE, gamma = 0.25) {
            # Number of variables and observations.
            n_var <- ncol(data)
            n_obs <- nrow(data)

            # Number of predictors (i.e., all other variables in the dataset).
            n_pred <- n_var - 1

            # Create storage for `glmnet` fit results.
            intercepts <- vector(mode = "list", length = n_var)
            betas <- vector(mode = "list", length = n_var)
            lambdas <- vector(mode = "list", length = n_var)

            # Number of lambdas.
            n_lambdas <- rep(0, n_var)

            # Fit for each variable in turn.
            for (i in 1:n_var) {
                # Fit regularized logistic regression.
                fit <- glmnet::glmnet(data[, -i], data[, i], family = "binomial")

                # Extract and store results.
                intercepts[[i]] <- fit$a0
                betas[[i]] <- as.matrix(fit$beta)
                lambdas[[i]] <- fit$lambda

                # Number of penalty values (i.e., tunning parameters) tried.
                n_lambdas[i] <- length(lambdas[[i]])
            }

            # Maximum number of lambdas used by `glmnet`.
            max_n_lambdas <- max(n_lambdas)

            # The number of neighbors.
            n_neighbors <- matrix(0, max_n_lambdas, n_var)

            # Log-likelihood storage for each variable and penalty parameter.
            log_likelihood <- array(0, dim = c(n_obs, max_n_lambdas, n_var))

            # Lambda matrix.
            lambda_mat <- matrix(NA, max_n_lambdas, n_var)

            # Compute likelihood and the number of neighbors for each variable.
            for (i in 1:n_var) {
                # Compute number of neighbors.
                n_neighbors[1:n_lambdas[i], i] <- colSums(betas[[i]] != 0)

                # Calculate likelihood (i.e., equation 1 in van Borkulo et al., 2014).

                # Extract predictors.
                predictors <- data[, -i]

                # Create storage for the sum of beta coefficients times predictors.
                y <- matrix(0, n_obs, n_lambdas[i])

                # For each predictor.
                for (k in 1:n_pred) {
                    # Extract the beta coefficients.
                    b <- matrix(betas[[i]][k, ], n_obs, n_lambdas[i], TRUE)

                    # Collect the sum.
                    y <- y + b * predictors[, k]
                }

                # Add the intercept (i.e., tau) term to the sum.
                y <- matrix(intercepts[[i]], n_obs, n_lambdas[i], TRUE) + y

                # Handle `NA` due to uneven number of tuning parameters.
                n_missing_lambdas <- max_n_lambdas - n_lambdas[i]

                # If there are missing lambdas, append NAs.
                if(n_missing_lambdas > 0) {
                    y <- cbind(y, matrix(NA, n_obs, n_missing_lambdas))
                }

                # Calculate log-likelihood.
                log_likelihood[, , i] <- log(exp(y * data[, i]) / (1 + exp(y)))

                # Fill lambda matrix.
                lambda_mat[, i] <- c(lambdas[[i]], rep(NA, max_n_lambdas - n_lambdas[i]))
            }

            # Sum log-likelihood (i.e., lambdas by variables).
            sum_log_likelihood <- colSums(log_likelihood, 1, na.rm = FALSE)

            # Mark any zero log-likelihood as missing (?).
            sum_log_likelihood[sum_log_likelihood == 0] <- NA

            # EBIC penalty part.
            penalty <- n_neighbors * log(n_obs) + 2 * gamma * n_neighbors * log(n_pred)

            # Compute the EBIC.
            ebic <- -2 * sum_log_likelihood + penalty

            # Get indices for optimal lambdas based on minimizing the EBIC.
            lambda_optimal_indices <- apply(ebic, 2, which.min)

            # Optimal thresholds (i.e., intercepts, or tau values).
            thresholds_optimal <- vector(mode = "numeric", length = n_var)

            # Optimal weights (i.e., slopes, or beta values).
            asymmetric_weights_optimal <- matrix(NA, n_var, n_var)

            # Store optimal values for each variable.
            for (i in 1:n_var) {
                # Thresholds.
                thresholds_optimal[i] <- intercepts[[i]][lambda_optimal_indices[i]]

                # Weights.
                asymmetric_weights_optimal[i, -i] <- betas[[i]][, lambda_optimal_indices[i]]
            }

            # Apply rule to create symmetrical weights matrix for the undirected graph.
            if (and) {
                # Apply the "AND" rule (i.e., ensure pairs of betas in both directions are non-zero).
                adjacency <- (asymmetric_weights_optimal != 0) * 1
                weights <- adjacency * t(adjacency) * asymmetric_weights_optimal

                # Take the mean.
                weights_optimal <- (weights + t(weights)) / 2
            } else {
                # Apply the "OR" rule (i.e., take the mean of pairs of beta coefficients).
                weights_optimal <- (asymmetric_weights_optimal + t(asymmetric_weights_optimal)) / 2
            }

            # Set the thresholds on the diagonal.
            diag(weights_optimal) <- thresholds_optimal

            return(weights_optimal)
        },

        evaluate = function(true_parameters, estimated_parameters, measure, ...) {
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
