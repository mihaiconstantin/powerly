QuadprogSolver <- R6::R6Class("QuadprogSolver",
    inherit = Solver,

    private = list(
        .basis = NULL,
        .y = NULL,
        .increasing = NULL,
        .n = NULL,

        # Solver equation inputs.
        .d_mat = NULL,
        .d_vec = NULL,
        .a_mat = NULL,
        .b_vec = NULL,

        # Create matrices used by the solver.
        .create_matrices = function() {
            private$.d_mat <- crossprod(private$.basis$matrix, private$.basis$matrix)
            private$.d_vec <- crossprod(private$.basis$matrix, private$.y)
        },

        # Set constraints matrix.
        .set_constraints = function() {
            # Apply equality constraints as necessary.
            if (private$.basis$monotone) {
                if (private$.increasing) {
                    # Non-negativity constraints (i.e., used for non-decreasing I-Splines).
                    a_mat <- diag(1, private$.n)
                } else {
                    # Non-positivity constraints (i.e., used for non-increasing I-Splines).
                    a_mat <- diag(-1, private$.n)
                }
                # For I-Splines, release the first parameter.
                 a_mat[1, 1] <- 0
            } else {
                # No constraints (i.e., used for B-Splines).
                a_mat <- diag(0, private$.n)
            }

            # Set the constraints matrix.
            private$.a_mat <- a_mat
        },

        # Set bounds for the constraints matrix.
        .set_bounds = function() {
            private$.b_vec <- rep(0, private$.n)
        }
    ),

    public = list(
        # Setup the solver.
        setup = function(basis, y, increasing = NULL) {
            # Set input.
            private$.basis <- basis
            private$.y <- y
            private$.increasing <- increasing

            # Compute number of basis functions.
            private$.n <- ncol(basis$matrix)

            # Prepare the solver.
            private$.create_matrices()
            private$.set_constraints()
            private$.set_bounds()
        },

        # Solve based on the setup.
        solve = function() {
            # Return the solution.
            return(
                quadprog::solve.QP(
                    Dmat = private$.d_mat,
                    dvec = private$.d_vec,
                    Amat = private$.a_mat,
                    bvec = private$.b_vec,
                    meq = 0
                )$solution
            )
        },

        # Solve with updated 'y' vector.
        solve_update = function(y_new) {
            # Solve and return the updated solution.
            return(
                quadprog::solve.QP(
                    Dmat = private$.d_mat,
                    dvec = crossprod(private$.basis$matrix, y_new),
                    Amat = private$.a_mat,
                    bvec = private$.b_vec,
                    meq = 0
                )$solution
            )
        }
    ),

    active = list(
        increasing = function() { return(private$.increasing) }
    )
)
