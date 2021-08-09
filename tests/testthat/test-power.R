# Test 'PowerStatistic' class.

test_that("'PowerStatistic' computes power correctly for a vector", {
    # Create plain power statistic object.
    statistic <- PowerStatistic$new()

    # Create data for the computation.
    measures <- c(rep(0, 20), rep(0.5, 80))

    # Statistic should yield a power of .8 in this scenario.
    expect_equal(statistic$compute(measures, target = 0.5), 0.8)
})


test_that("'PowerStatistic' computes power correctly for a matrix", {
    # Create plain power statistic object.
    statistic <- PowerStatistic$new()

    # Create vector data.
    measures <- c(rep(0, 20), rep(0.5, 80))

    # Create matrix for the computation.
    measures_matrix <- matrix(measures, nrow = 100, ncol = 10)

    # Statistic should yield a power of .8 in this scenario.
    expect_equal(statistic$apply(measures_matrix, target = 0.5), rep(0.8, 10))
})
