# Test 'IsingModel' class.

test_that("'IsingModel' generates data correctly", {
    # Sample size.
    sample_size <- sample(500:2000, 1)

    # Nodes.
    nodes <- sample(10:20, 1)

    # Density.
    density <- sample(seq(.2, .5, .1), 1)

    # Create plain Ising model object.
    ising <- IsingModel$new()

    # Create true model parameters.
    true <- ising$create(nodes = nodes, density = density)

    # Generate data.
    data <- ising$generate(sample_size = sample_size, true_parameters = true)

    # The data dimensions should match the number of nodes and the sample size.
    expect_equal(ncol(data), ncol(true))
    expect_equal(nrow(data), sample_size)

    # The range of the data should match the expected range.
    expect_equal(min(data), 0)
    expect_equal(max(data), 1)

    # Sample sizes smaller than 50 are not permitted.
    expect_error(
        ising$generate(sample_size = 49, true_parameters = true),
        "Sample size must be greater than 100."
    )
})


test_that("'IsingModel' generated data matches 'IsingSampler' data", {
    # Sample size.
    sample_size <- sample(500:2000, 1)

    # Nodes.
    nodes <- sample(10:20, 1)

    # Density.
    density <- sample(seq(.2, .5, .1), 1)

    # Create plain Ising model object.
    ising <- IsingModel$new()

    # Create true model parameters.
    true <- ising$create(nodes = nodes, density = density)

    # Create seed for the comparison with bootnet.
    seed <- sample(1:1e5, 1)

    # Generate data via 'IsingModel'.
    set.seed(seed)
    ising_model_data <- ising$generate(sample_size = sample_size, true_parameters = true)

    # Extract thresholds from the parameters matrix.
    thresholds <- diag(true)

    # Set diagonal to zero for the requirements of the 'IsingSampler'.
    diag(true) <- 0

    # Generate data via 'IsingSampler'.
    set.seed(seed)
    ising_sampler_data <- IsingSampler::IsingSampler(n = sample_size, graph = true, thresholds = thresholds, method = "MH")

    # The data should be the same as 'IsingSampler' generated data.
    expect_equal(ising_model_data, ising_sampler_data)
})


test_that("'IsingModel' estimates model parameters correctly", {
    # Sample size.
    sample_size <- sample(500:2000, 1)

    # Nodes.
    nodes <- sample(10:20, 1)

    # Density.
    density <- sample(seq(.2, .5, .1), 1)

    # Create plain Ising model object.
    ising <- IsingModel$new()

    # Create true parameters.
    true <- ising$create(nodes, density)

    # Generate data.
    data <- ising$generate(sample_size = sample_size, true_parameters = true)

    # Estimate via 'IsingFit'.
    network_ising_fit <- IsingFit::IsingFit(data, plot = FALSE, progressbar = FALSE)

    # Estimate via 'IsingModel'.
    network_ising_model <- ising$estimate(data)

    # Extract thresholds from model parameters matrix.
    thresholds <- diag(network_ising_model)

    # Set diagonal of weights matrix to zero.
    diag(network_ising_model) <- 0

    # The weights should be identical across both methods.
    expect_equal(network_ising_fit$weiadj, network_ising_model, ignore_attr = TRUE)

    # The thresholds should be identical across both methods.
    expect_equal(network_ising_fit$thresholds, thresholds, ignore_attr = TRUE)

    # Make one variable invariant.
    data[, 1] <- data[1, 1]

    # Expect the estimation to throw an error due to invariant variables.
    expect_error(ising$estimate(data))
})


test_that("'IsingModel' computes the correct measure", {
    # Sample size.
    sample_size <- sample(500:2000, 1)

    # Nodes.
    nodes <- sample(10:20, 1)

    # Density.
    density <- sample(seq(.2, .5, .1), 1)

    # Create plain Ising model object.
    ising <- IsingModel$new()

    # Create true parameters.
    true <- ising$create(nodes, density)

    # Generate data.
    data <- ising$generate(sample_size = sample_size, true_parameters = true)

    # Estimate parameters.
    estimated <- ising$estimate(data)

    # Expect the computed measures to have the correct value.
    expect_equal(ising$evaluate(true, estimated, measure = "sen"), compute_measure(true, estimated, "sen"))
    expect_equal(ising$evaluate(true, estimated, measure = "spe"), compute_measure(true, estimated, "spe"))

    # For unknown measures and error should be thrown.
    expect_error(ising$evaluate(true, estimated, measure = "unknown"), .__ERRORS__$not_developed)
})


test_that("'IsingModel' does not evaluate models of different dimensions", {
    # Create plain Ising model object.
    ising <- IsingModel$new()

    # Create true parameters.
    true <- ising$create(10, .3)

    # Generate data.
    data <- ising$generate(sample_size = 500, true_parameters = true)

    # Estimate parameters.
    estimated <- ising$estimate(data)

    # Drop one variable from the estimated parameters.
    estimated <- estimated[, -1]

    # The evaluation should return NA because the model dimensions do not match.
    expect_equal(ising$evaluate(true, estimated, measure = "sen"), NA)
    expect_equal(ising$evaluate(true, estimated, measure = "spe"), NA)
    expect_equal(ising$evaluate(true, estimated, measure = "mcc"), NA)
    expect_equal(ising$evaluate(true, estimated, measure = "rho"), NA)
})
