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
