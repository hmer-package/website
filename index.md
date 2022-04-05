---
title: Welcome to the hmer package website! 
---

<head>
<style>
ul {
  list-style-type: none;
  margin: 0;
  padding: 0;
  overflow: hidden;
  background-color: #333;
}

li {
  float: left;
}

li a {
  display: block;
  color: white;
  text-align: center;
  padding: 14px 16px;
  text-decoration: none;
}

li a:hover {
  background-color: #111;
}
</style>

<ul>
  <li><a class="active" href="index.html">Home</a></li>
  <li><a href="papers.html">News</a></li>
  <li><a href="learning_resources.hmtl">Contact</a></li>
</ul>
</head>
  
![logos](logos.PNG)

## Background 
Infectious disease models are widely used by epidemiologists to improve the understanding of transmission dynamics and disease natural history, and to predict the possible effects of interventions. As the complexity of such models increases, however, it becomes increasingly challenging to robustly calibrate them to empirical data. History matching with emulation (HME) is a calibration method that has been successfully applied to such models, but has not been widely used in epidemiology partly due to the lack of available software. To address this issue, we developed a new, user-friendly R package _hmer_ that allows you to simply and efficiently perform history matching with emulation.


## History matching with emulation (HME) and _hmer_  

History matching concerns the problem of exploring the parameter space and identifying the parameter sets that may give rise to acceptable matches between the model output and the empirical data. This part of the input space is referred to as _non-implausible_, while its complement is referred to as _implausible_. History matching proceeds as a series of iterations, called waves, where implausible areas of input space are identified and discarded. To do so, it is necessary to explore large portions of the parameter space. Unfortunately, this can be computationally unfeasible when working with complex simulators and/or high-dimensional parameter spaces. To address this issue, we resort to emulators.

An emulator is a statistical model of the simulator, which can be built using a relatively small number of simulator runs. The emulator approximates the simulator results, but also has a built-in understanding of the uncertainty brought by its estimates. This property allows us to use the emulator as a surrogate for the simulator, with the advantage that emulators tends to be several order of magnitude faster than the corresponding simulators.

In the _hmer_ package, to train emulators, we forego a full Bayesian approach and instead focus on Bayes linear updates (for details, see e.g. [this book](https://onlinelibrary.wiley.com/doi/book/10.1002/9780470065662)). This has the advantage of being quick to evaluate, and does not require us to supply full probabilistic specifications for all parameters of the emulator.

## [Learn about HME and _hmer_](https://hmer-package.github.io/website/learning_resources)  


## [Workshops](https://hmer-package.github.io/website/24may2022workshop) 


## [Research papers that performed HME through _hmer_](https://hmer-package.github.io/website/papers)


## Template to set up HME on your model 
This repository contains an R-script called _Template_hmer_script_ that will guide you through setting up history matching with emulation on your model of interest.


## Package development contributors 

- [Andrew Iskauskas](https://www.durham.ac.uk/staff/andrew-iskauskas/)
- [Michael Goldstein](https://www.durham.ac.uk/staff/michael-goldstein/)
- [Nicky McCreesh](https://www.lshtm.ac.uk/aboutus/people/mccreesh.nicky)
- [TJ McKinley](https://emps.exeter.ac.uk/mathematics/staff/tm389)
- [Danny Scarponi](https://www.lshtm.ac.uk/aboutus/people/scarponi.danny)
- [Ian Vernon](https://www.durham.ac.uk/staff/i-r-vernon/)
- [Richard White](https://www.lshtm.ac.uk/aboutus/people/white.richard)

The development of the _hmer_ package was supported by the Wellcome Trust. <img src="wellcome_trust.png" width="75">
