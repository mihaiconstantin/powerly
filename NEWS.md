# `powerly` `1.5.1`

## Bug fixes

* Updated preprint link in `powerly()` documentation to use the `\doi{}` syntax
  as indicated by CRAN member Uwe Ligges.

* Updated `DESCRIPTION` to start with capital letter as indicated by CRAN member
  Uwe Ligges.

* Fix typo in `DESCRIPTION`.

# `powerly` `1.5.0`

## Features

* Add preliminary `summary()` support for `Method` and `Validation` objects.

* Update citation and references to the preprint available at
  [psyarxiv.com/j5v7u](https://psyarxiv.com/j5v7u).

* Add `ggplot` plots and saving support for `StepOne`, `StepTwo`, `StepThree`
  and `Validation` objects.

## Improvements

* Migrate from `R` base plots to `ggplot2` and `patchwork`.

* Add more detailed `Description` in `DESCRIPTION` file as per comment by CRAN
  member Julia Haider.

## Bug fixes

* Fix seed in `StepOne` unit test.

* Fix superfluous test fail for `GGM` model estimation. Restricted the unit test
  to compare the estimated edge weights up to 7 digits precision.

# `powerly` `1.4.0`

## Features

* Add code coverage workflow based on action provided by
  `usethis::use_github_action("test-coverage")` and badge to `README.md`.

# `powerly` `1.3.0`

## Bug fixes

* Fix cluster creation bug in `Backend` when the machine had only 1 or 2 cores.
  The previous version would result in an error when the machine contained only
  1 or 2 cores. Now, when the machine has only 1 core, the cluster creation will
  fail, with a message that not enough cores are available. When the machine has
  2 cores, all 2 cores are used. In all other cases, the number of cores used is
  given by the number of cores on the machine minus one.

## Improvements

* Add names and comments to workflow file `R-CMD-check.yaml`.

* Update `README.md` and package startup logo to only show major version.

* Update existing tests and added new ones.

* Add type check for `method` argument of `validate()` to ensure that only
  instances of `Method` class (i.e., produced by `powerly()` are passed).

* Add `Backend` stopping to `on.exit()` in `powerly()` to ensure the cluster is
  stopped no matter the execution status of the function.

* Improve logic around setting and resetting the number of cores when the
  cluster is created and stopped (i.e., also for adopted clusters).

* Correct version number and add changes in `NEWS.md` for `1.2.0`.

# `powerly` `1.2.0`

## Features

* Add *CI* workflow via `usethis::use_github_action_check_standard()`.

## Bug fixes

* Restrict tests to using a maximum of two cores to respect CRAN restriction.

# Improvements

* Hide package logo at startup if the `R` session is not interactive.

* Add more informative changelogs to `NEWS.md` for previous releases.

# `powerly` `1.1.1`

## Bug fixes

* Add `.remove_missing()` to clear any `NA` values that may be present in
  `.measures` in `StepOne` class after the *Monte Carlo* procedure.

# `powerly` `1.1.1`

## Bug fixes

* Fix broken URLs in documentation causing build warnings.

# `powerly` `1.1.0`

## Features

* Add `validate()` public *API* to validate method results.

* Add `Validation` class to perform validation on a `Method` object.

## Improvements

* Add example in `README.md` for `validation()` and fixed images.

* Decrease legend font size in `StepThree` class.

* Rename from quantile to percentile in `StepThree` class plots.

# `powerly` `1.0.0`

* Add `powerly()` public *API* to run the method.

* Add `generate_model()` public *API* to generate true models.

* Add package documentation for public *API*.

* Add plotting for all three method steps.

* Add option to save last two iterations in `Method` class.

* Add `Method` class to run the method steps iteratively.

* Add parallel support for *Step 1* and *Step 3* of the method.

* Add `Backend` class to manage parallel clusters.

* Add support for multiple solvers for estimating spline coefficients.

* Rewrite prototype using `R6` *OOP* style into first stable release.

# `powerly` `0.2.0`

* Remove text feedback from each method step function.

# `powerly` `0.1.0`

* Fix bug cased by initial candidate sample size ranges being too narrow.

# `powerly` `0.1.0`

## Features

* Add preliminary support for the *Gaussian Graphical Model* via `ggm` object.

* Add preliminary support for two statistics via `statistic.power()` and
  `statistic.mean()`.

* Add `validate.recommendation()` prototype for validating a sample size
  recommendation.

* Add `run.method()` prototype for running all method steps iteratively.

* Add `run.step.1()` prototype for *Step 1* of the method.

* Add `run.step.2()` prototype for *Step 2* of the method.

* Add `run.step.3()` prototype for *Step 3* of the method.

---

# Planned changes

- Add tests for `Validation` class.
- Add implementation for `summary` and `print` methods for the `Method` class.
- Option to set seeds for the cluster via `parallel::setclusterSetRNGStream`
- Document the `plot` method in `Method` class.
- Mechanism for performing replicable simulations using the method.
- Mechanism for extending the package with new models, measures and statistics.
- Tutorial for methodologists on how to extend the package.
- Add *UML* class diagram to give an overview of the structure of the package.
- Add package website using the `pkgdown` generator.
- Switch to generating `README.md` file from `README.Rmd` via `knitr`.
- Change to `ggplot2` plots.

# Ideas to consider
- Bisectional algorithm for choosing an optimal starting range (i.e., not to
  wide, not to narrow)
- Switch to accelerated bootstrap CI in `StepThree` for better precision.
- Reuse Monte Carlo results from previous iterations if they fall within the
  updated range.
- Shiny application for running the method.

# Known bugs
- The percentile plot in `StepThree` results in misalignment between the dashed
  lines intersection point and the percentile function when the number of Monte
  Carlo replications is very large.
