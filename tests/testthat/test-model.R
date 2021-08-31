# Testing 'Model' class.

test_that("'Model' base class throws errors for abstract methods", {
    # Create `Model` base class.
    model <- Model$new()

    # Expect error because the methods are abstract.
    expect_error(model$create(), .__ERRORS__$not_implemented)
    expect_error(model$generate(NULL, NULL), .__ERRORS__$not_implemented)
    expect_error(model$estimate(NULL), .__ERRORS__$not_implemented)
    expect_error(model$evaluate(NULL, NULL, NULL), .__ERRORS__$not_implemented)
})
