require(hmer)

# This R-script is a template for you to perform history matching with emulation. Note that while some sections contain 
# code that is ready to be run, in other sections you will have to adapt the code yo your own model.


#############################################################################################################################
######################################## Parameter ranges, targets and design points ########################################
#############################################################################################################################


################################# Create empty lists to store data from the different waves #################################

ems <- list() # ems[[k]] will contain wave-k emulators
wave_data <- list() # wave_data[[k]] will contain the data used to train and validate wave-k emulators
ranges <- list() # ranges[[k]] will contain the parameter ranges used to train wave-k emulators
non_imp_pts <- list() # non_imp_pts[[k]] will contain the non-implausible points generated at the end of wave k

# You may also wish to save to file the data from the different waves

################################### Assign the initial parameter ranges to `ranges[[1]]` ####################################

# For example if you have three parameters, called `param1`, `param2` and `param3`, with ranges (a1,b1), (a2,b2) and (a3,b3), 
# `ranges[[1]]` would be:
# ranges[[1]] = list(
#     param1 = c(a1,b1), 
#     param2 = c(a2,b2),
#     param3 = c(a3,b3)
# )


################################################# Define the `targets` list #################################################

# For example if you have two targets, called `target1` and `target2`, with mean value m1 and standard deviation
# sd1 for `target1`, and lower bound lb2 and upper bound ub2 for `target2`, the list `targets` would be: 
# targets = list(
#     target1 = list(val=m1, sigma=sd1), 
#     target2 = c(lb2,ub2)
# )


############################################## Define a latin hypercube design ##############################################

# This can be done through the function `randomLHS`, which assumes that each parameter is distributed on [0,1]
initial_LHS <- lhs::randomLHS(20 * length(ranges[[1]]), length(ranges[[1]]))
# Adjust each parameter range to be the corrected one (instead of [0,1]) and add columns names to identify the parameters
initial_points <- setNames(data.frame(t(apply(initial_LHS, 1, 
                                              function(x) x*unlist(lapply(ranges[[1]], function(x) x[2]-x[1])) + 
                                                  unlist(lapply(ranges[[1]], function(x) x[1]))))), names(ranges[[1]]))


###################### Assign `initial_points` and the correspondent model outputs to `wave_data[[1]]` ######################

# First run the model on the parameter sets in `initial_points`. Put the outputs in a dataframe `initial_results`, having as 
# many rows as `initial_points` and a column for each model output. The columns should be named according to the names in 
# `targets`. Finally bind `initial_points` and `initial_results`:

wave_data[[1]]<-cbind(initial_points, initial_results)


################################# Split `wave_data[[1]]` into training and validation sets ##################################

t_sample <- sample(1:nrow(wave_data[[1]]), round(length(wave_data[[1]][,1])/2))
training <- wave_data[[1]][t_sample,]
validation <- wave_data[[1]][-t_sample,]



#############################################################################################################################
########################################################### Wave 1 ##########################################################
#############################################################################################################################


############################# Train wave-1 emulators through the function `emulator_from_data` ##############################

ems[[1]] <- emulator_from_data(training, names(targets), ranges[[1]])


######################### Validate wave-1 emulators through the function `validation_diagnostics` ###########################

# Plot the three validation tests for each emulator in `ems[[1]]`

vd <- validation_diagnostics(ems[[1]], validation = validation, targets = targets, plt=TRUE)

# If all emulators pass the three tests, go to the next section to generate non-implausible points.
# If, for example, the emulator for `target1` does not pass all three diagnostics, increase its sigma to improve its 
# performance. The code below multiplies the sigma by a factor 1.2: 
# ems[[1]]$`target1` <- ems[[1]]$`target1`$mult_sigma(1.2)
# Then check if the modified emulator passes the diagnostics:
# vd <- validation_diagnostics(ems[[1]][[i]], validation = validation, targets = targets, plt=TRUE)
# If it does, you are done, otherwise you can further increase the sigma, till all three diagnostic tests are successful. 
# Note that you can also choose not to use an emulator at any given wave, if its performance is particularly poor. 
# The following code removes the emulator for `target1` from the list of emulators in the first wave:
# ems[[1]]$`target1` <- NULL


######################## Generate non-implausible points through the function `generate_new_runs` ###########################

# The code below generates points that are deemed non-implausible by all wave-1 emulators and assigns the obtained points to
# `non_imp_pts[[1]]`. If in the validation step you decided to discard one or more emulators, then replace `ems[[1]]` with 
# the correct sublist of emulators. We suggest generating 20 points for each input parameter varied, however this can be 
# changed to create fewer or more points.

