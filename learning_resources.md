---
title: Welcome to the hmer package website!
---

<div class="navbar">
  <a href="index.html">Home</a>
  <a href="learning_resources.html"  class="active">Learning resources</a>
  <a href="24may2022workshop.html">Workshops</a>
  <a href="papers.html">Research papers</a>
</div>

<br>

<br>

<br>

In this section you will find some resources on the history matching with emulation (HME) framework, and how to implement the method using the hmer package.

## Resources on HME 

The resources below can be addressed independently of each other:

- [An introduction to HME](https://danny-sc.github.io/Tutorial_1/): a short tutorial which demonstrates the main concepts of HME using a simple one-dimensional example.

- [Bayes Linear Emulation and History Matching](https://www.youtube.com/watch?v=54G_aYHGdAk): a presentation on the HME methodology by Ian Vernon.

## Resources on _hmer_ 

The _hmer_ package is available on CRAN, together with a [reference manual](https://cran.r-project.org/web/packages/hmer/hmer.pdf) and four vignettes:
- an [introduction](https://cran.r-project.org/web/packages/hmer/vignettes/demonstrating-the-hmer-package.html) to the main functionality of the package;
- a [vignette](https://cran.r-project.org/web/packages/hmer/vignettes/low-dimensional-examples.html) showing how to use the package with one and two-dimensional models;
- a [vignette](https://cran.r-project.org/web/packages/hmer/vignettes/stochasticandbimodalemulation.html) on the calibration of stochastic and bimodal models;
- a [history matching with emulation handbook], which presents some of the issues that arise most frequently in emulation and history matching and explains how to circumvent them;

In addition to those resources, we created the following tutorials, meant to be addressed in the proposed ordered:

1. [Deterministic tutorial](https://danny-sc.github.io/Tutorial_2/): a general introduction to _hmer_'s functionalities for the calibration of deterministic models.

2. [Deterministic practical tutorial](https://danny-sc.github.io/determ_workshop/): a practical, interactive introduction to _hmer_'s functionalities for the calibration of deterministic models. You can work through this practical tutorial by running the [R script without solutions](https://github.com/hmer-package/website/blob/gh-pages/determ_workshop_code_without_sols.R) line by line. Note that the tutorial has tasks that require you to write your own code. Solutions to these tasks can be found both in the html file and in the [R script with solutions](https://github.com/hmer-package/website/blob/gh-pages/determ_workshop_code_with_sols.R).

3. Stochastic practical tutorial: a practical introduction to _hmer_'s functionalities for the calibration of models presenting stochasticity and/or bimodality.

## Template to set up HME on your model 
This repository contains an R-script [Template_hmer_script](https://raw.githubusercontent.com/hmer-package/website/gh-pages/Template_hmer_script.R) that will guide you through setting up history matching with emulation on your model of interest.
