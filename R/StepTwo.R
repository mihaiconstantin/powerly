#' @include Basis.R Spline.R Interpolation.R

StepTwo <- R6::R6Class("StepTwo",
    private = list(
        .step_1 = NULL,
        .spline = NULL,
        .interpolation = NULL,
        .cv = NULL,

        .duration = NULL,

        # Decide how many DF can be used during the LOOCV.
        .check_df = function(df, monotone) {
            # If we have an I-Spline then we can start 1 degree of freedom lower.
            if (monotone) {
                min_df <- 3
            } else {
                min_df <- 4
            }

            # Determine the maximum number of degrees of freedom (i.e., justify in the paper).
            max_df <- private$.step_1$range$available_samples - 2

            # Determine DF for LOOCV.
            if (is.null(df)) {
                # Never try more than 20 degrees of freedom.
                max_df <- ifelse(max_df > 20, 20, max_df)

                # Create the DF sequence for testing.
                df <- seq(min_df, max_df, 1)

            # Manually override the DF. Can exceed 20 limit because of manual override.
            } else {
                # Stop if the highest DF is too large.
                if (max(df) > max_df) {
                    stop(paste0("Degree of freedom '", max(df), "' cannot exceed `length(samples) - 2` (i.e., '", max_df, "')."))
                }

                # Stop if the lowest DF is too large.
                if (min(df) < min_df) {
                    stop(paste0("Degree of freedom '", min(df), "' cannot be lower that '", min_df, "'."))
                }

                # Sort the DFs and remove duplicates.
                df <- unique(sort(df))
            }

            return(df)
        },

        # Reset any previously fitted spline.
        .clear_spline = function() {
            private$.spline <- NULL
            private$.interpolation <- NULL
            private$.cv <- NULL
        },

        .run_cv = function(monotone, increasing, df, solver_type, ...) {
            # Check the DFs before LOOCV.
            df <- private$.check_df(df, monotone)

            # Storage for the squared errors.
            se <- matrix(NA, private$.step_1$range$available_samples, length(df))

            # Get the actual boundary knots.
            boundary_knots <- range(private$.step_1$range$partition)

            # Create solver.
            solver <- SolverFactory$new()$get_solver(solver_type)

            for (i in 1:private$.step_1$range$available_samples) {
                # Training data.
                x_train <- private$.step_1$range$partition[-i]
                y_train <- private$.step_1$statistics[-i]

                # Test data.
                x_test <- private$.step_1$range$partition[i]
                y_test <- private$.step_1$statistics[i]

                for (j in 1:length(df)) {
                    # Create training basis.
                    basis_train <- Basis$new(x = x_train, df = df[j], monotone = monotone, Boundary.knots = boundary_knots, ...)

                    # Setup the solver for the training basis.
                    solver$setup(basis_train, y_train, increasing)

                    # Estimate the spline coefficients.
                    spline_train <- Spline$new(basis = basis_train, solver)
                    spline_train$estimate_alpha()

                    # Predict.
                    basis_test <- basis_train$extend(x_new = x_test, ...)
                    y_hat <- basis_test %*% spline_train$alpha

                    # Compute error.
                    se[i, j] <- (y_test - y_hat)^2
                }
            }

            # Store the results.
            private$.cv <- list(
                se = se,
                df = df,
                mse = colMeans(se, na.rm = TRUE),
                sd = apply(se, 2, sd, na.rm = TRUE)
            )
        },

        .fit = function(monotone, increasing, solver_type, ...) {
            # Determine best DF based on MSE.
            df <- private$.cv$df[which.min(private$.cv$mse)]

            # Create spline basis.
            basis <- Basis$new(x = private$.step_1$range$partition, df, monotone, ...)

            # Create the solver.
            solver <- SolverFactory$new()$get_solver(solver_type)

            # Setup the solver.
            solver$setup(basis, private$.step_1$statistics, increasing)

            # Create spline.
            private$.spline <- Spline$new(basis, solver)

            # Fit the spline.
            private$.spline$estimate_alpha()
            private$.spline$predict_values()
        },

        .interpolate = function(...) {
            private$.interpolation <- Interpolation$new(private$.spline, ...)
        }
    ),

    public = list(
        initialize = function(step_1) {
            private$.step_1 <- step_1
        },

        fit = function(monotone = TRUE, increasing = TRUE, df = NULL, solver_type = "quadprog", ...) {
            # Time when the fitting started.
            start_time <- Sys.time()

            # Reset any previous spline before re-fitting.
            private$.clear_spline()

            # Perform LOOCV.
            private$.run_cv(monotone = monotone, increasing = increasing, df = df, solver_type = solver_type, ...)

            # Find spline coefficients.
            private$.fit(monotone = monotone, increasing = increasing, solver_type = solver_type, ...)

            # Interpolate the entire range used during Step 1.
            private$.interpolate(...)

            # Compute how long the simulation took.
            private$.duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
        }
    ),

    active = list(
        step_1 = function() { return(private$.step_1) },
        spline = function() { return(private$.spline) },
        interpolation = function() { return(private$.interpolation) },
        cv = function() { return(private$.cv) },
        ssq = function() {
            return(sum((private$.step_1$statistics - private$.spline$fitted) ^ 2))
        },
        duration = function() { return(private$.duration) }
    )
)
