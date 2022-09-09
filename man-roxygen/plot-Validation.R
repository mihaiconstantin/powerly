#' @title
#' Plot the results of a sample size analysis validation
#'
#' @description
#' This function plots the results for of a sample size analysis validation.
#'
#' @param x An object instance of class `Validation`.
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
#' @param bins A single positive integer passed to [ggplot2::geom_histogram()]
#' representing the number of bins to use for the histogram plot. The default
#' value is `20`.
#'
#' @param ... Optional arguments to be passed to [ggplot2::ggsave()].
#'
#' @return
#' An [ggplot2::ggplot] object containing the plot for the validation procedure.
#' The plot object returned can be further modified and also contains the
#' [patchwork] class applied.
#'
#' \if{html}{
#' Example of a validation plot:
#' \out{<div style="text-align: center">}
#' \figure{example-validation.png}{options: style="width: 640px; max-width: 90\%;" alt="Example Validation"}
#' \out{</div>}
#' }
#'
#' @seealso [powerly::summary.Validation()], [powerly::validate()]
