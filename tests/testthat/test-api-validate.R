# Test 'validate()' public API.

test_that("'validate()' fails on incorrect method object type", {
    # Expect validate to fail on incorrect method object.
    expect_error(validate(method = 1), .__ERRORS__$incorrect_type)
    expect_error(validate(method = "method"), .__ERRORS__$incorrect_type)
    expect_error(validate(method = StepOne$new()), .__ERRORS__$incorrect_type)
})
