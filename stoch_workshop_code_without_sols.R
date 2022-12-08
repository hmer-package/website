# WORKSHOP 2: CALIBRATING STOCHASTIC AND BIMODAL MODELS
# This tutorial offers an interactive introduction to the main functionality of the hmer package for the 
# calibration of stochastic and bimodal epidemiological models. 



###############################################  DEPENDENCIES  ################################################ 

library(hmer)
library(lhs)
library(deSolve)
library(ggplot2)
library(reshape2)
library(purrr)
library(tidyverse)
library(progressr)
handlers("progress")
set.seed(123)


#############################################  HELPER FUNCTIONS  ############################################## 

# Define the helper function that calculates the mean of the model outputs from several runs 
# at the same parameter set
aggregate_points <- function(data, input_names, func = 'mean') {
  unique_points <- unique(data[,input_names])
  uids <- apply(unique_points, 1, rlang::hash)
  data_by_point <- purrr::map(uids, function(h) {
    data[apply(data[,input_names], 1, rlang::hash) == h,]
  })
  aggregate_func <- get(func)
  aggregate_values <- do.call('rbind.data.frame', purrr::map(data_by_point, function(x) {
    output_data <- x[,!(names(x) %in% input_names)]
    apply(output_data, 2, aggregate_func)
  }))
  return(setNames(cbind.data.frame(unique_points, aggregate_values), names(data)))
}

# Define the function that implements the SEIRS stochastic model using the Gillespie algorithm
# N is a list containing N$M, the initial number of people in each compartment (comprising deaths), 
# N$Post, N$Pre, N$h. T is the time up to which we want to simulate (400th day by default). 
gillespied=function (N, T=400, dt=1, ...)
{
  tt=0
  n=T%/%dt
  x=N$M
  S=t(N$Post-N$Pre)
  u=nrow(S)
  v=ncol(S)
  xmat=matrix(0,ncol=u,nrow=n)
  i=1
  target=0
  repeat {
    h=N$h(x, tt, ...)
    h0=sum(h)
    if (h0<1e-10)
      tt=1e99
    else
      tt=tt+rexp(1,h0)
    while (tt>=target) {
      xmat[i,]=x
      i=i+1
      target=target+dt
      if (i>n)
        return(xmat)
    }
    j=sample(v,1,prob=h)
    x=x+S[,j]
  }
}

# Initial setup: transition matrices, hazard function, and initial conditions
Num <- 1000
N=list()
N$M=c(900,100,0,0,0)

# Columns of N$Pre are 5, for S, E, I, R, and Deaths. Rows are for transitions: births, S to E, 
# S to D, E to I, E to D, I to D, I to R, R to S, R to D. For example: the first row is 
# all of zeros, since we need no person in S, nor in the other compartments for a new birth to happen. 
# Columns of N$Post are 5 as for N$Pre. Rows are for transitions as for N$Pre. 
# For example: the element in (1,1) is 1 since a new birth goes straight into the S compartment. 
N$Pre = matrix(c(0,0,0,0,0,
                 1,0,0,0,0,
                 1,0,0,0,0,
                 0,1,0,0,0,
                 0,1,0,0,0,
                 0,0,1,0,0,
                 0,0,1,0,0,
                 0,0,0,1,0,
                 0,0,0,1,0), ncol = 5, byrow = TRUE)
N$Post = matrix(c(1,0,0,0,0,
                  0,1,0,0,0,
                  0,0,0,0,1,
                  0,0,1,0,0,
                  0,0,0,0,1,
                  0,0,0,0,1,
                  0,0,0,1,0,
                  1,0,0,0,0,
                  0,0,0,0,1), ncol = 5, byrow = TRUE)

