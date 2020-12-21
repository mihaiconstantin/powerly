#' @title Compute power for all sample sizes.
#' @export
statistic.power <- function(outcome.matrix, target = .8) {
    return(apply(outcome.matrix, 2, function(col) {
         return(compute.power(col, target = target))
    }))
}


#' @title Compute mean for all sample sizes.
#' @export
statistic.mean <- function(outcome.matrix) {
    return(apply(outcome.matrix, 2, function(col) {
         return(mean(col, na.rm = TRUE))
    }))
}


#' @title Compute power for single sample size replications.
#' @export
compute.power <- function(replications, target = .8) {
    replications <- na.omit(replications)
    return(sum(replications >= target) / length(replications))
}
