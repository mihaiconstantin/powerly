# Test exported facades.

test_that("facades run without errors when a backend is requested", {
    # Get the number of cores.
    cores <- get_number_cores()

    # Run the method.
    results <- powerly(
        range_lower = 100,
        range_upper = 500,
        samples = 5,
        replications = 10,
        measure = "sen",
        statistic = "power",
        measure_value = .6,
        statistic_value = .8,
        model = "ggm",
        nodes = 5,
        density = .4,
        iterations = 1,
        cores = cores,
        verbose = FALSE
    )

    # Expect the results to not be empty.
    expect_true(length(results$recommendation) > 0)

    # Expect the backend to not be active.
    expect_false(results$.__enclos_env__$private$.backend$active)

    # Perform the validation.
    validation_results <- validate(
        method = results,
        replications = 100,
        cores = cores,
        verbose = FALSE
    )

    # Expect the validation results to not be empty.
    expect_true(length(validation_results$percentile_value) > 0)

    # Expect the backend to not be active.
    expect_false(validation_results$.__enclos_env__$private$.backend$active)
})


test_that("'Validation' uses the correct sample", {
    # Run the method.
    results <- powerly(
        range_lower = 100,
        range_upper = 500,
        samples = 5,
        replications = 1,
        measure = "sen",
        statistic = "power",
        measure_value = .6,
        statistic_value = .8,
        model = "ggm",
        nodes = 5,
        density = .4,
        iterations = 1,
        cores = NULL,
        verbose = FALSE
    )

    # Perform the validation.
    validation_results <- validate(
        method = results,
        replications = 1,
        cores = NULL,
        verbose = FALSE
    )

    # Extract the recommendation.
    sample <- unname(results$recommendation["50%"])

    # Expect that the validation used the recommendation.
    expect_equal(validation_results$sample, sample)

    # Select a different sample randomly, never smaller.
    different_sample <- round(sample * runif(1, 1, 1.1))

    # Perform the validation.
    validation_results <- validate(
        method = results,
        sample = different_sample,
        replications = 1,
        cores = NULL,
        verbose = FALSE
    )

    # Expect that the validation used the different sample.
    expect_equal(validation_results$sample, different_sample)
})
