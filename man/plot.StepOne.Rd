% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/StepOne.R
\name{plot.StepOne}
\alias{plot.StepOne}
\title{Plot \code{StepOne} objects}
\usage{
\method{plot}{StepOne}(x, save = FALSE, path = NULL, width = 14, height = 10, ...)
}
\arguments{
\item{x}{An object instance of class \code{StepOne}.}

\item{save}{A logical value indicating whether the plot should be saved to a
file on disk.}

\item{path}{A character string representing the path (i.e., including the
filename and extension) where the plot should be saved on disk. If \code{NULL},
the plot will be saved in the current working directory with a filename
generated based on the current system time and a \code{.pdf} extension. See
\code{\link[ggplot2:ggsave]{ggplot2::ggsave()}} for supported file types.}

\item{width}{A single numerical value representing the desired plot width.
The default unit is inches (i.e., set by \code{\link[ggplot2:ggsave]{ggplot2::ggsave()}}), unless
overridden by providing the \code{units} argument via \code{...}.}

\item{height}{A single numerical value representing the desired plot height.
The default unit is inches (i.e., set by \code{\link[ggplot2:ggsave]{ggplot2::ggsave()}}), unless
overridden by providing the \code{units} argument via \code{...}.}

\item{...}{Optional arguments to be passed to \code{\link[ggplot2:ggsave]{ggplot2::ggsave()}}.}
}
\value{
An \link[ggplot2:ggplot]{ggplot2::ggplot} object containing the plot for a \code{StepOne} object
that can be further modified. The object returned also contains the
\link{patchwork} class applied.

\if{html}{
Example of a plot:
\out{<span style="display: block; text-align: center; margin-top: 1rem;">}
\figure{example-step-1.png}{options: style="width: 640px; max-width: 90\%;" alt="Example Step 1"}
\out{</span>}
}
}
\description{
This function plots the results for Step 1 of the method.
}
\seealso{
\code{\link[=plot.Method]{plot.Method()}}, \code{\link[=summary.Method]{summary.Method()}}
}
\keyword{internal}
