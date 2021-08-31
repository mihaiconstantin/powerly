# Test 'Backend' class.

test_that("'Backend' aborts on machines with only one core", {
    # Create backend instance.
    backend <- BackendTester$new()

    # Suppose the machine has only one core.
    backend$mock_machine_available_cores(cores = 1)

    # The expected error message.
    error_message <- "Not enough cores available on the machine."

    # Expect to abort regardless of the requested cores.
    expect_error(backend$set_cores(cores = 1), error_message)
    expect_error(backend$set_cores(cores = 2), error_message)
    expect_error(backend$set_cores(cores = 7), error_message)
})

