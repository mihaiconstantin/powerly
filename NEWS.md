# Changelog
All notable changes to this project will be documented in this file. The format
is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.7.4] - 2022-04-30
### Added
- Add `duration` field to `StepTwo` class to record the execution time for the
  spline fitting procedure
- Add `CNAME` for apex domain `https://powerly.dev` served via GitHub Pages.

### Fixed
- Fix missing import for `mvnorm` package (#11). Closes #5.
- Fix missing number of `cores` in `Backend` when more cores than available were
  requested (#12). Closes #2.
- Fix legend overlapping spline confidence bands for `StepThree` plot (#13).
  Closes #3.
- Fix recording and reporting of `Method` and step classes execution time (#15).
  The duration is now recorded in seconds. Closes #9.

### Removed
- Remove `dev` branch from all `GitHub` workflows (#14). Switched to the
  `GitHub` flow. Closes #4.

## [1.7.3]
#### Changed
- Update badges order in `README.md` and removed open issues badge.

#### Fixed
- Fix typos in `NEWS` file.

## [1.7.2]
### Added
- Add GitHub badges with latest release version and number of open issues.

### Changed
- Update GGM estimation test to check if the estimation fails when variables
  with zero standard deviation are present in the generated data.
- Update GGM estimation to fail when the generated data contains at least one
  variable that has a standard deviation equal to zero (i.e., as a result of
  generating data with a sample size value that is too low).

### Fixed
- Add tolerance (i.e., `0.0000001`) for test checking whether the spline
  coefficients are estimated correctly.
- Fix test for the updating of the bounds of a `Range` instance to run only when
  the the 2.5th and 97.5th selected sample sizes are different quantities.
- Fix bug in GGM data generating test where the number of nodes to generate data
  for were incorrectly sampled.

## [1.7.1]
### Changed
- Update moved URL https://codecov.io/gh/mihaiconstantin/powerly to
  https://app.codecov.io/gh/mihaiconstantin/powerly based on comments of CRAN
  maintainer Uwe Ligges.

## [1.7.0]
### Added
- Add `summary` S3 method support for `Validation` class objects.

### Changed
- Add new `R` version to the CI pipeline for the `R CMD check` job.
- Update `R CMD check` workflow to use `check` action from `r-lib/actions`.
- Add explicit `.data` and `.env` pronoun calls (i.e., from the `rlang` package)
  to variables used inside data-masking function (e.g., `ggplot2::aes()`) to
  avoid `CRAN` notes regarding missing bindings for global variables. See this
  question for more information: https://stackoverflow.com/q/9439256/5252007.
- Update plot functions to respect the signature of the S3 plot generic.
- Improve documentation and positioning of figures in the help pages.
- Create `roxygen2` templates for documenting the public API and S3 methods.
- Extract `plot()` methods from `R6` classes into standalone S3 methods.
- Update package start-up logo with message to welcome and encourage users to
  submit ideas for improving the package.
- Extend CI workflow to include branch `dev`.

### Fixed
- Fix backend test where the cluster would contain an unexpected `.Random.seed`.
  The `.Random.seed` is caused by loading the `bootnet` package which in turn
  loads the `snow` package. The `snow` package uses the `RNG` within the
  `.onLoad()` function to draw from the uniform distribution and set a port
  number. The result of this operation is a `.Random.seed` in the `.GlobalEnv`.
  For more information see: https://stackoverflow.com/q/69866215/5252007 and
  https://github.com/SachaEpskamp/bootnet/issues/82.
- Fix preprint URL in package documentation.
- Fix heading typo in news file.

## [1.6.1]
### Changed
- Update line exclusions for `covr::codecov()`.

## [1.6.0]
### Changed
- Add new `Validation` class plot to `README.md` file.
- Update `GgmModel` tests to vary various model estimation and data generation
  parameters.
- Update `testthat::expect_equal` to test with a tolerance of `1e-6` for `Basis`
  and `Solver`.
- Replace own `GgmModel` estimation with `qgraph::EBICglasso()`.
- Add ECDF plot to `Validation` class.
- Import external functions to `NAMESPACE` via `Roxygen2`.
- Add more cool badges to `README.md` (e.g., CRAN version and check status).
- Fix missing missing period in package description in `DESCRIPTION` file.

### Fixed
- Fix issue where `GGM` estimation test would fail due to a precision level set
  too high.

## [1.5.2]
### Fixed
- Update `Description` field in `DESCRIPTION` file to follow CRAN guidelines.

## [1.5.1]
### Fixed
- Update preprint link in `powerly()` documentation to use the `\doi{}` syntax
  as indicated by CRAN member Uwe Ligges.
- Update `DESCRIPTION` to start with capital letter as indicated by CRAN member
  Uwe Ligges.
- Fix typo in `DESCRIPTION`.

## [1.5.0]
### Added
- Add preliminary `summary()` support for `Method` and `Validation` objects.
- Update citation and references to the preprint available at
  [psyarxiv.com/j5v7u](https://psyarxiv.com/j5v7u).
- Add `ggplot` plots and saving support for `StepOne`, `StepTwo`, `StepThree`
  and `Validation` objects.

### Changed
- Migrate from `R` base plots to `ggplot2` and `patchwork`.
- Add more detailed `Description` in `DESCRIPTION` file as per comment by CRAN
  member Julia Haider.

### Fixed
- Fix seed in `StepOne` unit test.
- Fix superfluous test fail for `GGM` model estimation. Restricted the unit test
  to compare the estimated edge weights up to 7 digits precision.

## [1.4.0]
### Added
- Add code coverage workflow based on action provided by
  `usethis::use_github_action("test-coverage")` and badge to `README.md`.

## [1.3.0]
### Fixed
- Fix cluster creation bug in `Backend` when the machine had only 1 or 2 cores.
  The previous version would result in an error when the machine contained only
  1 or 2 cores. Now, when the machine has only 1 core, the cluster creation will
  fail, with a message that not enough cores are available. When the machine has
  2 cores, all 2 cores are used. In all other cases, the number of cores used is
  given by the number of cores on the machine minus one.

### Changed
- Add names and comments to workflow file `R-CMD-check.yaml`.
- Update `README.md` and package startup logo to only show major version.
- Update existing tests and added new ones.
- Add type check for `method` argument of `validate()` to ensure that only
  instances of `Method` class (i.e., produced by `powerly()` are passed).
- Add `Backend` stopping to `on.exit()` in `powerly()` to ensure the cluster is
  stopped no matter the execution status of the function.
- Improve logic around setting and resetting the number of cores when the
  cluster is created and stopped (i.e., also for adopted clusters).
- Correct version number and add changes in `NEWS.md` for `1.2.0`.

## [1.2.0]
### Added
- Add *CI* workflow via `usethis::use_github_action_check_standard()`.

### Fixed
- Restrict tests to using a maximum of two cores to respect CRAN restriction.

### Changed
- Hide package logo at startup if the `R` session is not interactive.
- Add more informative changelogs to `NEWS.md` for previous releases.

## [1.1.1]
### Fixed
- Add `.remove_missing()` to clear any `NA` values that may be present in
  `.measures` in `StepOne` class after the *Monte Carlo* procedure.

## [1.1.1]
### Fixed
- Fix broken URLs in documentation causing build warnings.

## [1.1.0]
### Added
- Add `validate()` public *API* to validate method results.
- Add `Validation` class to perform validation on a `Method` object.

### Changed
- Add example in `README.md` for `validation()` and fixed images.
- Decrease legend font size in `StepThree` class.
- Rename from quantile to percentile in `StepThree` class plots.

## [1.0.0]
### Added
- Add `powerly()` public *API* to run the method.
- Add `generate_model()` public *API* to generate true models.
- Add package documentation for public *API*.
- Add plotting for all three method steps.
- Add option to save last two iterations in `Method` class.
- Add `Method` class to run the method steps iteratively.
- Add parallel support for *Step 1* and *Step 3* of the method.
- Add `Backend` class to manage parallel clusters.
- Add support for multiple solvers for estimating spline coefficients.
- Rewrite prototype using `R6` *OOP* style into first stable release.

## [0.2.0]
### Removed
- Remove text feedback from each method step function.

## [0.1.1]
### Fixed
- Fix bug cased by initial candidate sample size ranges being too narrow.

## [0.1.0]
### Added
- Add preliminary support for the *Gaussian Graphical Model* via `ggm` object.
- Add preliminary support for two statistics via `statistic.power()` and
  `statistic.mean()`.
- Add `validate.recommendation()` prototype for validating a sample size
  recommendation.
- Add `run.method()` prototype for running all method steps iteratively.
- Add `run.step.1()` prototype for *Step 1* of the method.
- Add `run.step.2()` prototype for *Step 2* of the method.
- Add `run.step.3()` prototype for *Step 3* of the method.

---

# Planned changes and ideas to consider

- Add tests for `Validation` class.
- Option to set seeds for the cluster via `parallel::setclusterSetRNGStream`
- Mechanism for performing replicable simulations using the method.
- Mechanism for extending the package with new models, measures and statistics.
- Tutorial for methodologists on how to extend the package.
- Tutorial to demonstrate how the internal API of the package can be used.
- Add *UML* class diagram to give an overview of the structure of the package.
- Add package website using the `pkgdown` generator.
- Switch to generating `README.md` file from `README.Rmd` via `knitr`.
- Bisectional algorithm for choosing an optimal starting range (i.e., not too
  wide, not too narrow).
- Switch to accelerated bootstrap CI in `StepThree` for better precision.
- Reuse Monte Carlo results from previous iterations if they fall within the
  updated range.
- Shiny application for running the method.
- Allow rerunning the validation procedure with a custom sample size.
    - If multiple custom sample sizes are used during the validation, then
      switch from the histogram to a violin plot.
