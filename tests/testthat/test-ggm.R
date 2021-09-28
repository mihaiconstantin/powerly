# Test 'GgmModel' class.

test_that("'GgmModel' generates data correctly", {
    # Create plain GGM model object.
    ggm <- GgmModel$new()

    # Create true model parameters.
    true <- ggm$create(nodes = 15, density = .5)

    # Generate data.
    data <- ggm$generate(sample_size = 999, true_parameters = true, levels = 4)

    # The data dimensions should match the number of nodes and the sample size.
    expect_equal(ncol(data), ncol(true))
    expect_equal(nrow(data), 999)

    # The range of the data should match the Likert scale levels.
    expect_equal(min(data), 1)
    expect_equal(max(data), 4)
})


test_that("'GgmModel' generated data matches bootnet data", {
    # Create plain GGM model object.
    ggm <- GgmModel$new()

    # Create true model parameters.
    true <- ggm$create(nodes = 10, density = .5)

    # Create seed for the comparison with bootnet.
    seed <- sample(1:1e5, 1)

    # Generate data via 'GgmModel'.
    set.seed(seed)
    ggm_model_data <- ggm$generate(sample_size = 300, true_parameters = true, levels = 5)

    # Generate data via 'bootnet'.
    set.seed(seed)
    bootnet_data <- bootnet::ggmGenerator(ordinal = TRUE, nLevels = 5, type = "random", missing = 0)(n = 300, input = true)

    # The data should be the same as 'bootnet' generated data.
    expect_equal(ggm_model_data, bootnet_data)
})


test_that("'GgmModel' estimates model parameters correctly", {
    # Create plain GGM model object.
    ggm <- GgmModel$new()

    # Create true parameters.
    true <- ggm$create(10, .5)

    # Generate data.
    data <- ggm$generate(sample_size = 2000, true_parameters = true, levels = 5)

    # Estimate via 'qgraph'.
    network_qgraph <- suppressMessages(suppressWarnings(qgraph::EBICglasso(cov(data), nrow(data), verbose = FALSE)))

    # Estimate via 'GgmModel'.
    network_ggm_model <- ggm$estimate(data)

    # The parameters should be identical across both methods.
    expect_equal(round(network_qgraph, 7), round(network_ggm_model, 7), ignore_attr = TRUE)
})


test_that("'GgmModel' computes the correct measure", {
    # Create plain GGM model object.
    ggm <- GgmModel$new()

    # Create true parameters.
    true <- ggm$create(10, .4)

    # Generate data.
    data <- ggm$generate(sample_size = 10, true_parameters = true, levels = 5)

    # Estimate parameters.
    estimated <- ggm$estimate(data)

    # The right measures are picked if 'sen' returns 0, and 'spe' returns 1.
    expect_equal(ggm$evaluate(true, estimated, measure = "sen"), 0)
    expect_equal(ggm$evaluate(true, estimated, measure = "spe"), 1)

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
