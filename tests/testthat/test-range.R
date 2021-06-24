# Test 'Range' class.

test_that("'Range' creates partition of correct number of elements", {
    # Range should have the number of requested sample sizes.
    range <- Range$new(lower = 1, upper = 10, samples = 10)
    expect_equal(range$available_samples, 10)

    # Range should have maximum sample sizes possible if too many are requested.
    range <- Range$new(lower = 1, upper = 10, samples = 20)
    expect_equal(range$available_samples, 10)

    # Range should have one sample size if one is requested.
    # And the sample size should be the lower bound of the range.
    range <- Range$new(lower = 1, upper = 10, samples = 1)
    expect_equal(range$available_samples, 1)
    expect_equal(range$partition, 1)

    # Range should have one element when the bounds are equal.
    range <- Range$new(lower = 1, upper = 1, samples = 1)
    expect_equal(range$available_samples, 1)

    # Range should throw an error if the bounds are ill-specified.
    expect_error(
        Range$new(lower = 10, upper = 1, samples = 1),
        "The lower bound cannot be greater that the upper bound."
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
    step_3$compute()

    # Update range.
    range$update(step_3, lower = "2.5%", upper = "97.5%")

    # Expect the range bounds were updated correctly.
    expect_equal(range$lower, step_3$sufficient_samples["2.5%"])
    expect_equal(range$upper, step_3$sufficient_samples["97.5%"])

    # Expect that partition was recreated accordingly.
    expect_equal(min(range$partition), as.numeric(step_3$sufficient_samples["2.5%"]))
    expect_equal(max(range$partition), as.numeric(step_3$sufficient_samples["97.5%"]))
})
