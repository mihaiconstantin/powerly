#' @title Step 2.
#' @export
run.step.2 <- function(step.1, monotone = TRUE, non.increasing = FALSE, verbose = TRUE) {
    # User feedback.
    if(verbose) cat("Starting step 2...", "\n")

    # Create result environment.
    e <- new.env()

    # User feedback.
    if(verbose) cat("Fitting the spline...", "\n")

    # Get the spline results and store them.
    e <- spline.methdology(step.1$selected.sample.sizes, step.1$statistic, monotone = monotone, non.increasing = non.increasing)

    # Add class.
    class(e) <- "step.2"

    # User feedback.
    if(verbose) cat("Step 2 completed.", "\n\n\n")

    return(e)
}


#' @title Apply spline methdology.
spline.methdology <- function(x, y, monotone = TRUE, non.increasing = FALSE) {
    # Create result environment.
    e <- new.env()

    # Cross-validate and decide the number of knots to use.
    inner.knots <- x[2:(length(x) - 1)]

    # Fit a single spline to the entire data.
    e$fit <- fit.spline(x, y, inner.knots, monotone, non.increasing)

    # Interpolate single spline.
    e$interpolate <- interpolate.spline(min(x):max(x), e$fit)

    # Add class.
    class(e) <- "spline"

    return(e)
}


#' @title Fit spline.
fit.spline <- function(x, y, inner.knots, monotone = TRUE, non.increasing = TRUE, ...) {
    # Create basis.
    basis <- make.spline.basis(x = x, inner.knots = inner.knots, monotone = monotone, non.increasing = non.increasing, ...)

    # Find spline coefficients.
    spline <- find.spline.coefficients(y = y, basis = basis)

    return(spline)
}


#' @title Make spline basis.
make.spline.basis <- function(x, inner.knots, monotone, non.increasing, ...) {
    # Create storage.
    e <- new.env()

    # Attach parameters.
    e$x <- x
    e$inner.knots <- inner.knots
    e$monotone <- monotone
    e$non.increasing <- non.increasing

    # Decide what procedure to use (B-Splines or I-Splines).
    if(monotone) {
        # Adjust the data and the inner knots for non-increasing trends.
        if(non.increasing) {
            # Create I-Spline basis for a non-increasing scenario.
            e$basis <- splines2::iSpline(-x, knots = -inner.knots, degree = 3, intercept = TRUE, ...)
        } else {
            # Create I-Spline basis for a non-decreasing scenario.
            e$basis <- splines2::iSpline(x, knots = inner.knots, degree = 3, intercept = TRUE, ...)
        }

        # Add constant.
        e$basis[, 1] <- 1
    } else {
        # Create B-Spline basis.
        e$basis <- splines2::bSpline(x, knots = inner.knots, degree = 3, intercept = TRUE, ...)
    }

    return(e)
}


#' @title Find spline coefficients.
find.spline.coefficients <- function(y, basis) {
    # Create Storage.
    e <- new.env()

    # Attach basis and outcomes.
    e$basis <- basis
    e$y <- y

    # Get the spline coefficients.
    if(basis$monotone) {
        # Get alpha vector constrained to >= 0.
        e$alpha <- nnls::nnls(basis$basis, y)$x
    } else {
        # Get unconstrained alpha.
        e$alpha <- lm.fit(basis$basis, y)$coefficients
    }

    # Compute predicted values.
    e$spline <- basis$basis %*% e$alpha

    return(e)
}


#' @title Interpolate spline.
interpolate.spline <- function(x, spline, ...) {
    # Create result environment.
    e <- new.env()

    # Create new `x` for interpolation.
    e$x <- x

    # Check whether a non-increasing trend applies to the current basis.
    if(spline$basis$non.increasing) {
        # Create the right basis for interpolation with non-increasing trend.
        e$basis <- predict(spline$basis$basis, -x)
    } else {
        # Create the right basis for interpolation.
        e$basis <- predict(spline$basis$basis, x)
    }

    # Add constant.
    if(spline$basis$monotone) e$basis[, 1] <- 1

    # Interpolate.
    e$spline <- e$basis %*% spline$alpha

    return(e)
}