# Here x is the vector with the number of people in each of the compartments (deaths excluded), 
# t is the time and th is a vector with the parameters. N$h returns a vector with all the 
# transition rates at time t.
N$h=function(x,t,th=rep(1,9))
{
  Num = x[1]+x[2]+x[3]+x[4]
  if (t > 270) tns <- th[5]
  else if (t > 180) tns <- (th[5]-th[4])*t/90+3*th[4]-2*th[5]
  else if (t > 100) tns <- th[4]
  else tns <- (th[4]-th[3])*t/100+th[3]
  return(
    c(th[1]*Num,
      tns*x[3]*x[1]/Num,
      th[2]*x[1],
      th[6]*x[2],
      th[2]*x[2],
      (th[7]+th[2])*x[3],
      th[8]*x[3],
      th[9]*x[4],
      th[2]*x[4])
  )
}

# Define the function that takes a dataframe of parameter sets and returns 
# the model outputs from 100 runs at each parameter set
get_results <- function(params, nreps = 100, outs, times, raw = FALSE) {
  tseq <- 0:max(times)
  arra <- array(0, dim = c(max(tseq)+1, 5, nreps))
  for(i in 1:nreps) arra[,,i] <- gillespied(N,T=max(times) + 1 + 0.001,dt=1,th=params)
  if(raw) return(arra)
  collected <- list()
  for (i in 1:nreps) {
    relev <- c(arra[times+1, which(c("S", "E", "I", "R", "D") %in% outs), i])
    names <- unlist(purrr::map(outs, ~paste0(., times, sep = "")))
    relev <- setNames(relev, names)
    collected[[i]] <- relev
  }
  input_dat <- setNames(data.frame(matrix(rep(params, nreps), ncol = length(params), byrow = TRUE)), names(params))
  return(cbind(input_dat, do.call('rbind', collected)))
}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #  
########################################  3. INTRODUCTION TO THE MODEL  #######################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Define the parameter chosen to then define the targets
chosen_params <- c(
  b = 1/(76*365),
  mu = 1/(76*365),
  beta1 = 0.214, beta2 = 0.107, beta3 = 0.428,
  epsilon = 1/7,
  alpha = 1/50,
  gamma = 1/14,
  omega = 1/365
)

# Run the function `get_results` on `chosen_params` and plot the model output
solution <- get_results(chosen_params, outs = c("I", "R"), 
                        times = c(25, 40, 100, 200), raw = TRUE)
plot(0:200, ylim=c(0,700), ty="n", xlab = "Time", ylab = "Number")
for(j in 3:4) for(i in 1:100) lines(0:200, solution[,j,i], col=(3:4)[j-2], lwd=0.3)
legend('topleft', legend = c('Infected', "Recovered"), lty = 1, 
       col = c(3,4), inset = c(0.05, 0.05))
plot(0:200, ylim=c(0,1000), ty="n", xlab = "Time", ylab = "Number", main = "Susceptibles")
for(i in 1:100) lines(0:200, solution[,1,i], col='black', lwd=0.3, 
                      xlab = "Time", ylab = "Number", main = "Susceptibles")

###  Write your solution to the task on the exploration of the model ###

### End of the solution ###



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
############################  4. WAVE0 - PARAMETER RANGES, TARGETS AND DESIGN POINTS  ###########################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# Define the ranges of the parameters
ranges = list(
  b = c(1e-5, 1e-4), # birth rate
  mu = c(1e-5, 1e-4), # rate of death from other causes
  beta1 = c(0.05, 0.3), # infection rate at time t=0
  beta2 = c(0.1, 0.2), # infection rates at time t=100
  beta3 = c(0.3, 0.5), # infection rates at time t=270
  epsilon = c(0.01, 0.21), # rate of becoming infectious after infection
  alpha = c(0.01, 0.025), # rate of death from the disease
  gamma = c(0.01, 0.08), # recovery rate
  omega = c(0.002, 0.004) # rate at which immunity is lost following recovery
)

# Define the targets (here with lower and upper bound)
targets <- list(
  I25 = c(98.51, 133.25),
  I40 = c(117.17, 158.51),
  I100 = c(22.39, 30.29),
  I200 = c(0.578, 0.782),
  R25 = c(106.34, 143.9),
  R40 = c(218.28, 295.32),
  R100 = c(458.14, 619.84),
  R200 = c(377.6, 510.86)
)

