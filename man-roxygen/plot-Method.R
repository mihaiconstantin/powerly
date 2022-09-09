#' @title
#' Plot the results of a sample size analysis
#'
#' @description
#' This function plots the results for each step of the method.
#'
#' @param x An object instance of class `Method`.
#'
#' @param step A single positive integer representing the method step that
#' should be plotted. Possibles values are `1` for the first step, `2` for the
#' second step, and `3` for the third step of the method.
#'
#' @param last A logical value indicating whether the last iteration of the
#' method should be plotted. The default is `TRUE`, indicating that the last
#' iteration should be plotted.
#'
#' @param save A logical value indicating whether the plot should be saved to a
#' file on disk.
#'
#' @param path A character string representing the path (i.e., including the
#' filename and extension) where the plot should be saved on disk. If `NULL`,
#' the plot will be saved in the current working directory with a filename
#' generated based on the current system time and a `.pdf` extension. See
#' [ggplot2::ggsave()] for supported file types.
#'
#' @param width A single numerical value representing the desired plot width.
#' The default unit is inches (i.e., set by [ggplot2::ggsave()]), unless
#' overridden by providing the `units` argument via `...`.
#'
#' @param height A single numerical value representing the desired plot height.
#' The default unit is inches (i.e., set by [ggplot2::ggsave()]), unless
#' overridden by providing the `units` argument via `...`.
#'
#' @param ... Optional arguments to be passed to [ggplot2::ggsave()].
#'
#' @return
#' An [ggplot2::ggplot] object containing the plot for the requested step of the
#' method. The plot object returned can be further modified and also contains
#' the [patchwork] class applied.
#'
#' \if{html}{
#' Example of a plot for each step of the method:
#' \out{<span style="display: block; text-align: center;">}
#' \out{<span style="display: block; margin-top: 1rem; margin-bottom: 0.5rem">}\strong{Step 1: Monte Carlo Replications}\out{</span>}
#' \figure{example-step-1.png}{options: style="width: 640px; max-width: 90\%;" alt="Example Step 1"}
#' \out{</span>}
#' \out{<span style="display: block; text-align: center;">}
#' \out{<span style="display: block; margin-top: 1rem; margin-bottom: 0.5rem">}\strong{Step 2: Curve Fitting}\out{</span>}
#' \figure{example-step-2.png}{options: style="width: 640px; max-width: 90\%;" alt="Example Step 2"}
#' \out{</span>}
#' \out{<span style="display: block; text-align: center;">}
#' \out{<span style="display: block; margin-top: 1rem; margin-bottom: 0.5rem">}\strong{Step 3: Bootstrapping}\out{</span>}
#' \figure{example-step-3.png}{options: style="width: 640px; max-width: 90\%;" alt="Example Step 3"}
#' \out{</span>}
#' }
#'
#' @seealso [powerly::summary.Method()], [powerly::powerly()]
