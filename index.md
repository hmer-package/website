---
title: Welcome to the hmer package website! 
---

<div class="navbar">
  <a href="index.html" class="active">Home</a>
  <a href="learning_resources.html">Learning resources</a>
  <a href="24may2022workshop.html">Workshops</a>
  <a href="papers.html">Research papers</a>
</div>

<br>

<br>

![logos](logos.PNG)

## Background 
Infectious disease models are widely used by epidemiologists to improve the understanding of transmission dynamics and disease natural history, and to predict the possible effects of interventions. As the complexity of such models increases, however, it becomes increasingly challenging to robustly calibrate them to empirical data. History matching with emulation (HME) is a calibration method that has been successfully applied to such models, but has not been widely used in epidemiology partly due to the lack of available software. To address this issue, we developed a new, user-friendly R package _hmer_ that allows you to simply and efficiently perform history matching with emulation.


## History matching with emulation (HME) and _hmer_  

History matching concerns the problem of exploring the parameter space and identifying the parameter sets that may give rise to acceptable matches between the model output and the empirical data. This part of the input space is referred to as _non-implausible_, while its complement is referred to as _implausible_. History matching proceeds as a series of iterations, called waves, where implausible areas of input space are identified and discarded. To do so, it is necessary to explore large portions of the parameter space. Unfortunately, this can be computationally unfeasible when working with complex simulators and/or high-dimensional parameter spaces. To address this issue, we resort to emulators.

An emulator is a statistical model of the simulator, which can be built using a relatively small number of simulator runs. The emulator approximates the simulator results, but also has a built-in understanding of the uncertainty brought by its estimates. This property allows us to use the emulator as a surrogate for the simulator, with the advantage that emulators tends to be several order of magnitude faster than the corresponding simulators.

In the _hmer_ package, to train emulators, we forego a full Bayesian approach and instead focus on Bayes linear updates (for details, see e.g. [this book](https://onlinelibrary.wiley.com/doi/book/10.1002/9780470065662)). This has the advantage of being quick to evaluate, and does not require us to supply full probabilistic specifications for all parameters of the emulator.

## Package development contributors 

- [Andrew Iskauskas](https://www.durham.ac.uk/staff/andrew-iskauskas/)
- [Michael Goldstein](https://www.durham.ac.uk/staff/michael-goldstein/)
- [Nicky McCreesh](https://www.lshtm.ac.uk/aboutus/people/mccreesh.nicky)
- [TJ McKinley](https://emps.exeter.ac.uk/mathematics/staff/tm389)
- [Danny Scarponi](https://www.lshtm.ac.uk/aboutus/people/scarponi.danny)
- [Ian Vernon](https://www.durham.ac.uk/staff/i-r-vernon/)
- [Richard White](https://www.lshtm.ac.uk/aboutus/people/white.richard)

The development of the _hmer_ package was supported by the Wellcome Trust. <img src="wellcome_trust.png" width="75">

## Subscribe to our mailing list! 

To receive future updates on the package and hmer workshops, please go [here](https://lists.lshtm.ac.uk/sympa/info/hmer_mailing_list) and click on the "Subscribe" button on the left panel. You will be asked to insert your email address. 

As a member, you will receive the latest updates about the hmer package, including: new features, workshops and events on the use of the package.

You can unsubscribe from the hmer mailing list at any time. For information on how we use your data, please see our [privacy notice](https://www.lshtm.ac.uk/sites/default/files/Mailing-List-Privacy-Notice.pdf) for mailing list recipients and our [Data Protection](https://www.lshtm.ac.uk/aboutus/organisation/data-protection) pages.
