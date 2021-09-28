#' @title
#' Fetch `ggplot2` theme settings.
#'
#' @description
#' This function is used to create reusable `ggplot2` theme settings.
#'
#' @return A list of `ggplot2` layers.
#'
#' @keywords internal
plot_settings <- function() {
    return(
        list(
            # Main theme.
            ggplot2::theme_bw(),

            # Common specific theme settings.
            ggplot2::theme(
                plot.title = ggplot2::element_text(
                    face = "bold",
                    vjust = 0.5,
                    size = 11
                ),
                axis.title.x = ggplot2::element_text(
                    margin = ggplot2::margin(t = 5, r = 0, b = 0, l = 0),
                    size = 10
                ),
                axis.title.y = ggplot2::element_text(
                    margin = ggplot2::margin(t = 0, r = 5, b = 0, l = 0),
                    size = 10
                ),
                axis.text.x = ggplot2::element_text(
                    margin = ggplot2::margin(t = 5, r = 0, b = 0, l = 0),
                    size = 9,
                    angle = 90,
                    vjust = 0.5,
                    hjust = 1
                ),
                axis.text.y = ggplot2::element_text(
                    margin = ggplot2::margin(t = 0, r = 5, b = 0, l = 0),
                    size = 9
                ),
                panel.grid.minor = ggplot2::element_line(
                    size = 0.1
                ),
                panel.grid.major = ggplot2::element_line(
                    size = 0.1
                )
            )
        )
    )
}
