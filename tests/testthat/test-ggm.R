# Test 'GgmModel' class.

test_that("'GgmModel' generates data correctly", {
    # Sample size.
    sample_size <- sample(500:2000, 1)

    # Levels.
    max_level <- sample(3:5, 1)

    # Nodes.
    nodes <- sample(10:20, 1)

    # Density.
    density <- sample(seq(.2, .5, .1), 1)

    # Create plain GGM model object.
    ggm <- GgmModel$new()

    # Create true model parameters.
    true <- ggm$create(nodes = nodes, density = density)

    # Generate data.
    data <- ggm$generate(sample_size = sample_size, true_parameters = true, levels = max_level)

    # The data dimensions should match the number of nodes and the sample size.
    expect_equal(ncol(data), ncol(true))
    expect_equal(nrow(data), sample_size)

    # The range of the data should match the Likert scale levels.
    expect_equal(min(data), 1)
    expect_equal(max(data), max_level)

    # Sample sizes smaller than 50 are not permitted.
    expect_error(
        ggm$generate(sample_size = 49, true_parameters = true, levels = max_level),
        "Sample size must be greater than 50."
    )
})


test_that("'GgmModel' generated data matches bootnet data", {
    # Sample size.
    sample_size <- sample(500:2000, 1)

    # Levels.
    max_level <- sample(3:5, 1)

    # Nodes.
    nodes <- sample(10:20, 1)

    # Density.
    density <- sample(seq(.2, .5, .1), 1)

    # Create plain GGM model object.
    ggm <- GgmModel$new()

    # Create true model parameters.
    true <- ggm$create(nodes = nodes, density = density)

    # Create seed for the comparison with bootnet.
    seed <- sample(1:1e5, 1)

    # Generate data via 'GgmModel'.
    set.seed(seed)
    ggm_model_data <- ggm$generate(sample_size = sample_size, true_parameters = true, levels = max_level)

    # Generate data via 'bootnet'.
    set.seed(seed)
    bootnet_data <- bootnet::ggmGenerator(ordinal = TRUE, nLevels = max_level, type = "random", missing = 0)(n = sample_size, input = true)

    # The data should be the same as 'bootnet' generated data.
    expect_equal(ggm_model_data, bootnet_data)
})


test_that("'GgmModel' estimates model parameters correctly", {
    # Sample size.
    sample_size <- sample(500:2000, 1)

    # Levels.
    max_level <- sample(3:5, 1)

    # Nodes.
    nodes <- sample(10:20, 1)

    # Density.
    density <- sample(seq(.2, .5, .1), 1)

    # Create plain GGM model object.
    ggm <- GgmModel$new()

    # Create true parameters.
    true <- ggm$create(nodes, density)

    # Generate data.
    data <- ggm$generate(sample_size = sample_size, true_parameters = true, levels = max_level)

    # Estimate via 'qgraph'.
    network_qgraph <- suppressMessages(suppressWarnings(qgraph::EBICglasso(cov(data), nrow(data), verbose = FALSE)))

    # Estimate via 'GgmModel'.
    network_ggm_model <- ggm$estimate(data)

    # The parameters should be identical across both methods.
    expect_equal(network_qgraph, network_ggm_model, ignore_attr = TRUE)

    # Make one variable invariant.
    data[, 1] <- data[1, 1]

    # Expect the estimation to throw an error due to invariant variables.
    expect_error(ggm$estimate(data))
})


test_that("'GgmModel' computes the correct measure", {
    # Sample size.
    sample_size <- sample(500:2000, 1)

    # Levels.
    max_level <- sample(3:5, 1)

    # Nodes.
    nodes <- sample(10:20, 1)

    # Density.
    density <- sample(seq(.2, .5, .1), 1)

    # Create plain GGM model object.
    ggm <- GgmModel$new()

    # Create true parameters.
    true <- ggm$create(nodes, density)

    # Generate data.
    data <- ggm$generate(sample_size = sample_size, true_parameters = true, levels = max_level)

    # Estimate parameters.
    estimated <- ggm$estimate(data)

    # The right measures are picked if 'sen' returns 0, and 'spe' returns 1.
    expect_equal(ggm$evaluate(true, estimated, measure = "sen"), compute_measure(true, estimated, "sen"))
    expect_equal(ggm$evaluate(true, estimated, measure = "spe"), compute_measure(true, estimated, "spe"))

    # For unknown measures and error should be thrown.
    expect_error(ggm$evaluate(true, estimated, measure = "unknown"), .__ERRORS__$not_developed)
})


test_that("'GgmModel' does not evaluate models of different dimensions", {
    # Create plain GGM model object.
    ggm <- GgmModel$new()

    # Create true parameters.
    true <- ggm$create(10, .3)

    # Generate data.
    data <- ggm$generate(sample_size = 500, true_parameters = true, levels = 5)

    # Estimate parameters.
    estimated <- ggm$estimate(data)

    # Drop one variable from the estimated parameters.
    estimated <- estimated[, -1]

    # The evaluation should return NA because the model dimensions do not match.
    expect_equal(ggm$evaluate(true, estimated, measure = "sen"), NA)
    expect_equal(ggm$evaluate(true, estimated, measure = "spe"), NA)
    expect_equal(ggm$evaluate(true, estimated, measure = "mcc"), NA)
    expect_equal(ggm$evaluate(true, estimated, measure = "rho"), NA)
})
