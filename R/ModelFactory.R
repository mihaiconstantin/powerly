#' @include GgmModel.R

ModelFactory <- R6::R6Class("ModelFactory",
    public = list(
        get_model = function(type) {
            return(
                switch(type,
                    ggm = GgmModel$new(),
                    stop(.__ERRORS__$not_developed)
                )
            )
        }
    )
)
