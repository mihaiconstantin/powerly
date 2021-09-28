# Test 'StepThree' class.

test_that("'StepThree' selects correctly a sufficient sample size", {
    # Create instance of the test helper.
    step_3 <- StepThreeTester$new()

    # Statistic value.
    statistic_value <- 0.5

    # Test mock spline with increasing trend that crosses the statistic value.
    spline <- seq(0, 1, 0.001)
    expect_equal(which(spline >= statistic_value)[1], step_3$selection_rule(spline, statistic_value, monotone = TRUE, increasing = TRUE))

    # Test mock spline with increasing trend that is below the statistic value.
    spline <- seq(0, .4, 0.001)
    expect_equal(length(spline), step_3$selection_rule(spline, statistic_value, monotone = TRUE, increasing = TRUE))

    # Test mock spline with increasing trend that is above the statistic value.
    spline <- seq(.6, 1, 0.001)
    expect_equal(1, step_3$selection_rule(spline, statistic_value, monotone = TRUE, increasing = TRUE))

    # Test mock spline with decreasing trend that crosses the statistic value.
    spline <- seq(1, 0, -0.001)
    expect_equal(which(spline <= statistic_value)[1], step_3$selection_rule(spline, statistic_value, monotone = TRUE, increasing = FALSE))

    # Test mock spline with decreasing trend that is below the statistic value.
    spline <- seq(.4, 0, -0.001)
    expect_equal(1, step_3$selection_rule(spline, statistic_value, monotone = TRUE, increasing = FALSE))

    # Test mock spline with decreasing trend that is above the statistic value.
    spline <- seq(1, .6, -0.001)
    expect_equal(length(spline), step_3$selection_rule(spline, statistic_value, monotone = TRUE, increasing = FALSE))

    # Test spline without a trend that crosses the statistic value at multiple points.
    spline <- c(0, 0.3, 0.6, 0.8, 0.4, 0.3, 0.3, 0.6, 0.8, 1)
    expect_equal(3, step_3$selection_rule(spline, 0.5, monotone = FALSE, increasing = NULL))
    expect_equal(length(spline), step_3$selection_rule(spline, 1.1, monotone = FALSE, increasing = NULL))
    expect_equal(1, step_3$selection_rule(spline, -0.1, monotone = FALSE, increasing = NULL))
})


test_that("'StepThree' performs a bootstrap run correctly", {
    # Create range.
    range <- Range$new(100, 1000, 10)

    # Create Step One.
    step_1 <- StepOne$new()

    # Configure Step One.
    step_1$set_range(range)
    step_1$set_model("ggm")
    step_1$set_true_model_parameters(nodes = 10, density = .4)
    step_1$set_measure("sen", .6)
    step_1$set_statistic("power", .8)

    # Compute Step One.
    step_1$simulate(10)
    step_1$compute()

    # Create Step Two.
    step_2 <- StepTwo$new(step_1)

    # Compute Step Two.
    step_2$fit(monotone = TRUE, increasing = TRUE)

    # Create Step Three tester.
    step_3 <- StepThreeTester$new()

    # Get a seed value.
    seed <- sample(1:1e5, 1)

    # Set seed.
    set.seed(seed)

    # Perform single bootstrap run via the implementation.
    boot_spline_impl <- step_3$boot(
        range$available_samples,
        step_1$measures,
        step_1$measure_value,
        step_1$replications,
        step_2$interpolation$basis_matrix,
        step_1$statistic$compute,
        step_2$spline$solver
    )

    # Set seed.
    set.seed(seed)

    # Perform a single bootstrap run manually.
    # First bootstrap new statistics.
    boot_statistics <- apply(step_1$measures, 2, function(runs) {
        return(
            step_1$statistic$compute(sample(runs, size = step_1$replications, replace = TRUE), step_1$measure_value)
        )
    })

    # Then fit and interpolate.
    boot_spline <- step_2$interpolation$basis_matrix %*% step_2$spline$solver$solve_update(boot_statistics)

    # Both bootstrapped splines should yield similar measures.
    expect_equal(boot_spline_impl, boot_spline)
})


