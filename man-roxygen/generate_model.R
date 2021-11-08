#' @title
#' Generate true model parameters
#'
#' @description
#' Generate matrices of true model parameters for the supported true models.
#' These matrices are intended to passed to the `model_matrix` argument of
#' [powerly::powerly()].
#'
#' @param type Character string representing the type of true model. Possible
#' values are `"ggm"` (the default).
#'
#' @param ... Required arguments used for the generation of the true model. See
#' the **True Models** section of [powerly::powerly()] for the arguments
#' required for each true model.
#'
#' @return
#' A matrix containing the model parameters.
#'
#' @seealso [powerly::powerly()], [powerly::validate()]