# Define two Latin hypercube designs through the function `maximinLHS`. This function assumes 
# that each parameter is distributed on [0,1]
initial_LHS_training <- maximinLHS(100, 9)
initial_LHS_validation <- maximinLHS(50, 9)
initial_LHS <- rbind(initial_LHS_training, initial_LHS_validation)

# Rescale the parameter ranges from [0,1] to the correct ranges, and add columns names to 
# identify the parameters
initial_points <- setNames(data.frame(t(apply(initial_LHS, 1, 
                                              function(x) x * purrr::map_dbl(ranges, diff) + 
                                                purrr::map_dbl(ranges, ~.[[1]])))), names(ranges))


# Run the model on `initial_points` 
initial_results <- list()
with_progress({
  p <- progressor(nrow(initial_points))
  for (i in 1:nrow(initial_points)) {
    model_out <- get_results(unlist(initial_points[i,]), nreps = 25, outs = c("I", "R"), 
                             times = c(25, 40, 100, 200))
    initial_results[[i]] <- model_out
    p(message = sprintf("Run %g", i))
  }
})

# Create the `wave0` dataframe by binding `initial_results` by row 
wave0 <- data.frame(do.call('rbind', initial_results))

# Split `wave0` into a training and a validation dataset
all_training <- wave0[1:2500,]
all_valid <- wave0[2501:3750,]

# Create a list with the names of the targets
output_names <- c("I25", "I40", "I100", "I200", "R25", "R40", "R100", "R200")



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#################################################  5. EMULATORS  ##############################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Train stochastic emulators using `variance_emulator_from_data`
stoch_emulators <- variance_emulator_from_data(all_training, output_names, ranges)

# Check what variables are active for the variance and for the mean emulators
plot_actives(stoch_emulators$variance)
plot_actives(stoch_emulators$expectation)

# Plot the expectation of the mean emulator for I100 in the (epsilon,alpha)-plane, 
# fixing the un-shown parameters to their value in the first row of `all_training`
emulator_plot(stoch_emulators$expectation$I100, params = c('epsilon', 'alpha'),
              fixed_vals = all_training[1, names(ranges)[-c(6,7)]], plot_type = 'var') +
  geom_point(data = all_training[1,], aes(x = epsilon, y = alpha))



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
##############################################  6. IMPLAUSIBILITY  ############################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Plot the maximum implausibility across all emulators in the (epsilon,alpha)-plane
emulator_plot(stoch_emulators, plot_type = 'nimp', 
              targets = targets, params = c('epsilon', 'alpha'))

###  Write your solution to the task on the maximum implausibility at `chosen_params`  ###

### End of the solution ###


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
###########################################  7. EMULATOR DIAGNOSTICS  #########################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Produce three diagnostics of the mean emulators using `validation_diagnostics`
vd <- validation_diagnostics(stoch_emulators$expectation, targets, all_valid, plt=TRUE, row=2)




# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
############################################  8. PROPOSING NEW POINTS  ########################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Generate 150 new points using `generate_new_runs`
new_points <- generate_new_runs(stoch_emulators, 150, targets)

# Plot `new_points` using `plot_wrap` 
plot_wrap(new_points, ranges)



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
###############################################  9. SECOND WAVE  ##############################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Run the model on the parameter sets in `new_points`
new_results <- list()
with_progress({
  p <- progressor(nrow(new_points))
  for (i in 1:nrow(new_points)) {
    model_out <- get_results(unlist(new_points[i,]), nreps = 50, outs = c("I", "R"), 
                             times = c(25, 40, 100, 200))
    new_results[[i]] <- model_out
    p(message = sprintf("Run %g", i))
  }
})

# Bind the results in `new_results` by row, obtaining `wave1`
wave1 <- data.frame(do.call('rbind', new_results))

# Split `wave1` into a training and a validation set
new_all_training <- wave1[1:5000,]
new_all_valid <- wave1[5001:7500,]


# Train new stochastic emulators using `variance_emulators_from_data`
new_stoch_emulators <- variance_emulator_from_data(new_all_training, output_names, ranges, 
                                                   check.ranges=TRUE)

