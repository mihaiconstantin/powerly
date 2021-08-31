# Testing 'Statistic' class.

test_that("'Statistic' base class throws errors for abstract methods", {
    # Create `Statistic` base class.
    statistic <- Statistic$new()

    # Expect error because the methods are abstract.
    expect_error(statistic$compute(NULL), .__ERRORS__$not_implemented)
    expect_error(statistic$apply(NULL), .__ERRORS__$not_implemented)
})
