#' @title
#' Plot `<%= step_class %>` objects
#'
#' @description
#' This function plots the results for Step <%= step_number %> of the method.
#'
#' @param object An object instance of class `<%= step_class %>`.
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
#' An [ggplot2::ggplot] object containing the plot for a `<%= step_class %>` object
#' that can be further modified. The object returned also contains the
#' [patchwork] class applied.
#'
#' \if{html}{
#' Example of a plot:
#'
#' \out{<div style="text-align: center">}
#' \figure{example-step-<%= step_number %>.png}{options: style="width: 640px; max-width: 90\%;" alt="Example Step <%= step_number %>"}
#' \out{</div>}
#' }
#'
#' @seealso [powerly::plot.Method()], [powerly::summary.Method()]
#'
#' @keywords internal
