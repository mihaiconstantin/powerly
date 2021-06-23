Range <- R6::R6Class("Range",
    private = list(
        .lower = NULL,
        .upper = NULL,
        .samples = NULL,
        .tolerance = NULL,
        .converged = NULL,
        .available_samples = NULL,
        .partition = NULL,
        .sequence = NULL,
        .sequence_length = NULL,

        .make_partition = function() {
            # Check that the range has valid bounds.
            if(private$.lower > private$.upper) {
                stop("The lower bound cannot be greater that the upper bound.")
            }

            # Make partition.
            private$.partition <- unique(floor(seq(private$.lower, private$.upper, length.out = private$.samples)))

            # Record how many samples are in the partition.
            private$.available_samples <- length(private$.partition)
        },

        .make_sequence = function() {
            # Make the sequence.
            private$.sequence <- min(private$.partition):max(private$.partition)

            # Store the sequence length.
            private$.sequence_length <- length(private$.sequence)
        },

        .update_convergence = function(lower, upper) {
            if((upper - lower) <= private$.tolerance) {
                private$.converged <- TRUE
            } else {
                private$.converged <- FALSE
            }
        },

        # Trim based on the step 3 bootstrapping.
        .update_bounds = function(lower, upper) {
            # Trimming.
            private$.lower <- lower
            private$.upper <- upper
        }
    ),

    public = list(
        initialize = function(lower, upper, samples = 20, tolerance = 50) {
            private$.lower = lower
            private$.upper = upper
            private$.samples = samples
            private$.tolerance = tolerance

            private$.update_convergence(lower, upper)
            private$.make_partition()
            private$.make_sequence()
        },

        # Update the range based on Step 3 bootstrapping.
        update = function(step_3, lower_ci = "2.5%", upper_ci = "97.5%") {
            # Get confidence intervals at the statistic value of interest.
            ci <- step_3$get_ci_at_statistic_value()

            # Extract bounds.
            lower <- ci[lower_ci]
            upper <- ci[upper_ci]

            # Update convergence status.
            private$.update_convergence(lower, upper)

            # If it hasn't converged, update the bounds and recreate the partition.
            if(!private$.converged) {
                # Update bounds based on confidence intervals of Step 3.
                private$.update_bounds(lower, upper)

                # Recreate range components.
                private$.make_partition()
                private$.make_sequence()
            }
        }
    ),

    active = list(
        lower = function() { return(private$.lower) },
        upper = function() { return(private$.upper) },
        samples = function() { return(private$.samples) },
        tolerance = function() { return(private$.tolerance) },
        converged = function() { return(private$.converged) },
        available_samples = function() { return(private$.available_samples) },
        partition = function() { return(private$.partition) },
        sequence = function() { return(private$.sequence) },
        sequence_length = function() { return(private$.sequence_length) }
    )
)
