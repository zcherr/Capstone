# loading packages
library(glmnet) #Make sure this package is installed.
library(ggplot2)

#Function to estimate hold-out accuracy for l1-regularization classification
cv_accuracy <- function(x, y, num_hold_out){
  # x = input matrix
  # y = factor containing category label for each row of x
  # num_hold_out = number of items to hold out for test
  
  nitems <- dim(x)[1] #Number of items in x matrix
  
  tstitems <- sample(nitems,num_hold_out) #Choose nho items at random for hold-out set
  trnitems <- setdiff(c(1:nitems), tstitems) #Use remaining items for training set
  
  #Put test items in the test set
  x_tst <- x[tstitems,] 
  y_tst <- y[tstitems]
  
  #Put remaining items in the training set
  x_trn <- x[trnitems,] # the data type looks diff from `x_tst`, due to the size
  y_trn <- y[trnitems]
  
  #Search for best lambda
  lam <- cv.glmnet(x = x_trn, y = y_trn, family = "multinomial")$lambda.min
  
  #Refit model using chosen lambda
  m <- glmnet(x = x_trn, y = y_trn, family = "multinomial", lambda = lam)
  
  #Predict class label for test items
  pclass <- predict(m, x_tst, type = "class")
  
  return(c(lam, mean(pclass==y_tst))) #Return selected lambda and mean proportion correct on hold-outs 
}

# function to iterate the process
# the function `cv_accuracy` is to calculate the accuracy based on cv as criteria for each round to 
# fit a temp-final-model

iterative_selection <- function(x, y, threshold = 1/3, max_iter = 10, runs = 5, num_hold_out = 9, seed = 42) {
  set.seed(seed)
  hold_out_acc_med <- c()
  selected_x <- list()
  
  for (iter in 1:max_iter) {
    # show current iter
    print(paste("Iteration:", iter))
    # acc matrix of current iteration
    hold_out_acc <- matrix(NA, nrow = 2, ncol = runs)
    for (i in 1:runs) {
      hold_out_acc[, i] <- cv_accuracy(x = x, y = y, num_hold_out = num_hold_out)
    }
    # median acc of current iteration
    print(paste("Median hold-out accuracy:", median(hold_out_acc[2, ])))
    # ---- judgement of acc condition ----
    if (median(hold_out_acc[2, ]) < threshold) {
      print("Accuracy lower than random guess. Terminate the iterative variable selection.")
      break
    }
    # LOG: median acc for current iteration
    hold_out_acc_med <- c(hold_out_acc_med, median(hold_out_acc[2, ]))
    # MODEL: corresonding lambda to model in current iteration
    mfinal_cv <- glmnet(x = x, y = y, family = "multinomial", lambda = median(hold_out_acc[1, ]))
    mcoef <- coef(mfinal_cv)
    mcoefs <- cbind(as.matrix(mcoef[[1]]), as.matrix(mcoef[[2]]), as.matrix(mcoef[[3]]))
    mcoefs <- mcoefs[-1, ]
    colnames(mcoefs) <- c("face", "place", "object")
    
    # change the coefficients data to df
    tmp <- as.data.frame(mcoefs)
    # index of non-zero parameters in the x data
    tmp_index <- (tmp$face == 0 & tmp$place == 0 & tmp$object == 0)
    # change the x data to df
    tmp_x <- as.data.frame(x)
    
    # select out the predictors satisfying the requirements
    # those voxels are selected when their parameters is non-zero at least for one category
    selected_x[[iter]] <- tmp_x[, !tmp_index]
    x <- as.matrix(tmp_x[, tmp_index])
    
    # number of non-zero paramters in current iteration
    print(paste("Selected features for iteration", iter, ":", sum(!tmp_index)))
  }
  
  # results: 
  # [[1]]: log of acc; 
  # [[2]]: selected variables in each iteration (combined)
  return(list(hold_out_acc_med = hold_out_acc_med, selected_x = do.call(cbind, selected_x)))
}

# Loop for batch processing
# Function to fit model and perform iterative selection for a given subject
fit_model_for_subject <- function(subject_id, brain_file, stims, coord, rerun_setting=T, runs=5, max_iter=10) {
  # subject_id: id of individual subject
  # brain_file: file containing reactions of voxels
  # stims: file containing info of stimulus
  # coord: file containing info of coordinates
  
  # Read in the brain data for the subject
  brain_data <- as.matrix(read.csv(brain_file, row.names = NULL, header = FALSE))
  
  # Filter stimuli and coordinates data for the subject
  subject_stims <- stims |> 
    filter(subject == subject_id)
  # the following `subject_coord` is not used at present (2024-08-01); 
  # TODO: should be waived? or incorporated as part of the result?
  subject_coord <- coord |> 
    filter(V4 == subject_id) |> 
    select(x, y, z)
  
  # Prepare training material
  x <- brain_data  # Voxel activation patterns as the predictor matrix
  y <- factor(subject_stims$category, levels = c("face", "place", "object"))  # Category labels
  
  # Run the iterative function
  result_iter <- cache_rds(
    expr = {
      iterative_selection(x = x, y = y, runs = runs, max_iter = max_iter)
    },
    dir = "cache/",
    file = paste0("iterative_selection_s", subject_id),
    rerun = rerun_setting # NEED TO CHANGE when run formally
  )
  # result
  # because the data is processed in order, so that we could read out by numeric index directly.
  # result_iter[[subject_id]][[1]]: median accuracies
  # result_iter[[subject_id]][[2]]: df of selected voxels
  return(result_iter)
}








