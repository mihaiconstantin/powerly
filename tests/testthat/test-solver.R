# Testing the 'Solver' class.

test_that("'Solver' sets correct constraints for monotone non-decreasing spline", {
    # Data.
    x <- 1:10
    y <- c(-.5, .8, .6, 1, .3, 1, 1, 1, 1, .5)

    # Create spline basis.
    ispline <- Basis$new(x, df = 0, monotone = TRUE)
    n <- ncol(ispline$matrix)

    # Create solver.
    solver <- Solver$new(ispline, y, increasing = TRUE)

    # Test.
    expect_equal(solver$lower_bounds, c(-Inf, rep(0, n - 1)))
    expect_equal(solver$upper_bounds, rep(Inf, n))
})


test_that("'Solver' sets correct constraints for monotone non-increasing spline", {
    # Data.
    x <- 1:10
    y <- c(-.5, .8, .6, 1, .3, 1, 1, 1, 1, .5)

    # Create spline basis.
    ispline <- Basis$new(x, df = 0, monotone = TRUE)
    n <- ncol(ispline$matrix)

    # Create solver.
    solver <- Solver$new(ispline, y, increasing = FALSE)

    # Test.
    expect_equal(solver$lower_bounds, rep(-Inf, n))
    expect_equal(solver$upper_bounds, c(Inf, rep(0, n - 1)))
})


test_that("'Solver' sets correct constraints for non-monotone spline", {
    # Data.
    x <- 1:10
    y <- c(-.5, .8, .6, 1, .3, 1, 1, 1, 1, .5)

    # Create basis.
    bspline <- Basis$new(x, df = 0, monotone = FALSE)
    n <- ncol(bspline$matrix)

    # Create solver.
    solver <- Solver$new(bspline, y)

    # Test.
    expect_equal(solver$lower_bounds, rep(-Inf, n))
    expect_equal(solver$upper_bounds, rep(Inf, n))
})


test_that("'Solver' gives correct solution for monotone non-decreasing spline", {
    # Data.
    x <- 1:10
    y <- c(-0.2, 0.3, 0.5, 0.7, 0.6, 1, 0.9, 1, 1, 1)

    # Create spline.
    ispline <- Basis$new(x, df = 0, monotone = TRUE)
    n <- ncol(ispline$matrix)

    # Solve using solver.
    solver_alpha <- Solver$new(ispline, y, increasing = TRUE)$solve()

    # Solve using 'quadprog'.
    a_mat <- diag(1, n)
    a_mat[1, 1] <- 0
    b_vec <- rep(0, n)
    quadprog_alpha <- solve_qp(ispline$matrix, y, a_mat, b_vec)

    expect_equal(solver_alpha, quadprog_alpha)
})


test_that("'Solver' gives correct solution for monotone non-increasing spline", {
    # Data.
    x <- 1:10
    y <- rev(c(-0.2, 0.3, 0.5, 0.7, 0.6, 1, 0.9, 1, 1, 1))

    # Create spline.
    ispline <- Basis$new(x, df = 0, monotone = TRUE)
    n <- ncol(ispline$matrix)

    # Solve using solver.
    solver_alpha <- Solver$new(ispline, y, increasing = FALSE)$solve()

    # Solve using 'quadprog'.
    a_mat <- diag(-1, n)
    a_mat[1, 1] <- 0
    b_vec <- rep(0, n)
    quadprog_alpha <- solve_qp(ispline$matrix, y, a_mat, b_vec)

    expect_equal(solver_alpha, quadprog_alpha)
})


test_that("'Solver' gives correct solution for non-monotone spline", {
    # Data.
    x <- 1:10
    y <- c(-.5, .8, .6, 1, .3, 1, 1, 1, 1, .5)

    # Create spline.
    bspline <- Basis$new(x, df = 0, monotone = FALSE)

    # Solve using solver.
    solver_alpha <- Solver$new(bspline, y)$solve()

    # Solve using 'lm'.
    lm_alpha <- as.numeric(lm.fit(bspline$matrix, y)$coefficients)

    # Test.
    expect_equal(solver_alpha, lm_alpha)
})


test_that("'Solver' gives correct solution for updated statistics", {
    # Data.
    x <- 1:10
    y <- c(-0.2, 0.3, 0.5, 0.7, 0.6, 1, 0.9, 1, 1, 1)

    # Create spline.
    ispline <- Basis$new(x, df = 0, monotone = TRUE)
    n <- ncol(ispline$matrix)

    # Create solver.
    solver <- Solver$new(ispline, y, increasing = TRUE)

    # Solve the original problem to create the model.
    solver$solve()

    # Create new data to update the solver.
    y_new <- sample(y, length(y), TRUE)

    # Update solver and solve problem.
    solver_alpha <- solver$solve.update(y_new)

    # Solve problem with new data using 'osqp' helper.
    osqp_alpha <- solve_osqp(ispline$matrix, y_new, solver$lower_bounds, solver$upper_bounds)

    # Solve problem with new data using 'quadprog' helper.
    a_mat <- diag(1, n)
    a_mat[1, 1] <- 0
    b_vec <- rep(0, n)
    quadprog_alpha <- solve_qp(ispline$matrix, y_new, a_mat, b_vec)

    # Tests.
    expect_equal(solver_alpha, osqp_alpha)
    expect_equal(solver_alpha, quadprog_alpha)
})


test_that("'Solver' throws error if trying to update non-model", {
    # Data.
    x <- 1:10
    y <- c(-0.2, 0.3, 0.5, 0.7, 0.6, 1, 0.9, 1, 1, 1)

    # Create spline.
    ispline <- Basis$new(x, df = 0, monotone = TRUE)

    # Create solver.
    solver <- Solver$new(ispline, y, increasing = TRUE)

    # Create new data to update the solver.
    y_new <- sample(y, length(y), TRUE)

    # Update solver and solve problem without having called '$solve()' previously.
    testthat::expect_error(solver$solve.update(y_new))
})