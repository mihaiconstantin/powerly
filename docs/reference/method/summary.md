---
pageClass: page-reference
---

# Summarize Results

## Description

This function summarizes objects of class `Method` and `Validation`, providing
information about the method run and the sample size recommendation, as well as
the validation procedure.

## Usage

```r:no-line-numbers
summary(object, ...)
```

## Arguments

|   Name   | Description                                                                                                                                                            |
| :------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `object` | An object instance of class `Method` or `Validation` produced by the functions [`powerly`](/reference/function/powerly) or [`validate`](/reference/function/validate). |
|  `...`   | Other optional arguments currently not in use.                                                                                                                         |

## See Also

Functions [`powerly`](/reference/function/powerly) and
[`validate`](/reference/function/validate).

`S3` methods [`plot.Method`](/reference/method/plot-method) and
[`plot.Validation`](/reference/method/plot-validation).
