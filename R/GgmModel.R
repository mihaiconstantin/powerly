#' @include Model.R

GgmModel <- R6::R6Class("GgmModel",
    inherit = Model,

    private = list(
        .minimum_sample_size = 50,
        .max_resampling_attempts = 3,

        .has_zero_variance = function(data) {
            return(any(apply(data, 2, sd) == 0))
        },

        # Sample multivariate normal data.
        .sample_data = function(sample_size, sigma) {
            # Sample data.
            data <- mvtnorm::rmvnorm(sample_size, sigma = sigma)

            return(data)
        },

        # Split data into item steps (i.e., Likert scale).
        .threshold_data = function(data, levels) {
            # Create storage for ordinal data.
            data_ordinal <- matrix(0, nrow(data), ncol(data))

            # Split the data into item steps (i.e., Likert scale).
            for (i in 1:ncol(data)) {
                data_ordinal[, i] <- as.numeric(cut(data[, i], sort(c(-Inf, rnorm(levels - 1), Inf))))
            }

            return(data_ordinal)
        }
    ),

    public = list(
        create = function(nodes, density, positive = .9, constant = 1.5, range = c(0.5, 1)) {
            return(bootnet::genGGM(
                Nvar = nodes,
                p = density,
                propPositive = positive,
                constant = constant,
                parRange = range,
                graph = "random"
            ))
        },

        generate = function(sample_size, true_parameters, levels = 5) {
            # Prevent using a sample size smaller than 50.
            if (sample_size < private$.minimum_sample_size) {
               stop(paste0("Sample size must be greater than ", private$.minimum_sample_size, "."))
            }

            # Convert partial correlations to correlations.
            sigma <- cov2cor(solve(diag(ncol(true_parameters)) - true_parameters))

            # Sample multivariate normal data.
            data <- private$.sample_data(sample_size, sigma)

            # Set item steps.
            if (levels > 1) {
                # Make ordinal.
                data <- private$.threshold_data(data, levels)

                # Resampling attempts.
                attempts = 0

                # Check for invariant variables and attempt to correct.
                while(private$.has_zero_variance(data) && attempts < private$.max_resampling_attempts) {
                    # Record attempt.
                    attempts = attempts + 1

                    # Sample normal data.
                    data <- private$.sample_data(sample_size, sigma)

                    # Make ordinal.
                    data <- private$.threshold_data(data, levels)
                }
            }

            # Inform user about the status of the data.
            if (private$.has_zero_variance(data)) {
                stop("Variable(s) with SD = 0 detected. Increase sample size.")
            }

            return(data)
        },

        estimate = function(data, gamma = 0.5) {
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
