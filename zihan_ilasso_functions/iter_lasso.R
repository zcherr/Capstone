# Date: 2024-11-21
# Author: Zihan

iter_lasso <- function(x, y, type="class", family="multinomial", nho, max_iter, runs=NA, seed=42){
##########################################################################
# This function implements the iterated lasso processing.
# The accuracy in each iteration is calculated by `cv_hoacc` function.
# 
# Input:
# x - matrix containing the feats/voxels
# y - factor containing the labels/categories
# type - task type of `glmnet`
# family - type of model to fit (3+)
# nho - number of hold out items, consistent for `cv_hoacc`
# 
# Output: 
# (call as  "<obj>$<output_arg>" when used)
# selected - all selected features from x, matrix (with names), of feats 
# accuracies - accuracy history along iterations, list
##########################################################################
  
  # Initialization
  set.seed(seed) # Reproducible fake randomness; enough for the whole iters
  x_trn <- x
  
  # Define the criteria for termination is acc higher than random guess
  threshold <- 1/length(unique(y))
  acc_log <- c()
  selected_x <- c()
  
  for (iter in 1:max_iter){
    # Keep running, until breaks
    print(paste("Iteration:", iter))
    
    # ---- Accuracy Judgement ----
    # Branch 1: If there is no `runs`, no nested
    if (is.na(runs)){
      cv_result <- cv_hoacc(x=x_trn, y=y, nho=nho, alpha=1, type="class")
      lambda <- cv_result$lambda
      acc <- cv_result$accuracy
    }
    # Branch 2: If there is `runs`, take the median of the acc's
    else{
      accuracies <- c()
      lambdas <- c()
      for (run in 1:runs) {
        print(paste("Run:", run))
        cv_result <- cv_hoacc(x = x_trn, y = y, nho=nho, alpha=1, type="class")
        # Extract accuracies and lambdas
        accuracies <- append(accuracies, cv_result$accuracy)
        lambdas <- append(lambdas, cv_result$lambda)
      }
      # median accuracy
      acc <- median(accuracies)
      # If multiple, median
      index <- median(which(accuracies == acc))
      # lambda corresponding to the median accuracy
      lambda <- lambdas[index]
    }
    print(paste("Current accuracy is", acc))
    # Make sure the criteria is met
    if (acc <= threshold){
      print("Accuracy <= guess. Terminate the iteration.")
      break
    }
    # Log of accuracy
    acc_log <- append(acc_log, acc)
    
    # ---- Feature Selection ----
    # Fit current model to select non-zero feats
    fit <- glmnet(x=x_trn, y=y, family="multinomial", lambda=lambda) # should use the best lambda
    cur_selected_x <- get_selected_feats(fit)
    selected_x <- append(selected_x, cur_selected_x)
    # Show how many features are selected
    print(paste(length(cur_selected_x), "features selected in cur iter."))
    
    # Remove selected x's 
    x_trn <- x_trn[, setdiff(colnames(x_trn), selected_x), drop = FALSE]
    rm(cur_selected_x)
  }
  
  # Return accuracy log and selected features
  selected <- x[, selected_x, drop = FALSE]
  list(accuracies = acc_log, selected = selected)
}