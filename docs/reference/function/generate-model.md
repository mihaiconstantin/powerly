---
pageClass: page-reference
---

# Generate True Model Parameters

## Description

Generate matrices of true model parameters for the supported true models. These
matrices are intended to passed to the `model_matrix` argument of the
[`powerly`](/reference/function/powerly) function.

## Usage

```r:no-line-numbers
generate_model(type, ...)
```

## Arguments

|  Name  | Description                                                                                                                                                                                                  |
| :----: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `type` | Character string representing the type of true model. See the [**_True Models_**](/reference/function/generate-model.md#true-models) section for possible values.                                            |
| `...`  | Required arguments used for the generation of the true model. See the [**_True Models_**](/reference/function/generate-model.md#true-models) section for the arguments required for each type of true model. |

## Return

A matrix containing the model parameters.

## True Models

### Gaussian Graphical Model

**Type:** `ggm`

**`...` arguments:**

|    Name    | Description                                                                                                                                             |
| :--------: | :------------------------------------------------------------------------------------------------------------------------------------------------------ |
|  `nodes`   | A single positive integer representing the number of nodes in the network (e.g., `10`).                                                                 |
| `density`  | A single numerical value indicating the density of the network (e.g., `0.4`).                                                                           |
| `positive` | A single numerical value representing the proportion of positive edges in the network (e.g., `0.9` for $90\%$ positive edges).                          |
|  `range`   | A length two numerical value indicating the uniform interval from where to sample values for the partial correlations coefficients (e.g., `c(0.5, 1)`). |
| `constant` | A single numerical value representing the constant described by [Yin and Li (2011)](https://doi.org/10.1214%2F11-AOAS494).                              |

_**Note.** For more information see the arguments of the
[`genGGM`](https://rdrr.io/cran/bootnet/man/genGGM.html) function in the
[`bootnet`](https://CRAN.R-project.org/package=bootnet) package._

**Compatible performance measures:**

- `sen` (sensitivity)
- `spe` (specificity)
- `mcc` (Matthews correlation)
- `rho` (Pearson correlation)

See the [**_Performance
Measures_**](/reference/function/powerly.md#performance-measures) section for
the [`powerly`](/reference/function/powerly) function for more information on
the compatible performance measures.

**Examples**

The example below shows how to generate a true network model based on a random
architecture ([Barabási & Albert,
1999](https://doi.org/10.1126/science.286.5439.509)) with $10$ nodes, $90\%$
positive edge weights, and an edge density of $0.4$.

```r
# Generate true model.
true_model <- generate_model(
    type = "ggm",
    nodes = 10,
    density = 0.4,
    positive = 0.9
)

# Load the `qgraph` package.
library(qgraph)

# Plot the model.
qgraph(true_model)
```

## See Also

Functions [`powerly`](/reference/function/powerly) and
[`validate`](/reference/function/validate).

## References

<div class="references">

Barabási, A.-L., & Albert, R. (1999). Emergence of Scaling in Random Networks.
*Science*, 286(5439), 509–512.
[https://doi.org/10.1126/science.286.5439.509](https://doi.org/10.1126/science.286.5439.509)


Yin, J., & Li, H. (2011). A sparse conditional Gaussian graphical model for
analysis of genetical genomics data. *The Annals of Applied Statistics*, 5(4),
2630–2650. [https://doi.org/10.1214/11-AOAS494](https://doi.org/10.1214/11-AOAS494)

</div>
