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
