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
footer: Made with &#10084;&#65039; by <a href="https://mihaiconstantin.com" target="_blank">Mihai Constantin</a><br><div class="license">MIT licensed</div>
footerHtml: true
pageClass: page-home
---

<div class="main-text">
<div class="main-text-content">

`powerly` is an `R` package that implements the method by [Constantin et al.
(2021)](https://psyarxiv.com/j5v7u) for conducting sample size analysis for
cross-sectional network models. The implementation takes the form of a
three-step recursive algorithm designed to find an optimal sample size given a
model specification and an outcome measure of interest. It starts with a Monte
Carlo simulation step for computing the outcome at various sample sizes. It
continues with a monotone curve-fitting step for interpolating the outcome. The
final step employs stratified bootstrapping to quantify the uncertainty around
the fitted curve. For more details, consult the
[manuscript](https://psyarxiv.com/j5v7u) or check out the [tutorial](/tutorial/)
section.


</div>
</div>

<!-- Steps. -->
<div class="features">
    <!-- Step 1. -->
    <div class="feature">
        <h2>Step 1</h2>
        <p>
            <img src="/images/steps/example-step-1.png" alt="Step 1">
        </p>
    </div>
    <!-- Step 2. -->
    <div class="feature">
        <h2>Step 2</h2>
        <p>
            <img src="/images/steps/example-step-2.png" alt="Step 2">
        </p>
    </div>
    <!-- Step 3. -->
    <div class="feature">
        <h2>Step 3</h2>
        <p>
            <img src="/images/steps/example-step-3.png" alt="Step 3">
        </p>
    </div>
</div>
