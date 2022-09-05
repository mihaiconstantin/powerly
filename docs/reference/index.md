---
pageClass: page-reference
---

# Reference

In this section you can find information about the functions and methods
available in the `powerly` package. The information in this section is grouped
in two categories, namely, *functions* and *methods*.

## Functions

This category refers to the user exported functions, i.e., the functions that
encapsulate the functionality provided by `powerly` (e.g., running a sample size
analysis). The following functions are currently available and documented:

- [`generate_model`](/reference/function/generate-model): for generating true
  model parameters
- [`powerly`](/reference/function/powerly): for running a sample size analysis
- [`validate`](/reference/function/validate): for validating the results of a
  sample size analysis

## Methods

Methods (i.e., [`S3`](https://adv-r.hadley.nz/oo.html)) refer to built-in `R`
functions that can operate on the output provided by the functions exported by
the `powerly` package. Two types of [`S3`
methods](https://adv-r.hadley.nz/oo.html) are currently implemented, i.e.,
`plot` and `summary`:

- [`plot.Method`](/reference/method/plot-method): for plotting the results of a
  sample size analysis
- [`plot.Validation`](/reference/method/plot-validation): for plotting the
  results of a sample size analysis validation
- [`summary`](/reference/method/summary): for summarizing the results of a
  sample size analysis or validation
