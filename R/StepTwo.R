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

        .run_cv = function(monotone, increasing, df, ...) {
            # Check the DFs before LOOCV.
            df <- private$.check_df(df, monotone)

            # Storage for the squared errors.
            se <- matrix(NA, private$.step_1$range$available_samples, length(df))

            # Get the actual boundary knots.
            boundary_knots <- range(private$.step_1$range$partition)

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

                    # Create solver for the training basis.
                    solver <- Solver$new(basis_train, y_train, increasing)

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

        .fit = function(monotone, increasing, ...) {
            # Determine best DF based on MSE.
            df <- private$.cv$df[which.min(private$.cv$mse)]

            # Create spline basis.
            basis <- Basis$new(x = private$.step_1$range$partition, df, monotone, ...)

            # Create the solver.
            solver <- Solver$new(basis, private$.step_1$statistics, increasing)

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

        fit = function(monotone = TRUE, increasing = TRUE, df = NULL, ...) {
            # Perform LOOCV.
            private$.run_cv(monotone = monotone, increasing = increasing, df = df, ...)

            # Find spline coefficients.
            private$.fit(monotone = monotone, increasing = increasing, ...)

            # Interpolate the entire range used during Step 1.
            private$.interpolate(...)
        },

        plot = function() {
            # Revert changes on exit.
            on.exit({
                # Reset layout.
                layout(1:1)

                # Reset margins.
                par(mar = c(5.1, 4.1, 4.1, 2.1))
            })

            # Set layout.
            layout(matrix(c(1, 1, 2, 3, 4, 5), 3, 2, byrow = TRUE))

            # Adjust margins for layout.
            par(mar = c(5.1, 4.1, 4.1, 2.1) + 1)

            # Plot the fitted spline.
            plot(
                NULL,
                xlim = c(min(private$.step_1$range$partition), max(private$.step_1$range$partition)),
                ylim = c(min(min(private$.spline$fitted), min(private$.step_1$statistics)) , max(max(private$.spline$fitted), max(private$.step_1$statistics))),
                xlab = "",
                ylab = "",
                xaxt = "n",
                yaxt = "n"
            )
            title(
                main = paste0("Fitted spline | DF = ",  private$.spline$basis$df, " | SSQ = ", round(self$ssq, 4)),
                ylab = paste0("Value for statistic '", toupper(sub("Statistic", "", class(private$.step_1$statistic)[1])), "'"),
                cex.main = 1,
                cex.lab = 1
            )
            title(
                xlab = "Sample size",
                cex.lab = 1,
                line = 4
            )
            axis(
                side = 1,
                at = private$.step_1$range$partition,
                tck = -0.01,
                las = 2,
                cex.axis = .9
            )
            axis(
                side = 2,
                cex.axis = .9,
                las = 1
            )
            abline(
                h = private$.step_1$statistic_value,
                col = "lightgray",
                lty = 3
            )
            abline(
                v = private$.spline$basis$attrs$knots,
                col = "lightgray",
                lty = 2
            )
            points(
                private$.step_1$range$partition,
                private$.step_1$statistics,
                col = "royalblue",
                pch = 19,
                cex = 1
            )
            lines(
                private$.interpolation$x,
                private$.interpolation$fitted,
                col = "rosybrown",
                lwd = 2
            )
            points(
                private$.step_1$range$partition,
                private$.spline$fitted,
                col = "#7c2929",
                pch = 19,
                cex = 1
            )

            # Plot the spline coefficients.
            plot(
                NULL,
                xlim = c(1, ncol(private$.spline$basis$matrix)),
                ylim = c(min(private$.spline$alpha) - .2, max(private$.spline$alpha) + .2),
                xlab = "",
                ylab = "",
                xaxt = "n",
                yaxt = "n"
            )
            title(
                main = paste0("Spline coefficients"),
                ylab = paste0("Spline coefficient value"),
                cex.main = 1,
                cex.lab = 1
            )
            title(
                xlab = "Basis function",
                cex.lab = 1,
                line = 4
            )
            axis(
                side = 1,
                at = 1:ncol(private$.spline$basis$matrix),
                tck = -0.01,
                cex.axis = .9,
                las = 2
            )
            axis(
                side = 2,
                cex.axis = .9,
                las = 1
            )
            abline(
                h = 0,
                col = "#2c2c2c",
                lty = 3
            )
            points(
                1:ncol(private$.spline$basis$matrix),
                private$.spline$alpha,
                col = "darkred",
                pch = 17,
                cex = 1,
            )
            text(
                1:ncol(private$.spline$basis$matrix),
                private$.spline$alpha - 0.07,
                paste(round(private$.spline$alpha, 2), sep = ""),
                col = "#2e2e2e",
                cex = .9,
                font = 2
            )

            # Plot the basis functions.
            matplot(
                private$.spline$basis$matrix,
                type = "l",
                lwd = 2,
                xlab = "",
                ylab = "",
                xaxt = "n",
                yaxt = "n"
            )
            title(
                main = paste0("Basis matrix"),
                ylab = paste0("Basis function value"),
                cex.main = 1,
                cex.lab = 1
            )
            title(
                xlab = "Sample size",
                cex.lab = 1,
                line = 4
            )
            axis(
                side = 1,
                at = 1:private$.step_1$range$available_samples,
                labels = private$.step_1$range$partition,
                tck = -0.01,
                las = 2,
                cex.axis = .9
            )
           axis(
                side = 2,
                cex.axis = .9,
                las = 1
            )

            # Plot SE results by DF.
            plot(
                NULL,
                xlim = c(min(private$.cv$df) - .5, max(private$.cv$df)),
                ylim = c(min(private$.cv$se), max(private$.cv$se)),
                xlab = "",
                ylab = "",
                xaxt = "n",
                yaxt = "n"
            )
            title(
                main = "LOOCV | SE (color) | MSE (dark)",
                ylab = "Squared error",
                cex.main = 1,
                cex.lab = 1
            )
            title(
                xlab = "Degrees of freedom",
                cex.lab = 1,
                line = 4
            )
            axis(
                side = 1,
                at = private$.cv$df,
                tck = -0.01,
                cex.axis = .9,
                las = 2
            )
           axis(
                side = 2,
                cex.axis = .9,
                las = 0
            )
            # Specify which colors to use for private$.cv$se.
            colors <- colors(TRUE)
            # Plot the SE for each sample size.
            for (j in 1:nrow(private$.cv$se)) {
                # Select a color.
                color_index <- sample(1:length(colors), 1)
                color <- adjustcolor(colors[color_index], alpha.f = 0.25)

                # Plot.
                lines(private$.cv$df, private$.cv$se[j, ], lwd = 2, col = color)
                points(private$.cv$df, private$.cv$se[j, ], lwd = 2, col = color, pch = 20)
                text(x = min(private$.cv$df) - .5, y = private$.cv$se[j, ][1], private$.step_1$range$partition[j], col = adjustcolor(colors[color_index], alpha.f = 0.9))

                # Remove color to prevent ruse in private$.cv$se.
                colors <- colors[-color_index]
            }
            lines(
                private$.cv$df,
                private$.cv$mse,
                lwd = 3,
                col = "black"
            )
            points(
                private$.cv$df,
                private$.cv$mse,
                lwd = 3,
                col = "black",
                pch = 15
            )
            abline(
                v = private$.cv$df[which.min(private$.cv$mse)],
                col = "#2c2c2c",
                lty = 2
            )

            # Plot SE results by sample size.
            text_offset <- (private$.step_1$range$partition[2] - private$.step_1$range$partition[1]) / 2
            plot(
                NULL,
                xlim = c(min(private$.step_1$range$partition) - text_offset, max(private$.step_1$range$partition)),
                ylim = c(min(private$.cv$se), max(private$.cv$se)),
                xlab = "",
                ylab = "",
                xaxt = "n",
                yaxt = "n"
            )
            title(
                main = "Training prediction | SE (color) | MSE (dark)",
                ylab = "Squared error",
                cex.main = 1,
                cex.lab = 1
            )
            title(
                xlab = "Sample size",
                cex.lab = 1,
                line = 4
            )
            axis(
                side = 1,
                at = private$.step_1$range$partition,
                tck = -0.01,
                las = 2,
                cex.axis = .9
            )
           axis(
                side = 2,
                cex.axis = .9,
                las = 0
            )
            # Plot the SE for each sample size.
            for (j in 1:ncol(private$.cv$se)) {
                # Select a color.
                color_index <- sample(1:length(colors), 1)
                color <- adjustcolor(colors[color_index], alpha.f = 0.25)

                # Plot.
                lines(private$.step_1$range$partition, private$.cv$se[, j], lwd = 2, col = color)
                points(private$.step_1$range$partition, private$.cv$se[, j], lwd = 2, col = color, pch = 20)
                text(x = min(private$.step_1$range$partition) - text_offset, y = private$.cv$se[j, ][1], private$.cv$df[j], col = adjustcolor(colors[color_index], alpha.f = 0.9))

                # Remove color to prevent reuprivate$.cv$se.
                colors <- colors[-color_index]
            }
            lines(
                private$.step_1$range$partition,
                rowMeans(private$.cv$se, na.rm = TRUE),
                lwd = 3,
                col = "black"
            )
            points(
                private$.step_1$range$partition,
                rowMeans(private$.cv$se, na.rm = TRUE),
                lwd = 3,
                col = "black",
                pch = 15
            )
        }
    ),

    active = list(
        step_1 = function() { return(private$.step_1) },
        spline = function() { return(private$.spline) },
        interpolation = function() { return(private$.interpolation) },
        cv = function() { return(private$.cv) },
        ssq = function() {
            return(sum((private$.spline$solver$y - private$.spline$fitted) ^ 2))
        }
    )
)
