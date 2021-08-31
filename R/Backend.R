Backend <- R6::R6Class("Backend",
    cloneable = FALSE,

    private = list(
        .available_cores = NULL,
        .allowed_cores = NULL,
        .active = FALSE,
        .cores = NULL,
        .cluster = NULL,
        .type = NULL,
        .allowed_types = c(unix = "fork", windows = "psock"),

        # Set the cores (i.e., the number of clusters to create).
        .set_cores = function(cores) {
            # Abort if less than two cores are available.
            if (private$.available_cores < 2) {
                stop("Not enough cores available on the machine.")
            }

            # Determine the number of allowed cores.
            if (private$.available_cores == 2) {
                # If only two cores are available, use both.
                private$.allowed_cores <- private$.available_cores
            } else {
                # Otherwise, keep one core free.
                private$.allowed_cores <- private$.available_cores - 1
            }

            # Ensure at least two cores are used.
            if (cores < 2) {
                # Warn the user.
                warning("Argument `cores` must be greater than 1. Setting to 2.")

                # Set the cores.
                private$.cores <- 2

            # Ensure at least one core is left free.
            } else if (cores > private$.allowed_cores) {
                # Warn the user.
                warning(paste0("Argument `cores` cannot be larger than ", private$.allowed_cores, ". Setting to ", private$.allowed_cores, "."))

            # Honor the user request without any constraints.
            } else {
                private$.cores <- cores
            }
        },

        # Select cluster type based on OS.
        .set_type = function(type) {
            # Check if the provided type is known.
            if (!is.null(type)) {
                if (!tolower(type) %in% private$.allowed_types) {
                    # Warn if an unknown cluster is provided.
                    warning(paste0("Argument `type` must be ", paste0("'", private$.allowed_types, "'", collapse = " or ", sep = ""), ". Defaulting to '", private$.allowed_types["windows"], "'."))

                    # Default to 'PSOCK'.
                    private$.type <- toupper(private$.allowed_types["windows"])
                } else {
                    # Set the cluster as requested.
                    private$.type <- toupper(type)
                }
            # If no type is provided infer based on the platform.
            } else {
                if (.Platform$OS.type == "unix") {
                    # Select type for Unix.
                    private$.type <- toupper(private$.allowed_types["unix"])
                } else {
                    # Select type for Windows.
                    private$.type <- toupper(private$.allowed_types["windows"])
                }
            }
        },

        # Start the cluster.
        .start = function(cores, type) {
            # If a cluster is already active then stop.
            if (private$.active) {
                stop("A cluster is already active. Please stop it before starting a new one.")
            }

            # Determine the number of available cores on the machine.
            private$.available_cores <- parallel::detectCores()

            # Set the number of cores.
            private$.set_cores(cores)

            # Figure out the optimal cluster type.
            private$.set_type(type)

            # Make the cluster.
            private$.cluster <- parallel::makeCluster(private$.cores, private$.type)

            # Sanitize the cluster.
            private$.clear()

            # Set the active flag.
            private$.active <- TRUE
        },

        # Stop the cluster.
        .stop = function() {
            # Check if there is anything to stop.
            if (!private$.active) {
               stop("No active cluster to stop.")
            }

            # Stop the cluster.
            parallel::stopCluster(private$.cluster)

            # Toggle the active flag.
            private$.active <- FALSE

            # Reset cluster information.
            private$.cluster <- NULL
            private$.available_cores <- NULL
            private$.allowed_cores <- NULL
            private$.cores <- NULL
            private$.type <- NULL
        },

        # Export variables.
        .export = function(variables, environment) {
            # Export to the cluster.
            parallel::clusterExport(private$.cluster, variables, environment)
        },

        # Clear data on the cluster.
        .clear = function() {
            # Evaluate the expression on the cluster.
            parallel::clusterEvalQ(private$.cluster, rm(list = ls(all.names = TRUE)))

            # Remain silent.
            invisible()
        },

        # Inspect what is on the cluster.
        .inspect = function() {
            # Check what is on the cluster.
            parallel::clusterEvalQ(private$.cluster, ls(all.names = TRUE))
        },

        # A wrapper around `parallel:parSapply` to run tasks on the cluster.
        .sapply = function(x, fun, ...) {
            return(parallel::parSapply(private$.cluster, X = x, FUN = fun, ...))
        },

        # A wrapper around `parallel:parApply` to run tasks on the cluster.
        .apply = function(x, margin, fun, ...) {
            return(parallel::parApply(private$.cluster, X = x, MARGIN = margin, FUN = fun, ...))
        },

        # Adopt an external cluster to be managed via the backend.
        .adopt = function(cluster) {
            # Only adopt if no other cluster is active.
            if(private$.active) {
                stop("Cannot adopt external cluster while there is another active cluster.")
            }

            # Adopt it.
            private$.cluster <- cluster

            # Record the number of clusters.
            private$.cores <- length(cluster)

            # Set the active flag.
            private$.active <- TRUE

            # Indicate that the cluster is adopted.
            private$.type = "adopted"

            # Sanitize the cluster.
            private$.clear()
        }
    ),

    public = list(
        # Destructor.
        finalize = function() {
            # If a cluster is active, stop before deleting the instance.
            if (private$.active) {
                # Stop the cluster.
                private$.stop()
            }
        },

        # Start the cluster.
        start = function(cores, type = NULL) {
            private$.start(cores, type)
        },

        # Stop the cluster.
        stop = function() {
            private$.stop()
        },

        # Export variables to a cluster.
        export = function(variables, environment) {
            private$.export(variables, environment)
        },

        # Clear any residual data on the cluster.
        clear = function() {
            private$.clear()
        },

        # Inspect what is on the cluster.
        inspect = function() {
            private$.inspect()
        },

        # Evaluate an arbitrary expression on the cluster.
        evaluate = function(expression) {
            # Evaluate the expression.
            parallel::clusterCall(private$.cluster, eval, substitute(expression), env = .GlobalEnv)
        },

        # Run tasks on the cluster in an `sapply` fashion.
        sapply = function(x, fun, ...) {
            # Run the task.
            return(private$.sapply(x, fun, ...))
        },

        # Run tasks on the cluster in an `apply` fashion.
        apply = function(x, margin, fun, ...) {
            # Run the task.
            return(private$.apply(x, margin, fun, ...))
        },

        # Adaptor a cluster that was created externally.
        adopt = function(cluster) {
            private$.adopt(cluster)
        }
    ),

    active = list(
        active = function() { return(private$.active) },
        cores = function() { return(private$.cores) },
        type = function() { return(private$.type) },
        cluster = function() { return(private$.cluster) }
    )
)
