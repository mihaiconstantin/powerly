# Testing 'Basis' class.

test_that("'Basis' creates I-Spline bases with correct polynomial degree", {
    # Data.
    x <- 1:10

    # Create basis.
    ispline <- Basis$new(x, df = 0, monotone = TRUE, degree = 3)

    # Test.
    expect_equal(ispline$attrs$degree, 2)
})


test_that("'Basis' creates B-Spline bases with correct polynomial degree", {
    # Data.
    x <- 1:10

    # Create basis.
    bspline <- Basis$new(x, df = 0, monotone = FALSE, degree = 3)

    # Test.
    expect_equal(bspline$attrs$degree, 3)
})


test_that("'Basis' creates the correct type (I-Spline)", {
    # Data.
    x <- 1:10

    # Create basis via 'Basis'.
    ispline_1 <- Basis$new(x, df = 0, monotone = TRUE, degree = 3)$matrix

    # Create basis via 'splines2'.
    ispline_2 <- cbind(1, splines2::iSpline(x, df = 0, degree = 2, intercept = TRUE))

    # Test.
    expect_equal(ispline_1, ispline_2)
})


test_that("'Basis' creates the correct type (B-Spline)", {
    # Data.
    x <- 1:10

    # Create basis via 'Basis'.
    bspline_1 <- Basis$new(x, df = 0, monotone = FALSE, degree = 3)$matrix

    # Create basis via 'splines2'.
    bspline_2 <- splines2::bSpline(x, df = 0, degree = 3, intercept = TRUE)

    # Test.
    expect_equal(bspline_1, bspline_2)
})


test_that("'Basis' creates I-Spline basis with correct degrees of freedom", {
    # Data.
    x <- 1:10

    # Create basis via 'Basis'.
    ispline_1 <- Basis$new(x, df = 3, monotone = TRUE, degree = 3)$matrix

    # Create basis via 'splines2'.
    ispline_2 <- cbind(1, splines2::iSpline(x, df = 3, degree = 2, intercept = TRUE))

    # Test.
    expect_equal(ispline_1, ispline_2)
})


test_that("'Basis' creates B-Spline basis with correct degrees of freedom", {
    # Data.
    x <- 1:10

    # Create basis via 'Basis'.
    bspline_1 <- Basis$new(x, df = 4, monotone = FALSE, degree = 3)$matrix

    # Create basis via 'splines2'.
    bspline_2 <- splines2::bSpline(x, df = 4, degree = 3, intercept = TRUE)

    # Test.
    expect_equal(bspline_1, bspline_2)
})


test_that("'Basis' creates I-Spline basis equivalent to De Leeuw (2017)", {
    # Data.
    x <- 1:10

    # Create I-Spline basis via 'Basis' using Ramsay' (1988) approach.
    ispline_ramsay <- Basis$new(x, df = 0, monotone = TRUE, degree = 3)$matrix

    # Create normalized B-Splines.
    bspline <- splines2::bSpline(x, df = 0, degree = 3, intercept = TRUE)

    # Ceate I-Splines via De Leeuw's (2017, p. 17) approach with cumulative sums of normalized B-Splines.
    bspline_cumsum <- 1 - t(apply(bspline, 1, cumsum))
    bspline_cumsum <- cbind(1, bspline_cumsum[, -ncol(bspline_cumsum)])

    expect_equal(round(ispline_ramsay, 10), round(bspline_cumsum, 10))
})


test_that("'Basis' predicts correctly (I-Spline)", {
    # Data.
    x <- 1:10

    # Element to predict.
    x <- x[-3]

    # Create basis via 'Basis'.
    ispline_1 <- Basis$new(x, df = 5, monotone = TRUE, degree = 3)
    ispline_1_new <- ispline_1$extend(3)

    # Create basis via 'splines2'.
    ispline_2 <- splines2::iSpline(x, df = 5, intercept = TRUE, degree = 2)
    ispline_2_new <- cbind(1, predict(ispline_2, 3))

    # Test.
    expect_equal(ispline_1_new, ispline_2_new)
})


test_that("'Basis' predicts correctly (B-Spline)", {
    # Data.
    x <- 1:10

    # Element to predict.
    x <- x[-3]

    # Create basis via 'Basis'.
    bspline_1 <- Basis$new(x, df = 5, monotone = FALSE, degree = 3)
    bspline_1_new <- bspline_1$extend(3)

    # Create basis via 'splines2'.
    bspline_2 <- splines2::bSpline(x, df = 5, intercept = TRUE, degree = 3)
    bspline_2_new <- predict(bspline_2, 3)

    # Test.
    expect_equal(bspline_1_new, bspline_2_new)
})
