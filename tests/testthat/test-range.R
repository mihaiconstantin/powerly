# Test 'Range' class.

test_that("'Range' creates partition of correct number of elements", {
    # Range should have the number of requested sample sizes.
    range <- Range$new(lower = 1, upper = 10, samples = 10, tolerance = -1)
    expect_equal(range$available_samples, 10)

    # Range should have maximum sample sizes possible if too many are requested.
    range <- Range$new(lower = 1, upper = 10, samples = 20, tolerance = -1)
    expect_equal(range$available_samples, 10)

    # Range should have one sample size if one is requested.
    # And the sample size should be the lower bound of the range.
    range <- Range$new(lower = 1, upper = 10, samples = 1, tolerance = -1)
    expect_equal(range$available_samples, 1)
    expect_equal(range$partition, 1)

    # Range should have one element when the bounds are equal.
    range <- Range$new(lower = 1, upper = 1, samples = 1, tolerance = -1)
    expect_equal(range$available_samples, 1)

    # Range should throw an error if the bounds are ill-specified.
    expect_error(
        Range$new(lower = 10, upper = 1, samples = 1, tolerance = -1),
        "Please provide a range wider than the tolerance."
    )
})


# Range updates correctly.
test_that("'Range' updates bounds correctly based on 'StepThree' confidence intervals", {
    # Create range.
    range <- Range$new(100, 1500, 10)

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

    # Compute confidence intervals sequentially.
    step_3$compute(lower_ci = 0.025, upper_ci = 0.975)

    # Update range.
    range$update_bounds(step_3, lower_ci = 0.025, upper_ci = 0.975)

    # Expect the range bounds were updated correctly.
    expect_equal(range$lower, step_3$samples["2.5%"])
    expect_equal(range$upper, step_3$samples["97.5%"])

    # Expect that partition was recreated accordingly.
    expect_equal(min(range$partition), as.numeric(step_3$samples["2.5%"]))
    expect_equal(max(range$partition), as.numeric(step_3$samples["97.5%"]))

    # Expect that the bounds are of increasing size.
    expect_error(
        range$update_bounds(step_3, lower_ci = 0.975, upper_ci = 0.025),
        "The lower bound cannot be greater that the upper bound."
    )
})


test_that("'Range' convergence test works correctly", {
    # Expect error if the initial range is smaller than the tolerance.
    expect_error(Range$new(100, 130, samples = 10, tolerance = 50), "Please provide a range wider than the tolerance.")

    # Create `Range` instance.
    range <- RangeTester$new(100, 500, samples = 20, tolerance = 50)

    # Expect the convergence test triggers correctly.
    expect_equal(range$convergence_test(100, 160), FALSE)
    expect_equal(range$convergence_test(100, 150), TRUE)
    expect_equal(range$convergence_test(100, 140), TRUE)

    # Expect the convergence test triggers correctly even in absurd cases.
    expect_equal(range$convergence_test(160, 100), TRUE)
    expect_equal(range$convergence_test(150, 100), TRUE)
    expect_equal(range$convergence_test(140, 100), TRUE)
})
