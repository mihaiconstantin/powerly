# Tests for responsible user feedback.

test_that("Method prints a message when the selected target values are arguably low", {
    # Select a low measure value.
    measure_value <- .6

    # Select a low statistic value.
    statistic_value <- .7

    # Prepare storage for the result.
    results <- NULL

    # Constructor the message for lower targets.
    message <- paste0(
        "\n",
        "The performance measure target `measure_value = ", measure_value, "` may be too low for meaningful results.",
        "\n",
        "The statistic target `statistic_value = ", statistic_value, "` may be too low for reliable results."
    )

    # Run the method with a low targets.
    expect_message(
        capture.output(
            results <- powerly(
                range_lower = 100,
                range_upper = 500,
                samples = 5,
                replications = 1,
                measure = "sen",
                statistic = "power",
                measure_value = measure_value,
                statistic_value = statistic_value,
                model = "ggm",
                nodes = 5,
                density = .4,
                iterations = 1,
                cores = NULL,
                verbose = TRUE
            )
        ),
        message
    )

    # Expect the message also when summarizing.
    expect_message(capture.output(summary(results)), message)

    # Increase the measure value to acceptable levels.
    measure_value <- .8

    # Construct the message for low static target.
    message <- paste0(
        "The statistic target `statistic_value = ", statistic_value, "` may be too low for reliable results."
    )

    # Run the method with a low measure value.
    expect_message(
        capture.output(
            results <- powerly(
                range_lower = 100,
                range_upper = 500,
                samples = 5,
                replications = 1,
                measure = "sen",
                statistic = "power",
                measure_value = measure_value,
                statistic_value = statistic_value,
                model = "ggm",
                nodes = 5,
                density = .4,
                iterations = 1,
                cores = NULL,
                verbose = TRUE
            )
        ),
        message
    )

    # Expect the message also when summarizing.
    expect_message(capture.output(summary(results)), message)

    # Decrease the measure value.
    measure_value <- .7

    # Increase the statistic value to acceptable levels.
    statistic_value <- .8

    # Construct the message for low measure target.
    message <- paste0(
        "The performance measure target `measure_value = ", measure_value, "` may be too low for meaningful results."
    )

    # Run the method with a low measure target.
    expect_message(
        capture.output(
            results <- powerly(
                range_lower = 100,
                range_upper = 500,
                samples = 5,
                replications = 1,
                measure = "sen",
                statistic = "power",
                measure_value = measure_value,
                statistic_value = statistic_value,
                model = "ggm",
                nodes = 5,
                density = .4,
                iterations = 1,
                cores = NULL,
                verbose = TRUE
            )
        ),
        message
    )

    # Expect the message also when summarizing.
    expect_message(capture.output(summary(results)), message)
})


test_that("Validation prints a message when the targets are not reached", {
    # Run the method with really low targets.
    results <- powerly(
        range_lower = 100,
        range_upper = 500,
        samples = 5,
        replications = 1,
        measure = "sen",
        statistic = "power",
        measure_value = .1,
        statistic_value = .1,
        model = "ggm",
        nodes = 5,
        density = .4,
        iterations = 1,
        cores = NULL,
        verbose = FALSE
    )

    # Set impossible measure target for the validation.
    results$step_1$set_measure("sen", 2)

    # Extract the lower end of the recommendation.
    sample <- results$recommendation["0%"]

    # Store the results.
    validation_results <- NULL

    # Perform the validation and expect a message.
    expect_message(
        capture.output(
            validation_results <- validate(
                method = results,
                sample = sample,
                replications = 1,
                cores = NULL,
                verbose = TRUE
            )
        )
    )

    # Expect the message also when summarizing.
    expect_message(capture.output(summary(validation_results)))
})
