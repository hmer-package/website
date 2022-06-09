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

In this section you will find some resources on the history matching with emulation (HME) framework, and how to implement the method using the hmer package.

## Resources on HME 

The resources below can be addressed independently of each other:

- [An introduction to HME](https://danny-sc.github.io/Tutorial_1/): a short tutorial which demonstrates the main concepts of HME using a simple one-dimensional example.

- [Bayes Linear Emulation and History Matching](https://www.youtube.com/watch?v=54G_aYHGdAk): a presentation on the HME methodology by Ian Vernon.

## Resources on _hmer_ 

In addition to the package reference manual and the package vignettes (which can be found [here](https://cran.r-project.org/web/packages/hmer/index.html)), we created the following tutorials, meant to be addressed in the proposed ordered:

1. [Deterministic tutorial](https://danny-sc.github.io/Tutorial_2/): a general introduction to _hmer_'s functionalities for the calibration of deterministic models.

2. [Deterministic practical tutorial](https://danny-sc.github.io/determ_workshop/): a practical, interactive introduction to _hmer_'s functionalities for the calibration of deterministic models. You can work through this practical tutorial by running the [R script without solutions](https://github.com/hmer-package/website/blob/gh-pages/determ_workshop_code_without_sols.R) line by line. Note that the tutorial has tasks that require you to write your own code. Solutions to these tasks can be found both in the html file and in the [R script with solutions](https://github.com/hmer-package/website/blob/gh-pages/determ_workshop_code_with_sols.R).

3. Stochastic practical tutorial: a practical introduction to _hmer_'s functionalities for the calibration of models presenting stochasticity and/or bimodality.

## Template to set up HME on your model 
This repository contains an R-script [Template_hmer_script](https://raw.githubusercontent.com/hmer-package/website/gh-pages/Template_hmer_script.R) that will guide you through setting up history matching with emulation on your model of interest.

## Additional references

You can take a look at the following epidemiological papers, where HME was used for the calibration of HIV models:
- [Bayesian History Matching of Complex Infectious Disease Models Using Emulation: A Tutorial and a Case Study on HIV in Uganda](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1003968)
- [History matching of a complex epidemiological
model of human immunodeficiency virus
transmission by using variance emulation](https://researchonline.lshtm.ac.uk/id/eprint/4650003/1/History%20matching%20of%20a%20complex%20epidemiological%20model%20of%20human%20immunodeficiency%20virus%20transmission%20by%20using%20variance%20emulation.pdf)

The following papers, where HME was used in disciplines such as astrophysics and biology, contain a more technical and statistical introduction to the method:
- [Galaxy formation : a Bayesian uncertainty analysis](https://dro.dur.ac.uk/8086/)
- [Galaxy Formation: Bayesian History Matching for the Observable Universe](https://projecteuclid.org/journals/statistical-science/volume-29/issue-1/Galaxy-Formation-Bayesian-History-Matching-for-the-Observable-Universe/10.1214/12-STS412.full)
- [Constraints on galaxy formation models from the galaxy stellar mass function and its evolution](https://academic.oup.com/mnras/article/466/2/2418/2691461)
- [Bayesian uncertainty analysis for complex systems biology models: emulation, global parameter searches and evaluation of gene functions](https://bmcsystbiol.biomedcentral.com/articles/10.1186/s12918-017-0484-3)
- [Assessing model adequacy](https://dro.dur.ac.uk/23252/)
