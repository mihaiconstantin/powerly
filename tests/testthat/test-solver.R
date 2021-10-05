# Testing concrete implementations of the 'Solver' class.

test_that("'Solver' implementations set correct constraints for monotone non-decreasing spline", {
    # Data.
    x <- 1:10
    y <- c(-.5, .8, .6, 1, .3, 1, 1, 1, 1, .5)

    # Create spline basis.
    ispline <- Basis$new(x, df = 0, monotone = TRUE)
    n <- ncol(ispline$matrix)

    # Create solvers.
    osqp <- OsqpSolver$new()
    qp <- QuadprogSolver$new()

    # Setup solvers.
    osqp$setup(ispline, y, increasing = TRUE)
    qp$setup(ispline, y, increasing = TRUE)

    # Test bounds for 'OsqpSolver'.
    expect_equal(osqp$.__enclos_env__$private$.lower, c(-Inf, rep(0, n - 1)))
    expect_equal(osqp$.__enclos_env__$private$.upper, rep(Inf, n))

    # Constraints for 'QuadprogSolver'.
    b_vec <- rep(0, n)
    a_mat <- diag(1, n)
    a_mat[1, 1] <- 0

    # Test constraints for 'QuadprogSolver'.
    expect_equal(qp$.__enclos_env__$private$.b_vec, b_vec)
    expect_equal(qp$.__enclos_env__$private$.a_mat, a_mat)
})


test_that("'Solver' implementations set correct constraints for monotone non-increasing spline", {
    # Data.
    x <- 1:10
    y <- c(-.5, .8, .6, 1, .3, 1, 1, 1, 1, .5)

    # Create spline basis.
    ispline <- Basis$new(x, df = 0, monotone = TRUE)
    n <- ncol(ispline$matrix)

    # Create solvers.
    osqp <- OsqpSolver$new()
    qp <- QuadprogSolver$new()

    # Setup solvers.
    osqp$setup(ispline, y, increasing = FALSE)
    qp$setup(ispline, y, increasing = FALSE)

    # Test bounds for 'OsqpSolver'.
    expect_equal(osqp$.__enclos_env__$private$.lower, rep(-Inf, n))
    expect_equal(osqp$.__enclos_env__$private$.upper, c(Inf, rep(0, n - 1)))

    # Constraints for 'QuadprogSolver'.
    b_vec <- rep(0, n)
    a_mat <- diag(-1, n)
    a_mat[1, 1] <- 0

    # Test constraints for 'QuadprogSolver'.
    expect_equal(qp$.__enclos_env__$private$.b_vec, b_vec)
    expect_equal(qp$.__enclos_env__$private$.a_mat, a_mat)
})


test_that("'Solver' implementations set correct constraints for non-monotone spline", {
    # Data.
    x <- 1:10
    y <- c(-.5, .8, .6, 1, .3, 1, 1, 1, 1, .5)

    # Create basis.
    bspline <- Basis$new(x, df = 0, monotone = FALSE)
    n <- ncol(bspline$matrix)

    # Create solvers.
    osqp <- OsqpSolver$new()
    qp <- QuadprogSolver$new()

    # Setup solvers.
    osqp$setup(bspline, y)
    qp$setup(bspline, y)

    # Test bounds for 'OsqpSolver'.
    expect_equal(osqp$.__enclos_env__$private$.lower, rep(-Inf, n))
    expect_equal(osqp$.__enclos_env__$private$.upper, rep(Inf, n))

    # Constraints for 'QuadprogSolver'.
    b_vec <- rep(0, n)
    a_mat <- diag(0, n)

    # Test constraints for 'QuadprogSolver'.
    expect_equal(qp$.__enclos_env__$private$.b_vec, b_vec)
    expect_equal(qp$.__enclos_env__$private$.a_mat, a_mat)
})


test_that("'Solver' implementations give correct solution for monotone non-decreasing spline", {
    # Data.
    x <- 1:10
    y <- c(-0.2, 0.3, 0.5, 0.7, 0.6, 1, 0.9, 1, 1, 1)

    # Create spline.
    ispline <- Basis$new(x, df = 0, monotone = TRUE)
    n <- ncol(ispline$matrix)

    # Create solvers.
    osqp <- OsqpSolver$new()
    qp <- QuadprogSolver$new()

    # Setup solvers.
    osqp$setup(ispline, y, increasing = TRUE)
    qp$setup(ispline, y, increasing = TRUE)

    # Solve using own implementations.
    osqp_impl_alpha <- osqp$solve()
    qp_impl_alpha <- qp$solve()

    # Solve using 'quadprog'.
    a_mat <- diag(1, n)
    a_mat[1, 1] <- 0
    b_vec <- rep(0, n)
    qp_alpha <- solve_qp(ispline$matrix, y, a_mat, b_vec)

    # Solve using 'osqp'.
    osqp_alpha <- solve_osqp(ispline$matrix, y, c(-Inf, rep(0, n - 1)), rep(Inf, n))

    # Each implementation should be equal with its counterpart.
    expect_equal(osqp_impl_alpha, osqp_alpha, tolerance = 1e-6)
    expect_equal(qp_impl_alpha, qp_alpha, tolerance = 1e-6)

    # The implementations should also give the same solution.
    expect_equal(osqp_impl_alpha, qp_impl_alpha, tolerance = 1e-6)
})


