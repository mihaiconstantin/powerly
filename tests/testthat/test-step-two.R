# Test 'StepTwo' class.

test_that("'StepTwo' correctly computes the number of DF for LOOCV", {
    # Create reusable 'StepOne' instance.
    step_1 <- StepOne$new()

    # Set range.
    step_1$set_range(Range$new(100, 200, 10))

    # The minimum DF should start at 3 for monotone splines.
    expect_equal(min(StepTwoTester$new(step_1)$check_df(df = NULL, monotone = TRUE)), 3)

    # The minimum DF should start at 4 for non-monotone splines.
    expect_equal(min(StepTwoTester$new(step_1)$check_df(df = NULL, monotone = FALSE)), 4)

    # The maximum DF should not exceed the number of available samples take two.
    expect_equal(max(StepTwoTester$new(step_1)$check_df(df = NULL, monotone = FALSE)), step_1$range$available_samples - 2)

    # The maximum DF should not exceed 20 even for large number of available samples (e.g., 100).
    step_1$set_range(Range$new(100, 200, 100))
    expect_equal(max(StepTwoTester$new(step_1)$check_df(df = NULL, monotone = FALSE)), 20)

    # Should throw an error if the maximum provided DF is too large.
    step_1$set_range(Range$new(100, 200, 10))
    expect_error(StepTwoTester$new(step_1)$check_df(df = c(1, 10), monotone = FALSE))

    # Should throw and error if the minimum DF is too small.
    expect_error(StepTwoTester$new(step_1)$check_df(df = c(2, 7), monotone = TRUE))
    expect_error(StepTwoTester$new(step_1)$check_df(df = c(3, 7), monotone = FALSE))
})


test_that("'StepTwo' correctly performs the LOOCV procedure", {
    # Create range.
    range <- Range$new(100, 1000, 10)

    # Create 'StepOne' instance.
    step_1 <- StepOne$new()

    # Configure 'StepOne' instance.
    step_1$set_range(range)
    step_1$set_model("ggm")
    step_1$set_true_model_parameters(nodes = 10, density = .4)
    step_1$set_measure("sen", .6)
    step_1$set_statistic("power", .8)

    # Simulate 'StepOne' measures.
    step_1$simulate(10)

    # Compute 'StepOne' statistics.
    step_1$compute()

    # Create 'StepTwo' mock instance.
    step_2 <- StepTwoTester$new(step_1)

    # Flip a coin to decide which solver to use.
    solver_type <- ifelse(rbinom(1, 1, .5), "quadprog", "osqp")

    # Perform LOOCV via the mock instance.
    step_2$run_cv(monotone = TRUE, increasing = TRUE, df = NULL, solver_type = solver_type)

    # The dimensions if the LOOCV result should match the number of sample sizes and DF tested.
    expect_equal(nrow(step_2$cv$se), range$available_samples)
    expect_equal(ncol(step_2$cv$se), length(3:(range$available_samples - 2)))

    # The LOOCV result should contain no NA's.
    expect_equal(anyNA(step_2$cv$se), FALSE)
})


test_that("'StepTwo' fits and interpolates a spline correctly", {
    # Create range.
    range <- Range$new(100, 1500, 10)

    # Create 'StepOne' instance.
    step_1 <- StepOne$new()

    # Configure 'StepOne' instance.
    step_1$set_range(range)
    step_1$set_model("ggm")
    step_1$set_true_model_parameters(nodes = 10, density = .4)
    step_1$set_measure("sen", .6)
    step_1$set_statistic("power", .8)

    # Simulate 'StepOne' measures.
    step_1$simulate(10)

    # Compute 'StepOne' statistics.
    step_1$compute()

    # Fit a spline via step two.
    step_2 <- StepTwo$new(step_1)

    # Flip a coin to decide which solver to use.
    solver_type <- ifelse(rbinom(1, 1, .5), "quadprog", "osqp")

    # Fit the spline.
    step_2$fit(monotone = TRUE, increasing = TRUE, df = NULL, solver_type = solver_type)

    # Extract the DF selected.
    df <- step_2$cv$df[which.min(step_2$cv$mse)]

    # Fit a spline manually.
    basis <- splines2::iSpline(range$partition, df = df, degree = 3 - 1, intercept = TRUE)
    knots <- attributes(basis)$knots
    basis <- cbind(1, basis)

    # Create box constraints for 'osqp'.
    lower <- c(-Inf, rep(0, ncol(basis) - 1))
    upper <- rep(Inf, ncol(basis))

    # Estimate alpha.
    alpha <- solve_osqp(basis, step_1$statistics, lower, upper)

    # Predict.
    fitted <- basis %*% alpha

    # Create basis for interpolation, using the knots determined above given the DF provided.
    basis_extended <- splines2::iSpline(range$sequence, knots = knots, degree = 3 - 1, intercept = TRUE)
    basis_extended <- cbind(1, basis_extended)

    # Interpolate.
    interpolation <- basis_extended %*% alpha

    # The spline bases should be equal.
    expect_equal(step_2$spline$basis$matrix, basis)

    # The estimated spline coefficients should be equal.
    expect_equal(step_2$spline$alpha, alpha)

    # The fitted values should be equal.
    expect_equal(step_2$spline$fitted, fitted)

    # The extended spline bases should be equal.
    expect_equal(step_2$interpolation$basis_matrix, basis_extended)

    # The interpolated values should be equal.
    expect_equal(step_2$interpolation$fitted, interpolation)
})
