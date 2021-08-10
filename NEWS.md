# Coming changes
[x] Add function to validate the results of a sample size analysis.
[ ] Add tests for `Validation` class.
[ ] Add implementation for `summary` and `print` methods for the `Method` class.
[ ] Option to set seeds for the cluster via `parallel::setclusterSetRNGStream`
[ ] Document the `plot` method in `Method` class.
[ ] GitHub Actions workflow for automating various tasks.
[ ] Mechanism for performing replicable simulations using the method.
[ ] Mechanism for extending the package with new models, measures and statistics.
[ ] Tutorial for methodologists on how to extend the package.
[ ] UML structure of the package.
[ ] Package website using the `pkgdown` generator.
[ ] Generate the repository `README.md` file from `README.Rmd` using `knitr`.
[ ] Add automated build tags to repository `README.md`.

# Ideas to consider
[-] Bisectional algorithm for choosing an optimal starting range (i.e., not to wide, not to narrow)
[-] Switch to accelerated bootstrap CI in `StepThree` for better precision.
[-] Reuse Monte Carlo results from previous iterations if they fall within the updated range.
[-] Shiny application for running the method.

# Known bugs
[x] Too many `NA` values in the matrix of performance measures will result in bootstrapped vectors of
    statistics that have at least one `NaN` element. This will cause the
    `solver$solve_update(boot_statistics)` to fail (e.g., `NA/NaN/Inf in foreign function call (arg 2)`).

# Notes
[-] ...
