#' @include Model.R

# Implementation example for the McDonald's coefficient in SEM.
SemOmega <- R6::R6Class("SemOmega",
    inherit = Model,

    public = list(
        # Specify model.
        create = function() {
            # True model syntax.
            true_model_syntax <- "
                # Measurement model.
                eta1 =~ 1*Y1 + 0.25*Y2 + 0.75 *Y3
                eta2 =~ 1*Y4

                # Structural model.
                eta1 ~ 0.37*eta2

                # Latent disturbances.
                eta1 ~~ 0.51*eta1
                eta2 ~~ 0.71*eta2

                # Residuals.
                Y1 ~~ 0.33*Y1
                Y2 ~~ 0.93*Y2
                Y3 ~~ 0.43*Y3
                Y4 ~~ 0*Y4
            "

            # Get the true model object from syntax.
            theta_0 <- lavaan::sem(true_model_syntax, do.fit = FALSE)

            # Return the true model object.
            return(theta_0)
        },

        # Generate data.
        generate = function(n, specification) {
            # Extract the model parameters from the true model object.
            parameters <- lavaan::parameterTable(specification)

            # Generate dataset based on the true model parameters.
            dataset <- lavaan::simulateData(parameters, sample.nobs = n)

            # Return the dataset.
            return(dataset)
        },

        # Estimate model.
        estimate = function(generation) {
            # Indicate the model to estimate using syntax.
            model_syntax <- "
                # Measurement model.
                eta1 =~ 1*Y1 + Y2 + Y3
                eta2 =~ 1*Y4

                # Structural model.
                eta1 ~ eta2

                # Additional constraints.
                Y4 ~~ 0*Y4
            "

            # Estimate the model object from a dataset of size `n`.
            theta_n <- lavaan::sem(model_syntax, generation)

            # Return the estimated model object.
            return(theta_n)
        },

        # Evaluate performance measure.
        evaluate = function(specification, estimation, measure = "omega") {
            # Implement the research question via the estimand functional.
            estimand <- function(true_model_object) {
                # Extract relevant model matrices from the true model object.
                lambda <- lavaan::lavInspect(true_model_object, "est")$lambda
                psi <- lavaan::lavInspect(true_model_object, "est")$psi
                theta <- lavaan::lavInspect(true_model_object, "est")$theta

                # Choose an omega vector.
                omega <- rep(1, nrow(lambda))

                # Compute the coefficient.
                coefficient <- (t(omega) %*% lambda %*% psi %*% t(lambda) %*% omega) /
                    (t(omega) %*% (lambda %*% psi %*% t(lambda) + theta) %*% omega)

                # Return the coefficient.
                return(coefficient)
            }

            # Calibrate the discrepancy metric delta to the research question.
            delta <- function(psi_true, psi_estimate) {
                # Calculate the discrepancy on the research question scale.
                discrepancy <- abs(psi_true - psi_estimate)

                # Return the discrepancy.
                return(discrepancy)
            }

            # Calculate the performance measure.
            # Note the inversion since the setup programmed is for higher is better.
            performance_measure <- 1 - delta(estimand(specification), estimand(estimation))

            # Return the outcome.
            return(performance_measure)
        }
    )
)