test_that("'Solver' implementations give correct solution for monotone non-increasing spline", {
    # Data.
    x <- 1:10
    y <- rev(c(-0.2, 0.3, 0.5, 0.7, 0.6, 1, 0.9, 1, 1, 1))

    # Create spline.
    ispline <- Basis$new(x, df = 0, monotone = TRUE)
    n <- ncol(ispline$matrix)

    # Create solvers.
    osqp <- OsqpSolver$new()
    qp <- QuadprogSolver$new()

    # Setup solvers.
    osqp$setup(ispline, y, increasing = FALSE)
    qp$setup(ispline, y, increasing = FALSE)

    # Solve using own implementations.
    osqp_impl_alpha <- osqp$solve()
    qp_impl_alpha <- qp$solve()

    # Solve using 'quadprog'.
    a_mat <- diag(-1, n)
    a_mat[1, 1] <- 0
    b_vec <- rep(0, n)
    qp_alpha <- solve_qp(ispline$matrix, y, a_mat, b_vec)

    # Solve using 'osqp'.
    osqp_alpha <- solve_osqp(ispline$matrix, y, rep(-Inf, n), c(Inf, rep(0, n - 1)))

    # Each implementation should be equal with its counterpart.
    expect_equal(osqp_impl_alpha, osqp_alpha, tolerance = 1e-6)
    expect_equal(qp_impl_alpha, qp_alpha, tolerance = 1e-6)

    # The implementations should also give the same solution.
    expect_equal(osqp_impl_alpha, qp_impl_alpha, tolerance = 1e-6)
})


test_that("'Solver' implementations give correct solution for non-monotone spline", {
    # Data.
    x <- 1:10
    y <- c(-.5, .8, .6, 1, .3, 1, 1, 1, 1, .5)

    # Create spline.
    bspline <- Basis$new(x, df = 0, monotone = FALSE)

    # Create solvers.
    osqp <- OsqpSolver$new()
    qp <- QuadprogSolver$new()

    # Setup solvers.
    osqp$setup(bspline, y)
    qp$setup(bspline, y)

    # Solve using own implementations.
    osqp_impl_alpha <- osqp$solve()
    qp_impl_alpha <- qp$solve()

    # Solve using 'lm'.
    lm_alpha <- as.numeric(lm.fit(bspline$matrix, y)$coefficients)

    # Test.
    expect_equal(osqp_impl_alpha, lm_alpha, tolerance = 1e-6)
    expect_equal(qp_impl_alpha, lm_alpha, tolerance = 1e-6)
})


test_that("'Solver' implementations gives correct solution for updated statistics", {
    # Data.
    x <- 1:10
    y <- c(-0.2, 0.3, 0.5, 0.7, 0.6, 1, 0.9, 1, 1, 1)

    # Create spline.
    ispline <- Basis$new(x, df = 0, monotone = TRUE)
    n <- ncol(ispline$matrix)

    # Create solvers.
    osqp <- OsqpSolver$new()
    qp <- QuadprogSolver$new()

    # Setup solvers.
    osqp$setup(ispline, y, increasing = TRUE)
    qp$setup(ispline, y, increasing = TRUE)

    # Solve first time with original data.
    osqp$solve()
    qp$solve()

    # Create new data to update the solver.
    y_new <- sample(y, length(y), TRUE)

    # Update solvers and solve problem.
    osqp_impl_alpha <- osqp$solve_update(y_new)
    qp_impl_alpha <- qp$solve_update(y_new)

    # Solve problem with new data using 'osqp' helper.
    osqp_alpha <- solve_osqp(ispline$matrix, y_new, osqp$.__enclos_env__$private$.lower, osqp$.__enclos_env__$private$.upper)

    # Solve problem with new data using 'quadprog' helper.
    qp_alpha <- solve_qp(ispline$matrix, y_new, qp$.__enclos_env__$private$.a_mat, qp$.__enclos_env__$private$.b_vec)

    # The solver implementations should agree with their counterpart helpers.
    expect_equal(osqp_impl_alpha, osqp_alpha, tolerance = 1e-6)
    expect_equal(qp_impl_alpha, qp_alpha, tolerance = 1e-6)

    # The solver implementations should give the same solution.
    expect_equal(osqp_impl_alpha, qp_impl_alpha, tolerance = 1e-6)
})


test_that("'Solver' implementations still give original solution after solving with updated data", {
    # Data.
    x <- 1:10
    y <- c(-0.2, 0.3, 0.5, 0.7, 0.6, 1, 0.9, 1, 1, 1)

    # Create spline.
    ispline <- Basis$new(x, df = 0, monotone = TRUE)

    # Create solvers.
    osqp <- OsqpSolver$new()
    qp <- QuadprogSolver$new()

    # Setup solvers.
    osqp$setup(ispline, y, increasing = TRUE)
    qp$setup(ispline, y, increasing = TRUE)

    # Solve first time with original data.
    osqp_first_alpha <- osqp$solve()
    qp_first_alpha <- qp$solve()

    # Create new data to update the solver.
    y_new <- sample(y, length(y), TRUE)

    # Solve with updated data.
    osqp$solve_update(y_new)
    qp$solve_update(y_new)

    # Solve again and expect to recover the original solution.
    expect_equal(osqp_first_alpha, osqp$solve())
    expect_equal(qp_first_alpha, qp$solve())
})


test_that("'Solver' base class throws errors for abstract methods", {
    # Create `Solver` base class.
    solver <- Solver$new()

    # Expect error because the methods are abstract.
    expect_error(solver$setup(NULL, NULL, NULL), .__ERRORS__$not_implemented)
    expect_error(solver$solve(), .__ERRORS__$not_implemented)
    expect_error(solver$solve_update(NULL), .__ERRORS__$not_implemented)
})
