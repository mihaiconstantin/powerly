---
title: Welcome
home: true
heroImage: /images/logos/powerly-logo.png
heroAlt: Sample Size Analysis Tools
heroText: powerly
tagline: Sample Size Analysis for Psychological Networks ...and more
actions:
  - text: Get Started
    link: /tutorial/
    type: primary
  - text: Reference
    link: /reference/
    type: secondary
footer: Made with <span class="heart">&#9829;</span> by <a href="https://mihaiconstantin.com" target="_blank">Mihai Constantin</a><br><div class="license">MIT licensed</div>
footerHtml: true
pageClass: page-home
---

<div class="main-text">

<div class="repo-badges">
    <a href="https://www.repostatus.org/#active"><img src="https://www.repostatus.org/badges/latest/active.svg" alt="Repository status"/></a>
    <a href="https://github.com/mihaiconstantin/powerly/releases"><img src="https://img.shields.io/github/v/release/mihaiconstantin/powerly?display_name=tag&sort=semver"/></a>
    <a href="https://www.r-pkg.org/pkg/powerly"><img src="https://www.r-pkg.org/badges/version/powerly" alt="CRAN version"/></a>
    <a href="https://www.r-pkg.org/pkg/powerly"><img src="https://cranlogs.r-pkg.org/badges/grand-total/powerly" alt="CRAN RStudio mirror downloads"/></a>
    <a href="https://app.codecov.io/gh/mihaiconstantin/powerly"><img src="https://codecov.io/gh/mihaiconstantin/powerly/branch/main/graph/badge.svg?token=YUCO8ULBCM" alt="Code coverage"/></a>
    <a href="https://github.com/mihaiconstantin/powerly/actions"><img src="https://github.com/mihaiconstantin/powerly/workflows/R-CMD-check/badge.svg" alt="R-CMD-check" /></a>
    <a href="https://cranchecks.info/pkgs/powerly"><img src="https://cranchecks.info/badges/worst/powerly" alt="CRAN checks"/></a>
</div>

<div class="main-text-content">

`powerly` is an `R` package for conducting sample size analysis that implements
the method by [Constantin et al. (2021)](https://psyarxiv.com/j5v7u). The
implementation takes the form of a three-step recursive algorithm designed to
find an optimal sample size given a model specification and an outcome measure
of interest. It starts with a Monte Carlo simulation step for computing the
outcome at various sample sizes. It continues with a monotone curve-fitting step
for interpolating the outcome. The final step employs stratified bootstrapping
to quantify the uncertainty around the fitted curve. For more details, consult
the [manuscript](https://psyarxiv.com/j5v7u) or check out the
[tutorial](/tutorial/) section.

</div>
</div>

<!-- Steps. -->
<div class="features">
    <!-- Step 1. -->
    <div class="feature">
        <h2>Step 1</h2>
        <p>
            <img src="/images/content/powerly-feature-step-1.png" alt="powerly Step 1">
        </p>
    </div>
    <!-- Step 2. -->
    <div class="feature">
        <h2>Step 2</h2>
        <p>
            <img src="/images/content/powerly-tutorial-method-step-2-spline.png" alt="powerly Step 2">
        </p>
    </div>
    <!-- Step 3. -->
    <div class="feature">
        <h2>Step 3</h2>
        <p>
            <img src="/images/content/powerly-tutorial-method-step-3-confidence-intervals-histogram.png" alt="powerly Step 3">
        </p>
    </div>
</div>