test_that("'StepThree' performs the bootstrap procedure correctly", {
    # Create range.
    range <- Range$new(100, 1000, 10)

    # Create Step One.
    step_1 <- StepOne$new()

    # Configure Step One.
    step_1$set_range(range)
    step_1$set_model("ggm")
    step_1$set_true_model_parameters(nodes = 10, density = .4)
    step_1$set_measure("sen", .6)
    step_1$set_statistic("power", .8)

    # Compute Step One.
    step_1$simulate(10)
    step_1$compute()

    # Create Step Two.
    step_2 <- StepTwo$new(step_1)

    # Compute Step Two.
    step_2$fit(monotone = TRUE, increasing = TRUE)

    # Create Step Three tester.
    step_3 <- StepThree$new(step_2)

    # Run the bootstrap sequentially.
    step_3$bootstrap(1000)

    # Check the dimensions of the bootstrapped splines.
    expect_equal(dim(step_3$boot_statistics), c(1000, range$sequence_length))

    # Create backend for running the bootstrap in parallel.
    backend <- Backend$new()

    # Start the backend.
    backend$start(get_number_cores())

    # Run the bootstrap in parallel.
    step_3$bootstrap(1000, backend = backend)

    # Stop the backend.
    backend$stop()

    # Check the dimensions of the bootstrapped splines.
    expect_equal(dim(step_3$boot_statistics), c(1000, range$sequence_length))
})


test_that("'StepThree' extracts the sufficient samples correctly", {
    # Create range.
    range <- Range$new(100, 1000, 10)

    # Create Step One.
    step_1 <- StepOne$new()

    # Configure Step One.
    step_1$set_range(range)
    step_1$set_model("ggm")
    step_1$set_true_model_parameters(nodes = 10, density = .4)
    step_1$set_measure("sen", .6)
    step_1$set_statistic("power", .8)

    # Compute Step One.
    step_1$simulate(10)
    step_1$compute()

    # Create Step Two.
    step_2 <- StepTwo$new(step_1)

    # Compute Step Two.
    step_2$fit(monotone = TRUE, increasing = TRUE)

    # Create Step Three tester.
    step_3 <- StepThree$new(step_2)

    # Run the bootstrap sequentially.
    step_3$bootstrap(3000)

    # Compute the CI.
    step_3$compute()

    # Extract the selection rule.
    selection_rule <- step_3$.__enclos_env__$private$.selection_rule

    # Get all the sufficient samples manually.
    sufficient_samples <- apply(step_3$boot_statistics, 1, function(spline) {
        return(range$sequence[selection_rule(spline, statistic_value = step_1$statistic_value, monotone = TRUE, increasing = TRUE)])
    })

    # Compute the CI for the sufficient samples.
    sufficient_samples <- quantile(sufficient_samples, c(0, .025, .5, .975, 1), na.rm = TRUE)

    # The CI should match within a tolerance range.
    testthat::expect_lte(sum(abs(step_3$samples - sufficient_samples)), 1)
})


test_that("'StepThree' computes the confidence intervals correctly", {
    # Create range.
    range <- Range$new(100, 1000, 10)

    # Create Step One.
    step_1 <- StepOne$new()

    # Configure Step One.
    step_1$set_range(range)
    step_1$set_model("ggm")
    step_1$set_true_model_parameters(nodes = 10, density = .4)
    step_1$set_measure("sen", .6)
    step_1$set_statistic("power", .8)

    # Compute Step One.
    step_1$simulate(10)
    step_1$compute()

    # Create Step Two.
    step_2 <- StepTwo$new(step_1)

    # Compute Step Two.
    step_2$fit(monotone = TRUE, increasing = TRUE)

    # Create Step Three tester.
    step_3 <- StepThree$new(step_2)

    # Run the bootstrap sequentially.
    step_3$bootstrap(3000)

    # Compute confidence intervals sequentially.
    step_3$compute()
    spline_ci_sequential <- step_3$ci

    # Create backend for running the bootstrap in parallel.
    backend <- Backend$new()

    # Start the backend.
    backend$start(get_number_cores())

    # Compute confidence intervals in parallel.
    step_3$compute(backend = backend)
    spline_ci_parallel <- step_3$ci

    # Stop the backend.
    backend$stop()

    # The confidence intervals should match.
    expect_equal(spline_ci_sequential, spline_ci_parallel)
})
