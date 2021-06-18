#' @include Model.R

GgmModel <- R6::R6Class("GgmModel",
    inherit = Model,

    private = list(
        .tp = NULL,
        .fp = NULL,
        .tn = NULL,
        .fn = NULL,

        .compute_rates = function(true_parameters, estimated_parameters) {
            # Get the true and estimated edges.
            true <- true_parameters[upper.tri(true_parameters)]
            esti <- estimated_parameters[upper.tri(estimated_parameters)]

            # True/ false | positive/ negative rates.
            private$.tp <- sum(true != 0 & esti != 0)
            private$.fp <- sum(true == 0 & esti != 0)
            private$.tn <- sum(true == 0 & esti == 0)
            private$.fn <- sum(true != 0 & esti == 0)
        },

        .sen = function() {
            return(private$.tp / (private$.tp + private$.fn))
        },

        .spe = function() {
            return(private$.tn / (private$.tn + private$.fp))
        },

        .mcc = function() {
            return((private$.tp * private$.tn - private$.fp * private$.fn) / sqrt((private$.tp + private$.fp) * (private$.tp + private$.fn) * (private$.tn + private$.fp) * (private$.tn + private$.fn)))
        }
    ),

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

        estimate = function(data) {
            return(bootnet::estimateNetwork(data, default = "EBICglasso", verbose = FALSE)$graph)
        },

        evaluate = function(true_parameters, estimated_parameters, measure) {
            # Compute rates because they are required for most of all other measures.
            private$.compute_rates(true_parameters, estimated_parameters)

            # Compute correct measure.
            return(switch(measure,
                sen = private$.sen(),
                spe = private$.spe(),
                mcc = private$.mcc(),
                rho = ifelse(length(true_parameters) == length(estimated_parameters), cor(true_parameters, estimated_parameters, use = "complete.obs"), NA),
                stop(.__ERRORS__$not_developed)
            ))
        }
    )
)
