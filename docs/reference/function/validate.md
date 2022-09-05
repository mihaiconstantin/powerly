---
pageClass: page-reference
---

# Validate a Sample Size Analysis

## Description

This function can be used to validate the recommendation obtained from a sample
size analysis.

## Usage

```r:no-line-numbers
validate(
    method,
    replications = 3000,
    cores = NULL,
    backend_type = NULL,
    verbose = TRUE
)
```

## Arguments

|      Name      | Description                                                                                                                                                                                                                                                                                  |
| :------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|    `method`    | An object of class `Method` obtained by running the function [`powerly`](/reference/function/powerly).                                                                                                                                                                                       |
| `replications` | A single positive integer representing the number of Monte Carlo simulations to perform for the recommended sample size. The default is `1000`. Whenever possible, a value of `10000` should be preferred for a higher accuracy of the validation results.                                   |
|    `cores`     | A single positive positive integer representing the number of cores to use for running the validation in parallel, or `NULL`. If `NULL` (the default) the validation will run sequentially.                                                                                                  |
| `backend_type` | A character string indicating the type of cluster to create for running the validation in parallel, or `NULL`. Possible values are `"psock"` and `"fork"`. If `NULL` the backend is determined based on the computer architecture (i.e., `fork` for Unix and MacOS and `psock` for Windows). |
|   `verbose`    | A logical value indicating whether information about the status of the validation should be printed while running. The default is `TRUE`.                                                                                                                                                    |

## Details

The sample sizes used during the validation procedure is automatically extracted
from the `method` argument.

## Return

An [`R6::R6Class`](https://adv-r.hadley.nz/r6.html) instance of `Validation`
class that contains the results of the validation. Suppose the instance is
stored in a variable named `validation`, then specific fields of the
`Validation` class can be accessed as `validation$field`.

The following main fields can be accessed:
- `$sample`: The sample size used for the validation.
- `$measures`: The performance measures observed during validation.
- `$statistic`: The statistic computed on the performance measures.
- `$percentile_value`: The performance measure value at the desired percentile.
- `$validator`: An [`R6::R6Class`](https://adv-r.hadley.nz/r6.html) instance of
  `StepOne` class.

The `plot` [`S3` method](https://adv-r.hadley.nz/oo.html) can be called on the
return value to visualize the validation results (i.e., see the
[`plot.Validation`](/reference/method/plot-validation) method for more
information on how to plot the validation results), e.g.:

```r:no-line-numbers
# Plot validation results.
plot(validation)
```

## Examples

```r
# Perform a sample size analysis.
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

# Validate the recommendation obtained during the analysis.
validation <- validate(results, cores = 2)

# Plot the validation results.
plot(validation)

# To see a summary of the validation, we can use the `summary` S3 method.
summary(validation)
```

## See Also

Functions [`generate_model`](/reference/function/generate-model) and
[`powerly`](/reference/function/powerly).

`S3` methods [`plot.Validation`](/reference/method/plot-validation) and
[`summary`](/reference/method/summary).