non_imp_pts[[1]] <- generate_new_runs(ems[[1]],  20 * length(ranges[[1]]), targets, verbose=TRUE)



#############################################################################################################################
###################################################### Subsequent waves #####################################################
#############################################################################################################################

# The code below can be used for all waves after wave 1. Start with k equal to 2 to perform the second wave, then 
# change k to 3 to perform the third wave, and so on.

k <- 2


############################################# Define the new parameters' ranges #############################################

# Wave-k emulators will be trained only on the non-implausible region found in wave (k-1). To do this, we define new ranges 
# for the parameters, identifying the smallest hyper-rectangle containing all points in `non_imp_pts[[k-1]]`. When defining
# such a hyper-rectangle, we first find the minimum and maximum value of each parameter and then add (resp. subtract) 5% of 
# the obtained range to the maximum (resp. minimum). This is to provide a safety margin, and help ensure that we do not 
# discard any non-implausible point. The new ranges are then stored in `ranges[[k]]`. 

min_val <- list()
max_val <- list()
for (i in 1:length(ranges[[k-1]])) {
    par <- names(ranges[[1]])[[i]]
    min_val[[par]] <- max(min(non_imp_pts[[k-1]][,par])-0.05*diff(range(non_imp_pts[[k-1]][,par])), 
                          ranges[[1]][[par]][1])
    max_val[[par]] <- min(max(non_imp_pts[[k-1]][,par])+0.05*diff(range(non_imp_pts[[k-1]][,par])),
                          ranges[[1]][[par]][2])
    ranges[[k]][[par]] <- c(min_val[[par]], max_val[[par]])
}


#################### Assign `non_imp_pts[[k-1]]` and the correspondent model outputs to `wave_data[[k]]` ####################

# First run the model on the parameter sets in `non_imp_pts[[k-1]]`. Put the outputs in a dataframe `results_k`, having as 
# many rows as `non_imp_pts[[k-1]]` and a column for each model output. The columns should be named according to the names in 
# `targets`. Finally bind `non_imp_pts[[k-1]]` and `results_k`:

wave_data[[k]]<-cbind(non_imp_pts[[k-1]], results_k)


################################## Split `wave_data[[k]]` into training and validation sets #################################

t_sample <- sample(1:nrow(wave_data[[k]]), round(length(wave_data[[k]][,1])/2))
training <- wave_data[[k]][t_sample,]
validation <- wave_data[[k]][-t_sample,]


############################# Train wave-k emulators through the function `emulator_from_data` ##############################

ems[[k]] <- emulator_from_data(training, names(targets), ranges[[k]])


######################### Validate wave-k emulators through the function `validation_diagnostics` ###########################

# Plot the three validation tests for each of the trained emulators

vd <- validation_diagnostics(ems[[k]], validation = validation, targets = targets, plt=TRUE)

# If all emulators pass the three tests, go to the next section (point proposal). Otherwise try to improve them by increasing 
# their sigmas. As already mentioned above, you can also choose not to use an emulator at any given wave, if its performance 
# is particularly poor. 


######################## Generate non-implausible points through the function `generate_new_runs` ###########################

# The code below generates points, evaluating their implausibility using all emulators generated in all prior waves. If in 
# the validation step you decided to discard one or more emulators, then replace `ems[[k]]` with the correct list of 
# emulators you want to use. When using the `generate_new_runs` function, make sure to pass all emulators trained so far.
# Note that it is important to put the last-wave emulators first, since the `generate_new_runs` picks the parameter ranges
# from the first emulator in the list.

non_imp_pts[[k]] <- generate_new_runs(c(ems[[k]],ems[[k-1]],...,ems[[1]]),  20 * length(ranges[[k]]), targets, verbose=TRUE)



#############################################################################################################################
###################################### Comparing non-implausible points across waves ########################################
#############################################################################################################################


############## Show the distribution of the non-implausible space for waves of interest through `wave_points` ###############

# For example, if you want to visualise the distribution of non-implausible points at the end of wave 1, wave 3 and wave 6, 
# you would use the following code:
# wave_points(list(non_imp_pts[[1]], non_imp_pts[[3]], non_imp_pts[[6]]), input_names = names(ranges))


################### Show how non-implausible points perform against the targets using `simulator_plot` #####################

# For example, if you want to compare how non-implausible points from wave 1, wave 3 ad wave 6 perform against the targets,
# you would use the following code:
# simulator_plot(list(wave_data[[1]], wave_data[[3]], wave_data[[6]]), input_names = names(ranges))

















