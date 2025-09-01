---
pageClass: page-reference
---

# Perform Sample Size Analysis

## Description

Run an iterative three-step Monte Carlo method and return the sample sizes
required to obtain a certain value for a performance measure of interest (e.g.,
sensitivity) given a set of hypothesized true model parameters (e.g., an edge
weights matrix).

## Usage

```r:no-line-numbers
powerly(
    range_lower,
    range_upper,
    samples = 30,
    replications = 30,
    model = "ggm",
    ...,
    model_matrix = NULL,
    measure = "sen",
    statistic = "power",
    measure_value = 0.6,
    statistic_value = 0.8,
    monotone = TRUE,
    increasing = TRUE,
    spline_df = NULL,
    solver_type = "quadprog",
    boots = 10000,
    lower_ci = 0.025,
    upper_ci = 0.975,
    tolerance = 50,
    iterations = 10,
    cores = NULL,
    cluster_type = NULL,
    save_memory = FALSE,
    verbose = TRUE
)
```

## Arguments

|       Name        | Description                                                                                                                                                                                                                                                                                                                                                                                                                |
| :---------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|   `range_lower`   | A single positive integer representing the lower bound of the candidate sample size range.                                                                                                                                                                                                                                                                                                                                 |
|   `range_upper`   | A single positive integer representing the upper bound of the candidate sample size range.                                                                                                                                                                                                                                                                                                                                 |
|     `samples`     | A single positive integer representing the number of sample sizes to select from the candidate sample size range.                                                                                                                                                                                                                                                                                                          |
|  `replications`   | A single positive integer representing the number of Monte Carlo replications to perform for each sample size selected from the candidate range.                                                                                                                                                                                                                                                                           |
|      `model`      | A character string representing the type of true model to find a sample size for. See the [**_True Models_**](/reference/function/generate-model.md#true-models) section for the function [`generate_model`](/reference/function/generate-model) for possible values. Defaults to `"ggm"`.                                                                                                                                 |
|       `...`       | Required arguments used for the generation of the true model. See the [**_True Models_**](/reference/function/generate-model.md#true-models) section for the function [`generate_model`](/reference/function/generate-model) for the arguments required for each true model.                                                                                                                                               |
|  `model_matrix`   | A square matrix representing the true model. See the [**_True Models_**](/reference/function/generate-model.md#true-models) section for the function [`generate_model`](/reference/function/generate-model) for what this matrix should look like depending on the true model selected.                                                                                                                                    |
|     `measure`     | A character string representing the type of performance measure of interest. Possible values are `"sen"` (i.e., sensitivity; the default), `"spe"` (i.e., specificity), `"mcc"` (i.e., Matthews correlation), and `"rho"` (i.e., Pearson correlation). See the [**_Performance Measures_**](/reference/function/powerly.md#performance-measures) section for the measures available for each type of true model supported. |
|    `statistic`    | A character string representing the type of statistic to be computed on the values obtained for the performance measures. Possible values are `"power"` (the default).                                                                                                                                                                                                                                                     |
|  `measure_value`  | A single numerical value representing the desired value for the performance measure of interest. The default is `0.6` (i.e., for the `measure = "sen"`). See the [**_Performance Measures_**](/reference/function/powerly.md#performance-measures) section for the range of values allowed for each performance measure.                                                                                                   |
| `statistic_value` | A single numerical value representing the desired value for the statistic of interest. The default is `0.8` (i.e., for the `statistic = "power"`). See the [**_Statistics_**](/reference/function/powerly.md#statistics) section for the range of values allowed for each statistic.                                                                                                                                       |
|    `monotone`     | A logical value indicating whether a monotonicity assumption should be placed on the values of the performance measure. The default is `TRUE` meaning that the performance measure changes as a function of sample size (i.e., either by increasing or decreasing as the sample size goes up). The alternative `FALSE` indicates that the performance measure it is not assumed to change as a function a sample size.     |
|   `increasing`    | A logical value indicating whether the performance measure is assumed to follow a non-increasing or non-decreasing trend. `TRUE` (the default) indicates a non-decreasing trend (i.e., the performance measure increases as the sample size goes up). `FALSE` indicates a non-increasing trend (i.e., the performance measure decreases as the sample size goes up).                                                       |
|    `spline_df`    | A vector of positive integers representing the degrees of freedom considered for constructing the spline basis, or `NULL`. The best degree of freedom is selected based on Leave One Out Cross-Validation. If `NULL` (the default) is provided, a vector of degrees of freedom is automatically created with all integers between `3` and `20`.                                                                            |
|   `solver_type`   | A character string representing the type of the quadratic solver used for estimating the spline coefficients. Currently only `"quadprog"` (the default) is supported.                                                                                                                                                                                                                                                      |
|      `boots`      | A positive integer representing the number of bootstrap runs to perform on the matrix of performance measures in order to obtained bootstrapped values for the statistic of interest. The default is `10000`.                                                                                                                                                                                                              |
|    `lower_ci`     | A single numerical value indicating the lower bound for the confidence interval to be computed on the bootstrapped statistics. The default is `0.025` (i.e., $2.5\%$).                                                                                                                                                                                                                                                     |
|    `upper_ci`     | A single numerical value indicating the upper bound for the confidence to be computed on the bootstrapped statistics. The default is `0.975` (i.e., $97.5\%$).                                                                                                                                                                                                                                                             |
|    `tolerance`    | A single positive integer representing the width at the candidate sample size range at which the algorithm is considered to have converge. The default is `50`, meaning that the algorithm will stop running when the difference between the upper and the lower bound of the candidate range shrinks to $50$ sample sizes.                                                                                                |
|   `iterations`    | A single positive integer representing the number of iterations the algorithm is allowed to run. The default is `10`.                                                                                                                                                                                                                                                                                                      |
|      `cores`      | A single positive positive integer representing the number of cores to use for running the algorithm in parallel, or `NULL`. If `NULL` (the default) the algorithm will run sequentially.                                                                                                                                                                                                                                  |
|  `cluster_type`   | A character string indicating the type of cluster to create for running the algorithm in parallel, or `NULL`. Possible values are `"psock"` and `"fork"`. If `NULL` the backend is determined based on the computer architecture (i.e., `fork` for Unix and MacOS and `psock` for Windows).                                                                                                                                |
|   `save_memory`   | A logical value indicating whether to save memory by only storing the results for the last iteration of the method. The default `TRUE` indicates that only the last iteration should be saved.                                                                                                                                                                                                                             |
|     `verbose`     | A logical value indicating whether information about the status of the algorithm should be printed while running. The default is `TRUE`.                                                                                                                                                                                                                                                                                   |

## Details

This function represents the implementation of the method introduced by
[Constantin et al. (2023)](https://doi.org/10.1037/met0000555) for performing a
priori sample size analysis (i.e., currently in the context of network models).
The method takes the form of a three-step recursive algorithm designed to find
an optimal sample size value given a model specification and an outcome measure
of interest (e.g., sensitivity). It starts with a Monte Carlo simulation step
for computing the outcome of interest at various sample sizes. It continues with
a monotone non-decreasing curve-fitting step for interpolating the outcome. The
final step employs a stratified bootstrapping scheme to account for the
uncertainty around the recommendation provided. The method runs the three steps
iteratively until the candidate sample size range used for the search shrinks
below a specified value.

## Return

An [`R6::R6Class`](https://adv-r.hadley.nz/r6.html) instance of `Method` class
that contains the results for each step of the method for the last and previous
iterations. Suppose that the output of the `powerly` function is stored in an
`R` object called `results`. Specific fields of the `Method` class can be
accessed from the instance `results` as `results$field`.

The following main fields can be accessed:
- `$duration`: The time in seconds elapsed during the method run.
- `$iteration`: The number of iterations performed.
- `$converged`: Whether the method converged.
- `$previous`: The results during the previous iteration.
- `$range`: The candidate sample size range.
- `$step_1`: The results for *Step 1*.
- `$step_2`: The results for *Step 2*.
- `$step_3`: The results for *Step 3*.
- `$recommendation`: The sample size recommendation(s).

The `plot` [`S3` method](https://adv-r.hadley.nz/oo.html) can be called on the
return value to visualize the results. See the method
[`plot.Method`](/reference/method/plot-method) for more information on how to
plot the method results. Briefly, the results for each individual step can be
plotted as:

```r:no-line-numbers
# For Step 1.
plot(results, step = 1)

# For Step 2.
plot(results, step = 2)

# For Step 3.
plot(results, step = 3)
```

## Performance Measures

| Performance Measure  | Symbol |   Lower |  Upper | Compatible Models |
| :------------------- | :----: | ------: | -----: | :---------------: |
| Sensitivity          | `sen`  |  `0.00` | `1.00` |       `ggm`       |
| Specificity          | `spe`  |  `0.00` | `1.00` |       `ggm`       |
| Matthews correlation | `mcc`  | `-1.00` | `1.00` |       `ggm`       |
| Pearson correlation  | `rho`  | `-1.00` | `1.00` |       `ggm`       |

See the [**_True Models_**](/reference/function/generate-model.md#true-models)
section for the [`generate_model`](/reference/function/generate-model) function
for more information on the compatible true models.

## Statistics

| Statistic | Symbol  |  Lower |  Upper |
| :-------- | :-----: | -----: | -----: |
| Power     | `power` | `0.00` | `1.00` |

## Examples

```r
# Suppose we want to find the sample size for observing a sensitivity of `0.6`
# with a probability of `0.8`, for a GGM true model consisting of `10` nodes
# with an edge density of `0.4`.

# We can run the method for an arbitrarily generated true model that matches
# those characteristics (i.e., number of nodes and edge density).
results <- powerly(
    range_lower = 300,
    range_upper = 1000,
    samples = 40,
    replications = 40,
    measure = "sen",
    statistic = "power",
    measure_value = .6,
    statistic_value = .8,
    model = "ggm",
    nodes = 10,
    density = .4,
    cores = 4,
    verbose = TRUE
)

# Or we omit the `nodes` and `density` arguments and specify directly the edge
# weights matrix via the `model_matrix` argument.

# To get a matrix of edge weights we can use the `generate_model()` function.
true_model <- generate_model(type = "ggm", nodes = 10, density = .4)

# Then, supply the true model to the algorithm directly.
results <- powerly(
    range_lower = 300,
    range_upper = 1000,
    samples = 40,
    replications = 40,
    measure = "sen",
    statistic = "power",
    measure_value = .6,
    statistic_value = .8,
    model = "ggm",
    model_matrix = true_model, # Note the change.
    cores = 4,
    verbose = TRUE
)

# To visualize the results, we can use the `plot` S3 method and indicate the
# step that we want to plot.
plot(results, step = 1)
plot(results, step = 2)
plot(results, step = 3)

# To see a summary of the results, we can use the `summary` S3 method.
summary(results)
```

## See Also

Functions [`generate_model`](/reference/function/generate-model) and
[`validate`](/reference/function/validate).

`S3` methods [`plot.Method`](/reference/method/plot-method) and
[`summary`](/reference/method/summary).

## Requests

If you would like to support a new model, performance measure, or statistic,
please open a pull request on GitHub at
[github.com/mihaiconstantin/powerly/pulls](https://github.com/mihaiconstantin/powerly/pulls).

To request a new model, performance measure, or statistic, please submit your
request at
[github.com/mihaiconstantin/powerly/issues](https://github.com/mihaiconstantin/powerly/issues).
If possible, please also include references discussing the topics you are
requesting. Alternatively, you can get in touch at `mihai at mihaiconstantin dot
com`.

## References

<div class="references">

Constantin, M. A., Schuurman, N. K., & Vermunt, J. K. (2023). A General Monte
Carlo Method for Sample Size Analysis in the Context of Network Models.
_Psychological Methods_.
[https://doi.org/10.1037/met0000555](https://doi.org/10.1037/met0000555)

</div>
