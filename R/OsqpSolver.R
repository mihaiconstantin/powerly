OsqpSolver <- R6::R6Class("OsqpSolver",
    inherit = Solver,

    private = list(
        .basis = NULL,
        .y = NULL,
        .increasing = NULL,
        .n = NULL,

        # Solver settings.
        .settings = NULL,

        # Solver equation inputs.
        .p_mat = NULL,
        .q_vec = NULL,
        .a_mat = NULL,
        .lower = NULL,
        .upper = NULL,

        # Model object.
        .model = NULL,

        .set_settings = function() {
            private$.settings <- osqp::osqpSettings(
                verbose = FALSE,
                eps_abs = 1e-10,
                eps_rel = 1e-10,
                linsys_solver = 0L,
                warm_start = FALSE
            )
        },

        .create_matrices = function() {
            private$.p_mat <- crossprod(private$.basis$matrix, private$.basis$matrix)
            private$.q_vec <- -crossprod(private$.basis$matrix, private$.y)
        },

        .set_constraints = function() {
            private$.a_mat <- diag(1, private$.n)
        },

        .set_bounds = function() {
            if(private$.basis$monotone) {
                if(private$.increasing) {
                    private$.lower <- c(-Inf, rep(0, private$.n - 1))
                    private$.upper <- rep(Inf, private$.n)
                } else {
                    private$.lower <- rep(-Inf, private$.n)
                    private$.upper <- c(Inf, rep(0, private$.n - 1))
                }
            } else {
                private$.lower <- rep(-Inf, private$.n)
                private$.upper <- rep(Inf, private$.n)
            }
        },

        .make_model = function() {
            private$.model <- osqp::osqp(
                P = private$.p_mat,
                q = private$.q_vec,
                A = private$.a_mat,
                l = private$.lower,
                u = private$.upper,
                pars = private$.settings
            )
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
            private$.n <- ncol(private$.basis$matrix)

            # Prepare solver.
            private$.set_settings()
            private$.create_matrices()
            private$.set_constraints()
            private$.set_bounds()
        },

        # Solve based on the provided setup.
        solve = function() {
            # Make the model.
            private$.make_model()

            # Return the solution.
            return(private$.model$Solve()$x)
        },

        # Solve with updated 'y' vector.
        solve_update = function(y_new) {
            # Update the model with new `q` vector.
            private$.model$Update(q = -crossprod(private$.basis$matrix, y_new))

            # Solve and return.
            return(private$.model$Solve()$x)
        }
    ),

    active = list(
        increasing = function() { return(private$.increasing) }
    )
)
