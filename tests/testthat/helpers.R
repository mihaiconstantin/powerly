# Helper based on 'quadprog' for testing the 'Solver' class.
solve_qp <- function(basis_matrix, y, a_mat, b_vec, meq = 0) {
    # Create matrices for `solve.QP`.
    d_mat <- crossprod(basis_matrix, basis_matrix)
    d_vec <- crossprod(basis_matrix, y)

    # Optimize.
    return(quadprog::solve.QP(Dmat = d_mat, dvec = d_vec, Amat = t(a_mat), bvec = b_vec, meq = meq)$solution)
}

# Helper based on 'osqp' for testing the 'Solver' class.
solve_osqp <- function(basis_matrix, y, lower, upper) {
    # Set settings.
    settings <- osqp::osqpSettings(
        verbose = FALSE,
        eps_abs = 1e-10,
        eps_rel = 1e-10,
        linsys_solver = 0L,
        warm_start = FALSE
    )

    # Create matrices for `osqp`.
    p_mat <- crossprod(basis_matrix, basis_matrix)
    q_vec <- -crossprod(basis_matrix, y)

    # Create constraint matrix.
    a_mat <- diag(1, ncol(basis_matrix))

    # Create model.
    model <- osqp::osqp(
        P = p_mat,
        q = q_vec,
        A = a_mat,
        l = lower,
        u = upper,
        pars = settings
    )

    # Optimize.
    return(model$Solve()$x)
}

# Helper for testing private methods of 'StepTwo' class.
StepTwoTester <- R6::R6Class("StepTwoTester",
    inherit = StepTwo,

    public = list(
        check_df = function(df, monotone) {
            # Call the method we want to test.
            private$.check_df(df, monotone)
        },

        run_cv = function(monotone, increasing, df, solver_type, ...) {
            # Call the method we want to test.
            private$.run_cv(monotone, increasing, df, solver_type, ...)
        }
    )
)

# Helper for testing private methods of 'StepThree' class.
StepThreeTester <- R6::R6Class("StepThreeTester",
    inherit = StepThree,

    public = list(
        # Empty constructor.
        initialize = function() {},

        # Expose to the public API the function to test.
        selection_rule = function(spline, statistic_value, monotone, increasing) {
            # Call the method we want to test.
            private$.selection_rule(spline, statistic_value, monotone, increasing)
        }
    )
)
