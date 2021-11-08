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


test_that("'Backend' performs operations on the cluster correctly", {
    # Create a backend.
    backend <- Backend$new()

    # Start the cluster.
    backend$start(2)

    # Expect the cluster is empty upon creation.
    expect_true(all(sapply(backend$inspect(), length) == 0))

    # Create a variable in a new environment.
    env <- new.env()
    env$test_variable <- rnorm(1)

    # Export variable to the cluster from an environment.
    backend$export("test_variable", env)

    # Expect the cluster to contain the exported variable.
    expect_true(all(backend$inspect() == "test_variable"))

    # Expect the cluster to hold the correct value for the exported variable.
    expect_true(all(parallel::clusterEvalQ(backend$cluster, test_variable) == env$test_variable))

    # Expect that clearing the cluster leaves it empty.
    backend$clear()
    expect_true(all(sapply(backend$inspect(), length) == 0))

    # Create test data for the cluster `sapply` and `apply operations`.
    data <- matrix(rnorm(100), 10, 10)
    test_function <- function(x, add = 1) x + add

    # Expect that the parallel `sapply` is executed correctly.
    expect_equal(backend$sapply(data[, 1], test_function, add = 3), sapply(data[, 1], test_function, add = 3))

    # Expect that the parallel `apply` is executed correctly.
    expect_equal(backend$apply(data, 1, test_function, add = 10), apply(data, 1, test_function, add = 10))

    # Expect that the cluster is empty after performing operations on it.
    # Note, it will contain a `.Random.seed` placed there by `snow` which is loaded via bootnet.
    # To check that that is indeed the case, remove `bootnet` imports from `NAMESPACE`.
    # Also see:
    #   - https://stackoverflow.com/q/69866215/5252007
    #   - https://github.com/SachaEpskamp/bootnet/issues/82
    expect_equal(sum(sapply(backend$inspect(), function(x) { length(x[!x %in% ".Random.seed"]) })), 0)

    # Stop the cluster.
    backend$stop()
})


test_that("'Backend' manages the cluster correctly", {
    # Create a backend.
    backend <- Backend$new()

    # Start the cluster.
    backend$start(2)

    # Expect the correct type.
    if (.Platform$OS.type == "unix") {
       expect_equal(backend$type, c(unix = "FORK"))
    } else {
       expect_equal(backend$type, c(windows = "PSOCK"))
    }

    # Expect the correct number of cores.
    expect_equal(backend$cores, 2)
    expect_equal(length(backend$cluster), 2)

    # Expect an error if an attempt is made to start a cluster while one is already active.
    expect_error(backend$start(2), "A cluster is already active. Please stop it before starting a new one.")

    # Expect stopping the cluster works.
    backend$stop()
    expect_false(backend$active)
    expect_equal(backend$cluster, NULL)

    # Expect the cluster can be started again after being stop.
    backend$start(2)
    expect_equal(length(backend$cluster), 2)

    # Expect an error if an attempt is made to adopt a cluster while one is already active.
    expect_error(backend$adopt(backend$cluster), "Cannot adopt external cluster while there is another active cluster.")

    # Stop the current cluster.
    backend$stop()

    # Create a cluster manually.
    cluster <- parallel::makePSOCKcluster(2)

    # Expect the backend correctly adopts a cluster object.
    backend$adopt(cluster)
    expect_equal(backend$type, "adopted")
    expect_equal(length(backend$cluster), 2)
    expect_equal(backend$cores, 2)
    expect_equal(backend$.__enclos_env__$private$.available_cores, NULL)
    expect_equal(backend$.__enclos_env__$private$.allowed_cores, NULL)

    # Expect that the backend can stop the adopted cluster.
    backend$stop()
    # If the backend `stop()` worked, then attempting to close again will throw an error.
    expect_error(parallel::stopCluster(cluster))
})
