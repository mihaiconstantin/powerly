# Test 'StepOne' class.

test_that("'StepOne' Monte Carlo simulation runs correctly", {
    # Create true model parameters that will be reused.
    ggm <- GgmModel$new()
    true_model_parameters <- ggm$create(nodes = 10, density = .5)

    # Create power statistic.
    power_statistic <- PowerStatistic$new()

    # Create range of sample sizes.
    range <- Range$new(100, 1500, 10, 50)

    # Create Step One.
    step_1 <- StepOne$new()

    # Configure Step One.
    step_1$set_range(range)
    step_1$set_model("ggm")
    step_1$set_true_model_parameters(matrix = true_model_parameters)
    step_1$set_measure("sen", .6)
    step_1$set_statistic("power", .8)

    # Determine seed.
    seed <- runif(1)

    # Set seed.
    set.seed(seed)

    # Perform Monte Carlo via 'StepOne' class instance.
    step_1$simulate(10, backend = NULL)

    # Compute statistic via 'StepOne' class instance.
    step_1$compute()

    # Set seed.
    set.seed(seed)

    # Perform Monte Carlo for each sample size manually.
    measures <- sapply(range$partition, function(sample) {
        # Perform replications for each sample size.
        sapply(1:10, function(r) {
            # Generate data.
            data <- ggm$generate(sample, true_model_parameters)

            # Estimate model.
            estimated_model_parameters <- ggm$estimate(data)

            # Compute measure.
            measure <- ggm$evaluate(true_model_parameters, estimated_model_parameters, "sen")
        })
    })

    # Compute statistic.
    statistics <- power_statistic$apply(measures, target = .6)

    # Measures computed via both methods should be equal.
    expect_equal(step_1$measures, measures)

    # Statistics computed via both methods should be equal.
    expect_equal(step_1$statistics, statistics)
})