# Produce three diagnostics of the new emulators using `validation_diagnostics`
vd <- validation_diagnostics(new_stoch_emulators, targets, new_all_valid, plt=TRUE, row=2)


# Generate new parameter sets, non-implausible for both `new_stoch_emulators` and `stoch_emulators`
new_new_points <- generate_new_runs(c(new_stoch_emulators, stoch_emulators), 150, targets)


# Run the model on the parameter sets in `new_new_points`
new_new_results <- list()
with_progress({
  p <- progressor(nrow(new_new_points))
  for (i in 1:nrow(new_new_points)) {
    model_out <- get_results(unlist(new_new_points[i,]), nreps = 100, outs = c("I", "R"), 
                             times = c(25, 40, 100, 200))
    new_new_results[[i]] <- model_out
    p(message = sprintf("Run %g", i))
  }
})

# Bind the results in `new_new_results` by row, obtaining `wave2`
wave2 <- data.frame(do.call('rbind', new_new_results))

# The first 100000 rows of `wave2` constitute the training set
new_new_all_training <- wave2[1:10000,]



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#############################  10. VISUALISATIONS OF NON-IMPLAUSIBLE SPACE BY WAVE  ###########################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Show the distribution of the non-implausible space before the wave 1, at the end of wave 1 and at the end of
# wave 2 using the function `wave_points`
wave_points(list(initial_points, new_points, new_new_points), 
            input_names = names(ranges)[c(2,3,6,8,9)]) +
  ggplot2::theme(axis.text.x = ggplot2::element_text(size = 6))


# Use the `aggregate_points` to calculate the mean of each output across different realisations
all_training_aggregated <- aggregate_points(all_training, names(ranges))
new_all_training_aggregated <- aggregate_points(new_all_training, names(ranges))
new_new_all_training_aggregated <- aggregate_points(new_new_all_training, names(ranges))

# Create a list with all aggregated results
all_aggregated <- list(all_training_aggregated, new_all_training_aggregated,
                       new_new_all_training_aggregated)

# Assess how much better parameter sets at later waves perform compared to the original `initial_points` through 
# `simulator_plot`
simulator_plot(all_aggregated, targets, barcol = "grey")

# For each combination of two outputs, show the output values for non-implausible parameter sets at each wave.
wave_values(all_aggregated, targets, l_wid=1) 



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#########################################  11. DEALING WITH BIMODALITY  #######################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Run the model on `chosen_params` using `get_results` up to time t=500 and plotting the results 
# for "I" and "R":
solution <- get_results(chosen_params, outs = c("I", "R"), 
                        times = c(25, 40, 100, 200, 300, 400, 500), raw = TRUE)
plot(0:500, ylim=c(0,700), ty="n", xlab = "Time", ylab = "Number")
for(j in 3:4) for(i in 1:100) lines(0:500, solution[,j,i], col=(3:4)[j-2], lwd=0.3)
legend('topleft', legend = c('Infected', "Recovered"), lty = 1, 
       col = c(3,4), inset = c(0.05, 0.05))

###  Write your solution to the task on the exploration of bimodality ###

### End of the solution ###

# Define the targets for the bimodal case 
bimodal_targets <- list(
  I25 = list(val = 115.88, sigma = 5.79),
  I40 = list(val = 137.84, sigma = 6.89),
  I100 = list(val = 26.34, sigma = 1.317),
  I200 = list(val = 0.68, sigma = 0.034),
  I250 = list(val = 9.67, sigma = 4.76),
  I400 = list(val = 15.67, sigma = 5.36),
  I500 = list(val = 14.45, sigma = 5.32),
  R25 = list(val = 125.12, sigma = 6.26),
  R40 = list(val = 256.80, sigma = 12.84),
  R100 = list(val = 538.99, sigma = 26.95),
  R200 = list(val = 444.23, sigma = 22.21),
  R250 = list(val = 361.08, sigma = 25.85),
  R400 = list(val = 569.39, sigma = 26.52),
  R500 = list(val = 508.64, sigma = 28.34)
)

