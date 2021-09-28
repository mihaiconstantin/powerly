#' @include Basis.R Spline.R Interpolation.R

StepTwo <- R6::R6Class("StepTwo",
    private = list(
        .step_1 = NULL,
        .spline = NULL,
        .interpolation = NULL,
        .cv = NULL,

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
            # Reset any previous spline before re-fitting.
            private$.clear_spline()

            # Perform LOOCV.
            private$.run_cv(monotone = monotone, increasing = increasing, df = df, solver_type = solver_type, ...)

            # Find spline coefficients.
            private$.fit(monotone = monotone, increasing = increasing, solver_type = solver_type, ...)

            # Interpolate the entire range used during Step 1.
            private$.interpolate(...)
        },

        plot = function(save = FALSE, path = NULL, width = 14, height = 10, ...) {
            # Data statistic.
            data_statistics <- data.frame(
                x = private$.step_1$range$partition,
                observed = private$.step_1$statistics,
                predicted = private$.spline$fitted
            )

            # Data spline values.
            data_spline_values <- data.frame(
                x = private$.interpolation$x,
                y = private$.interpolation$fitted
            )

            # Data spline coefficients.
            data_spline_alpha <- data.frame(
                x = as.factor(1:ncol(private$.spline$basis$matrix)),
                y = private$.spline$alpha
            )

            # Data basis matrix.
            data_spline_basis <- data.frame(
                x = as.factor(rep(private$.spline$basis$x, ncol(private$.spline$basis$matrix))),
                y = as.numeric(private$.spline$basis$matrix),
                basis = as.factor(sort(rep(1:ncol(private$.spline$basis$matrix), nrow(private$.spline$basis$matrix))))
            )

            # Data cross-validation.
            data_cv <- data.frame(
                df = sort(rep(private$.cv$df, nrow(private$.cv$se))),
                se = as.numeric(private$.cv$se),
                sample = rep(private$.spline$basis$x, ncol(private$.cv$se)),
                mse_df = rep(private$.cv$mse, each = nrow(private$.cv$se)),
                mse_sample = rep(apply(private$.cv$se, 1, mean), ncol(private$.cv$se)),
                first_se_sample = rep(private$.cv$se[, 1], ncol(private$.cv$se)),
                first_se_df = rep(private$.cv$se[1, ], each = nrow(private$.cv$se))
            )

            # Common plot theme settings.
            .__PLOT_SETTINGS__ <- c(plot_settings(), list(
                ggplot2::theme(
                    legend.position = "none"
                )
            ))

            # Spline plot.
            plot_spline <- ggplot2::ggplot(data_spline_values, ggplot2::aes(x = x, y = y)) +
                ggplot2::geom_line(
                    size = 1,
                    color = "rosybrown"
                ) +
                ggplot2::geom_point(
                    data = data_statistics,
                    mapping = ggplot2::aes(x = x, y = observed),
                    fill = "#3f51b5",
                    color = "#3f51b5",
                    size = 1.5,
                    shape = 23
                ) +
                ggplot2::geom_point(
                    data = data_statistics,
                    mapping = ggplot2::aes(x = x, y = predicted),
                    fill = "#7c2929",
                    color = "#7c2929",
                    size = 1.5,
                    shape = 19
                ) +
                ggplot2::geom_hline(
                    yintercept = private$.step_1$statistic_value,
                    color = "#8b0000",
                    linetype = "dotted",
                    size = .65
                ) +
                ggplot2::labs(
                    title = paste0("Fitted spline | DF = ",  private$.spline$basis$df, " | SSQ = ", round(self$ssq, 4)),
                    x = "Candidate Sample Size Range",
                    y = "Statistic Value"
                ) +
                ggplot2::scale_y_continuous(
                    breaks = seq(0, 1, .1)
                ) +
                ggplot2::scale_x_continuous(
                    breaks = private$.step_1$range$partition
                ) +
                .__PLOT_SETTINGS__

            plot_coefficients <- ggplot2::ggplot(data_spline_alpha, ggplot2::aes(x = x, y = y)) +
                ggplot2::geom_point(
                    shape = 17,
                    size = 1.5,
                    color = "darkred",
                    fill = "darkred"
                ) +
                ggplot2::geom_text(
                    mapping = ggplot2::aes(y = y - 0.04),
                    label = round(data_spline_alpha$y, 2),
                    fontface = "bold",
                    size = 2.8
                ) +
                ggplot2::geom_hline(
                    yintercept = 0,
                    color = "#2c2c2c",
                    linetype = "dotted",
                    size = .65,
                    alpha = .7
                ) +
                ggplot2::coord_cartesian(
                    ylim = c(min(data_spline_alpha$y) - .2, max(data_spline_alpha$y) + .2)
                ) +
                ggplot2::scale_y_continuous(
                    breaks = round(seq(min(data_spline_alpha$y) - .2, max(data_spline_alpha$y) + .2, .2), 2)
                ) +
                ggplot2::labs(
                    title = "Spline coefficients",
                    x = "Basis function",
                    y = "Spline coefficient value"
                ) +
                .__PLOT_SETTINGS__

            plot_basis <- ggplot2::ggplot(data_spline_basis, ggplot2::aes(x = x, y = y, color = basis, group = basis)) +
                ggplot2::geom_line(
                    mapping = ggplot2::aes(lty = basis),
                    size = .7
                ) +
                ggplot2::labs(
                    title = "Basis matrix",
                    x = "Sample size",
                    y = "Basis function value"
                ) +
                .__PLOT_SETTINGS__

            plot_cv <- ggplot2::ggplot(data_cv, ggplot2::aes(x = df, y = se, color = as.factor(sample))) +
                ggplot2::geom_line(
                    size = .75,
                    alpha = .15
                ) +
                ggplot2::geom_point(
                    size = 1,
                    shape = 19,
                    alpha = .15,
                ) +
                ggplot2::geom_line(
                    mapping = ggplot2::aes(
                        y = mse_df
                    ),
                    size = 1,
                    color = "#000000"
                ) +
                ggplot2::geom_point(
                    mapping = ggplot2::aes(
                        y = mse_df
                    ),
                    size = 1.5,
                    shape = 19,
                    color = "#000000"
                ) +
                ggplot2::geom_text(
                    mapping = ggplot2::aes(
                        x = min(df) - .75,
                        y = first_se_sample,
                        label = sample
                    ),
                    size = 2.8,
                    alpha = .05
                ) +
                ggplot2::geom_vline(
                    xintercept = data_cv$df[which.min(data_cv$mse_df)],
                    color = "#2c2c2c",
                    linetype = "dotted",
                    size = .65,
                    alpha = .7
                ) +
                ggplot2::scale_x_continuous(
                    breaks = unique(data_cv$df)
                ) +
                ggplot2::labs(
                    title = "LOOCV | SE (color) | MSE (dark)",
                    x = "Spline degrees of freedom",
                    y = "Squared error"
                ) +
                .__PLOT_SETTINGS__

            plot_cv_error <- ggplot2::ggplot(data_cv, ggplot2::aes(x = sample, y = se, color = as.factor(df))) +
                ggplot2::geom_line(
                    size = .75,
                    alpha = .15
                ) +
                ggplot2::geom_point(
                    size = 1,
                    shape = 19,
                    alpha = .15,
                ) +
                ggplot2::geom_line(
                    mapping = ggplot2::aes(
                        y = mse_sample
                    ),
                    size = 1,
                    color = "#000000"
                ) +
                ggplot2::geom_point(
                    mapping = ggplot2::aes(
                        y = mse_sample
                    ),
                    size = 1.5,
                    shape = 19,
                    color = "#000000"
                ) +
                ggplot2::geom_text(
                    mapping = ggplot2::aes(
                        x = min(sample) - (sample[2] - sample[1]) * .6,
                        y = first_se_df,
                        label = df
                    ),
                    size = 2.8,
                    alpha = .05
                ) +
                ggplot2::scale_x_continuous(
                    breaks = private$.step_1$range$partition
                ) +
                ggplot2::labs(
                    title = "Training prediction | SE (color) | MSE (dark)",
                    y = "Squared error",
                    x = "Sample size"
                ) +
                .__PLOT_SETTINGS__

            # Define the margins.
            margin_plot_top <- ggplot2::theme(plot.margin = ggplot2::margin(t = 0, r = 0, b = 0, l = 0))
            margin_plot_left <- ggplot2::theme(plot.margin = ggplot2::margin(t = 15, r = 7.5, b = 0, l = 0))
            margin_plot_right <- ggplot2::theme(plot.margin = ggplot2::margin(t = 15, r = 0, b = 0, l = 7.5))

            # Adjust plot margins.
            plot_spline <- plot_spline & margin_plot_top
            plot_coefficients <- plot_coefficients & margin_plot_left
            plot_basis <- plot_basis & margin_plot_right
            plot_cv <- plot_cv & margin_plot_left
            plot_cv_error <- plot_cv_error & margin_plot_right

            # Prepare plot layout.
            plot_step_2 <- plot_spline /
                (plot_coefficients | plot_basis) /
                (plot_cv | plot_cv_error) +
                plot_layout(heights = c(1.5, 1, 1))

            # Save the plot.
            if (save) {
                if (is.null(path)) {
                    # If no path is provided, create one.
                    path <- paste0(getwd(), "/", "step-2", "_", gsub(":|\\s", "-", as.character(Sys.time()), perl = TRUE), ".pdf")
                }

                # Save the plot.
                ggplot2::ggsave(path, plot = plot_step_2, width = width, height = height, ...)
            } else {
                # Show the plot.
                plot(plot_step_2)
            }

            # Return the plot object silently.
            invisible(plot_step_2)
        }
    ),

    active = list(
        step_1 = function() { return(private$.step_1) },
        spline = function() { return(private$.spline) },
        interpolation = function() { return(private$.interpolation) },
        cv = function() { return(private$.cv) },
        ssq = function() {
            return(sum((private$.step_1$statistics - private$.spline$fitted) ^ 2))
        }
    )
)
