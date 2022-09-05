---
pageClass: page-reference
---

# Plot Validation Results

## Description

The `plot.Validation` [`S3` method](https://adv-r.hadley.nz/oo.html) plots the
results of a sample size analysis validation.

## Usage

```r:no-line-numbers
plot(
    x,
    save = FALSE,
    path = NULL,
    width = 14,
    height = 10,
    bins = 20,
    ...
)
```

## Arguments

|   Name   | Description                                                                                                                                                                                                                                                                                                                                                                                |
| :------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|   `x`    | An object instance of class `Validation` produced by the function [`validate`](/reference/function/validate).                                                                                                                                                                                                                                                                              |
|  `save`  | A logical value indicating whether the plot should be saved to a file on disk.                                                                                                                                                                                                                                                                                                             |
|  `path`  | A character string representing the path (i.e., including the filename and extension) where the plot should be saved on disk. If `NULL`, the plot will be saved in the current working directory with a filename generated based on the current system time and a `.pdf` extension. See [`ggplot2::ggsave`](https://ggplot2.tidyverse.org/reference/ggsave.html) for supported file types. |
| `width`  | A single numerical value representing the desired plot width. The default unit is inches (i.e., set by [`ggplot2::ggsave`](https://ggplot2.tidyverse.org/reference/ggsave.html)), unless overridden by providing the `units` argument via `...`.                                                                                                                                           |
| `height` | A single numerical value representing the desired plot height. The default unit is inches (i.e., set by [`ggplot2::ggsave`](https://ggplot2.tidyverse.org/reference/ggsave.html)), unless overridden by providing the `units` argument via `...`.                                                                                                                                          |
|  `bins`  | A single positive integer passed to [`ggplot2::geom_histogram`](https://ggplot2.tidyverse.org/reference/geom_histogram.html) representing the number of bins to use for the histogram plot. The default value is `20`.                                                                                                                                                                     |
|  `...`   | Optional arguments to be passed to [`ggplot2::ggsave`](https://ggplot2.tidyverse.org/reference/ggsave.html).                                                                                                                                                                                                                                                                               |

## Return

An [`ggplot2::ggplot`](https://ggplot2.tidyverse.org/) object containing the
plot for the validation procedure. The plot object returned can be further
modified and also contains the
[`patchwork`](https://patchwork.data-imaginist.com/) class applied. An example
of a validation plot is shown below.

<div class="showcase-image">
    <p>
        Sample Size Analysis Validation
    </p>
    <img src="/images/content/powerly-tutorial-introduction-example-validation.png" alt="Example of powerly output for sample size analysis validation">
</div>

## See Also

`S3` method [`summary`](/reference/method/summary) and function
[`validate`](/reference/function/validate).
