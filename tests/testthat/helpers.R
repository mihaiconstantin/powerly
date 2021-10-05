# Get the number of cores allowed for parallelization for tests.
get_number_cores <- function() {
    return(2)
}

# Helper based on `quadprog` for testing the `Solver` class.
solve_qp <- function(basis_matrix, y, a_mat, b_vec, meq = 0) {
    # Create matrices for `solve.QP`.
    d_mat <- crossprod(basis_matrix, basis_matrix)
    d_vec <- crossprod(basis_matrix, y)

    # Optimize.
    return(quadprog::solve.QP(Dmat = d_mat, dvec = d_vec, Amat = t(a_mat), bvec = b_vec, meq = meq)$solution)
}

# Helper based on `osqp` for testing the `Solver` class.
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

# Compute performance measures.
compute_measure <- function(true_parameters, estimated_parameters, measure) {
    # Extract the true and estimated parameters from the weights matrices.
    true <- true_parameters[upper.tri(true_parameters)]
    esti <- estimated_parameters[upper.tri(estimated_parameters)]

    # Compute true/ false | positive/ negative rates.
    tp <- sum(true != 0 & esti != 0)
    fp <- sum(true == 0 & esti != 0)
    tn <- sum(true == 0 & esti == 0)
    fn <- sum(true != 0 & esti == 0)

    # Compute and return measure.
    if(measure == "sen") {
        return(tp / (tp + fn))
    } else {
        return(tn / (tn + fp))
    }
}

# Helper for testing private methods of `StepTwo` class.
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

# Helper for testing private methods of `StepThree` class.
StepThreeTester <- R6::R6Class("StepThreeTester",
    inherit = StepThree,

    public = list(
        # Empty constructor.
        initialize = function() {},

        # Expose selection rule to the public API.
        selection_rule = function(spline, statistic_value, monotone, increasing) {
            # Call the method we want to test.
            return(
                private$.selection_rule(spline, statistic_value, monotone, increasing)
            )
        },

        # Expose single bootstrap run to the public API.
        boot = function(available_samples, measures, measure_value, replications, extended_basis, statistic, solver) {
            # Call the method we want to test.
            return(
                private$.boot(1, available_samples, measures, measure_value, replications, extended_basis, statistic, solver)
            )
        }
    )
)

# Helper for testing private methods of `Backend` class.
BackendTester <- R6::R6Class("BackendTester",
    inherit = Backend,

    public = list(
        # Mock the number of cores detected during instantiation.
        mock_machine_available_cores = function(cores) {
            # Predetermine the number of cores on the machine.
            private$.available_cores <- cores
        },

        # Expose the private method for testing.
        set_cores = function(cores) {
            # Set the cores.
            private$.set_cores(cores)
        }
    )
)

# Helper for testing private methods of `Range` class.
RangeTester <- R6::R6Class("RangeTester",
    inherit = Range,

    public = list(
        # Expose `.convergence_test()` for testing.
        convergence_test = function(lower, upper) {
            # Perform the test.
            return(private$.convergence_test(lower, upper))
        }
    )
)
