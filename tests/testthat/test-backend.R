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


test_that("'Backend' sets the number of cores correctly", {
    # Create backend instance.
    backend <- BackendTester$new()

    # Suppose the machine has two cores.
    backend$mock_machine_available_cores(cores = 2)

    # Expectations based on the number of cores requested.

    # When 1 core is requested.
    expect_warning(backend$set_cores(cores = 1), "Argument `cores` must be greater than 1. Setting to 2.")
    expect_equal(backend$cores, 2)

    # When two cores are requested.
    backend$set_cores(cores = 2)
    expect_equal(backend$cores, 2)

    # When more than two cores are requested.
    expect_warning(backend$set_cores(cores = 7), "Argument `cores` cannot be larger than 2. Setting to 2.")
    expect_equal(backend$cores, 2)

    # Suppose the machine has 8 cores.
    backend$mock_machine_available_cores(cores = 8)

    # When 1 core is requested.
    expect_warning(backend$set_cores(cores = 1), "Argument `cores` must be greater than 1. Setting to 2.")
    expect_equal(backend$cores, 2)

    # When two cores are requested.
    backend$set_cores(cores = 2)
    expect_equal(backend$cores, 2)

    # When seven cores are requested.
    backend$set_cores(cores = 7)
    expect_equal(backend$cores, 7)

    # When seven cores are requested.
    expect_warning(backend$set_cores(cores = 8), "Argument `cores` cannot be larger than 7. Setting to 7.")
    expect_equal(backend$cores, 7)
})

