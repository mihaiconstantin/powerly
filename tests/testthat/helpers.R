solve_qp <- function(basis_matrix, y, a_mat, b_vec, meq = 0) {
    # Create matrices for `solve.QP`.
    d_mat <- crossprod(basis_matrix, basis_matrix)
    d_vec <- crossprod(basis_matrix, y)

    # Optimize.
    return(quadprog::solve.QP(Dmat = d_mat, dvec = d_vec, Amat = t(a_mat), bvec = b_vec, meq = meq)$solution)
}

solve_osqp <- function(basis_matrix, y, lower, upper) {
    # Set settings.
    settings <- osqp::osqpSettings(
        verbose = FALSE,
        eps_abs = 1e-8,
        eps_rel = 1e-8,
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
