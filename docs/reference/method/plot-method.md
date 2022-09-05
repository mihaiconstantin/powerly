---
pageClass: page-reference
---

# Plot Method Results

## Description

The `plot.Method` [`S3` method](https://adv-r.hadley.nz/oo.html) plot the
results for each step of the method.

## Usage

```r:no-line-numbers
plot(
    x,
    step = 3,
    last = TRUE,
    save = FALSE,
    path = NULL,
    width = 14,
    height = 10,
    ...
)
```

## Arguments

|   Name   | Description                                                                                                                                                                                                                                                                                                                                                                                |
| :------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|   `x`    | An object instance of class `Method` produced by the function [`powerly`](/reference/function/powerly).                                                                                                                                                                                                                                                                                    |
|  `step`  | A single positive integer representing the method step that should be plotted. Possibles values are `1` for the first step, `2` for the second step, and `3` for the third step of the method.                                                                                                                                                                                             |
|  `last`  | A logical value indicating whether the last iteration of the method should be plotted. The default is `TRUE`, indicating that the last iteration should be plotted.                                                                                                                                                                                                                        |
|  `save`  | A logical value indicating whether the plot should be saved to a file on disk.                                                                                                                                                                                                                                                                                                             |
|  `path`  | A character string representing the path (i.e., including the filename and extension) where the plot should be saved on disk. If `NULL`, the plot will be saved in the current working directory with a filename generated based on the current system time and a `.pdf` extension. See [`ggplot2::ggsave`](https://ggplot2.tidyverse.org/reference/ggsave.html) for supported file types. |
| `width`  | A single numerical value representing the desired plot width. The default unit is inches (i.e., set by [`ggplot2::ggsave`](https://ggplot2.tidyverse.org/reference/ggsave.html)), unless overridden by providing the `units` argument via `...`.                                                                                                                                           |
| `height` | A single numerical value representing the desired plot height. The default unit is inches (i.e., set by [`ggplot2::ggsave`](https://ggplot2.tidyverse.org/reference/ggsave.html)), unless overridden by providing the `units` argument via `...`.                                                                                                                                          |
|  `...`   | Optional arguments to be passed to the [`ggplot2::ggsave`](https://ggplot2.tidyverse.org/reference/ggsave.html) function.                                                                                                                                                                                                                                                                  |

## Return

An [`ggplot2::ggplot`](https://ggplot2.tidyverse.org/) object containing the
plot for the requested step of the method. The plot object returned can be
further modified and also contains the
[`patchwork`](https://patchwork.data-imaginist.com/) class applied. Example
plots for each step of the method are shown below.

<div class="showcase-image">
    <p>
        Step 1: Monte Carlo Replications
    </p>
    <img src="/images/content/powerly-feature-step-1.png" alt="Example of powerly output for Step 1">
</div>

<div class="showcase-image">
    <p>
        Step 2: Curve Fitting
    </p>
    <img src="/images/content/powerly-feature-step-2.png" alt="Example of powerly output for Step 2">
</div>

<div class="showcase-image">
    <p>
        Step 3: Bootstrapping
    </p>
    <img src="/images/content/powerly-feature-step-3.png" alt="Example of powerly output for Step 3">
</div>

## See Also

`S3` method [`summary`](/reference/method/summary) and function
[`powerly`](/reference/function/powerly).
