#' @include PowerStatistic.R

StatisticFactory <- R6::R6Class("StatisticFactory",
    public = list(
        get_statistic = function(type) {
            return(
                switch(type,
                    power = PowerStatistic$new(),
                    stop(.__ERRORS__$not_developed)
                )
            )
        }
    )
)
