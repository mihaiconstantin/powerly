#' @include Statistic.R

PowerStatistic <- R6::R6Class("PowerStatistic",
    inherit = Statistic,

    public = list(
        compute = function(measures_vector, target) {
            return(mean(measures_vector >= target, na.rm = TRUE))
        },

        apply = function(measures_matrix, target) {
            return(apply(measures_matrix, 2, self$compute, target = target))
        }
    )
)