# Run the model on `initial_points`
bimodal_initial_results <- list()
with_progress({
  p <- progressor(nrow(initial_points))
  for (i in 1:nrow(initial_points)) {
    model_out <- get_results(unlist(initial_points[i,]), nreps = 50, outs = c("I", "R"), 
                             times = c(25, 40, 100, 200, 250, 400, 500))
    bimodal_initial_results[[i]] <- model_out
    p(message = sprintf("Run %g", i))
  }
})

# Bind the results by row to get `bimodal_wave0`
bimodal_wave0 <- data.frame(do.call('rbind', bimodal_initial_results))

# Split `bimodal_wave0` into a training and a validation set
bimodal_all_training <- bimodal_wave0[1:5000,]
bimodal_all_valid <- bimodal_wave0[5001:7500,]

# Define a list with the outputs' names
bimodal_output_names <- c("I25", "I40", "I100", "I200", "I250", "I400", "I500", 
                          "R25", "R40", "R100", "R200", "R250", "R400", "R500")

# Train bimodal emulators using `bimodal_emulator_from_data`
bimodal_emulators <- bimodal_emulator_from_data(bimodal_all_training,
                                                bimodal_output_names, ranges)

# Plot the mean emulator for mode 1 for R400 in the (alpha,epsilon)-plane with the un-shown 
# parameters as in `chosen_params`
emulator_plot(bimodal_emulators$mode1$expectation$R400, params = c('alpha', 'epsilon'),
              fixed_vals = chosen_params[!names(chosen_params) %in% c('alpha', 'epsilon')])

# Plot the mean emulator for mode 2 for R400 in the (alpha,epsilon)-plane with the un-shown 
# parameters as in `chosen_params`
emulator_plot(bimodal_emulators$mode2$expectation$R400, params = c('alpha', 'epsilon'),
              fixed_vals = chosen_params[!names(chosen_params) %in% c('alpha', 'epsilon')])

# Plot the proportion emulator in the (alpha,epsilon)-plane with the un-shown parameters as 
# in `chosen_params` 
emulator_plot(bimodal_emulators$prop, params = c('alpha', 'epsilon'),
              fixed_vals = chosen_params[!names(chosen_params) %in% c('alpha' ,'epsilon')]) +
  geom_point(aes(x=1/7, y=1/50), size=3)

# Plot the mean emulator for mode 1 for I400 in the (alpha,epsilon)-plane
emulator_plot(bimodal_emulators$mode1$expectation$I400, params = c('alpha', 'epsilon'))

# Plot the mean emulator for mode 2 for I400 in the (alpha,epsilon)-plane
emulator_plot(bimodal_emulators$mode2$expectation$I400, params = c('alpha', 'epsilon'))

# Plot the maximum implausibility of the `bimodal_emulators` in the (alpha,epsilon)-plane
emulator_plot(bimodal_emulators, plot_type = 'nimp', targets = bimodal_targets,
              params = c('alpha', 'epsilon'))

# Plot the implausibility for each of the mean emulators in mode 1, in the (omega,epsilon)-plane
emulator_plot(bimodal_emulators$mode1, plot_type = 'imp',
              targets = bimodal_targets, params = c('omega', 'epsilon'))

# Plot the implausibility for each of the mean emulators in mode 2, in the (omega,epsilon)-plane
emulator_plot(bimodal_emulators$mode2, plot_type = 'imp',
              targets = bimodal_targets, params = c('omega', 'epsilon'))

# Produce three diagnostics of the mean emulators using `validation_diagnostics`
vd <- validation_diagnostics(bimodal_emulators, bimodal_targets, bimodal_all_valid, 
                             plt=TRUE, row=2)

# Multiply the `sigma` by 2 for the mean emulators for mode 1 and mode 2 for I500
bimodal_emulators$mode1$expectation$I500 <- bimodal_emulators$mode1$expectation$I500$mult_sigma(2)
bimodal_emulators$mode2$expectation$I500 <- bimodal_emulators$mode2$expectation$I500$mult_sigma(2)

# Generate new points using `generate_new_runs`
new_points <- generate_new_runs(bimodal_emulators, 150, bimodal_targets, nth=1)
