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

        # Make a partition from the bounds.
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

        # Make sequence based on the bounds.
        .make_sequence = function() {
            # Make the sequence.
            private$.sequence <- min(private$.partition):max(private$.partition)

            # Store the sequence length.
            private$.sequence_length <- length(private$.sequence)
        },

        # The logic for the convergence test.
        .convergence_test = function(lower, upper) {
            return((as.numeric(upper) - as.numeric(lower)) <= private$.tolerance)
        }
    ),

    public = list(
        initialize = function(lower, upper, samples = 20, tolerance = 50) {
            private$.lower = lower
            private$.upper = upper
            private$.samples = samples
            private$.tolerance = tolerance

            # Ensure a reasonably wide range was provided.
            if (private$.convergence_test(lower, upper)) {
                # Stop if the range is too small.
                stop("Please provide a range wider than the tolerance.")
            }

            # Make the rest of the range components.
            private$.converged <- FALSE
            private$.make_partition()
            private$.make_sequence()
        },

        # Check convergence.
        update_convergence = function(step_3) {
            # Extract bounds.
            lower <- step_3$samples[step_3$lower_ci_string]
            upper <- step_3$samples[step_3$upper_ci_string]

            # Perform convergence test and update with results.
            private$.converged <- private$.convergence_test(lower, upper)
        },

        # Update the range based on Step 3 bootstrapping.
        update_bounds = function(step_3, lower_ci = 0.025, upper_ci = 0.975) {
            # Update bounds based on confidence intervals of Step 3.
            private$.lower <- step_3$samples[paste0(lower_ci * 100, "%")]
            private$.upper <- step_3$samples[paste0(upper_ci * 100, "%")]

            # Recreate range components.
            private$.make_partition()
            private$.make_sequence()
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
