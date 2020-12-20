#' @title Compute power of outcomes.
#' @export
statistic.power <- function(outcome.matrix, target = .8, eps = .000) {
    return(apply(outcome.matrix, 2, function(col) {
         col <- na.omit(col)
         return(sum(col >= (target - eps)) / length(col))
    }))
}


#' @title Compute mean of outcomes.
#' @export
statistic.mean <- function(outcome.matrix) {
    return(apply(outcome.matrix, 2, function(col) {
         return(mean(col, na.rm = TRUE))
    }))
}
