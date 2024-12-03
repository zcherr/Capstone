# Date: 2024-11-25
# Author: Zihan Li

iter_lasso_cv_full <- function(x, y, nfold=10, max_iter=10, alpha=1, seed=42){
############################################################################
# This function implement full cross-validation on all data,
# return the accuracy log and selected features.
# 
# Input:
# x - features, matrix
# y - labels, factor
# nfold - numbder of folds in cross-validation, int
# seed - random seed, int
#
# Output:
# accuracies - log of accuracy in each iteration, vector
# selected - selected features, matrix
#
############################################################################
  
  # ---- Global Initialization ----
  # Obtain nfold sets of in/out data
  splits <- cv_splits(x, y, nfold = nfold, seed = seed)
  acc_log <- c()
  num_selected_log <- c()
  threshold <- 1 / length(unique(y))
  selected_x <- c()
  
  # Randomness control on inner cv
  set.seed(seed)
  
  # ---- Iteration ----
  for (iter in 1:max_iter){
    # Keep running, until breaks
    print(paste("Iteration:", iter))
    
    # Initialize for current iteration
    cur_selected_x <- c()
    cur_acc_log <- c()
    
    # ---- Feature selection across splits ----
    for (fold in 1:nfold){
      # Progress 
      print(paste("Feature selection in fold:", fold))
      
      x_ho <- splits[[fold]]$x_ho  # Test features
      y_ho <- splits[[fold]]$y_ho  # Test labels
      x_trn <- splits[[fold]]$x_trn  # Train features
      y_trn <- splits[[fold]]$y_trn   # Train labels
      
      # ---- Cross validation ----
      # Step 1: Fit model using CV to find the best lambda
      cv_fit <- cv.glmnet(x_trn, y_trn, family = "multinomial", alpha = alpha)  # Cross-validate with train set
      best_lambda <- cv_fit$lambda.min  # Select the best lambda
      
      # Step 2: Refit the model using the best lambda
      final_fit <- glmnet(x_trn, y_trn, family = "multinomial", alpha = alpha, lambda = best_lambda)
      
      # Step 3: Predict on the holdout/test set
      preds <- predict(final_fit, newx = x_ho, type = "class")
      
      # Step 4: Calculate accuracy
      acc <- mean(preds == y_ho)
      cur_acc_log <- append(cur_acc_log, acc)
      
      # Select features (names)
      fold_selected_x <- get_selected_feats(final_fit)
      cur_selected_x <- append(cur_selected_x, fold_selected_x)
    }
    
    # ---- Judgement for termination ----
    cur_acc_ave <- mean(cur_acc_log)
    if (cur_acc_ave <= threshold){
      print("Accuracy <= p(guess). Terminate the iteration.")
      break
    }
    print(paste("Current accuracy is", cur_acc_ave))
    # Record accuracy of current iteration
    acc_log <- append(acc_log, cur_acc_ave)
    
    # ---- Feature Selection and Update ----
    # Make selected features unique
    cur_selected_x <- unique(cur_selected_x)
    # Record # selected features
    num_selected_log <- append(num_selected_log, length(cur_selected_x))
    # Show how many features are selected
    print(paste(length(cur_selected_x), "features selected in cur iter."))
    
    # Select features and add to total, once it shows non-zero in one split
    selected_x <- append(selected_x, cur_selected_x)
    
    # Update the rest available features across all splits
    for (fold in 1:nfold){
      splits[[fold]]$x_ho  <- splits[[fold]]$x_ho[, setdiff(colnames(splits[[fold]]$x_ho), cur_selected_x), drop = FALSE]# Test features
      splits[[fold]]$x_trn <- splits[[fold]]$x_trn[, setdiff(colnames(splits[[fold]]$x_trn), cur_selected_x), drop = FALSE]# Train features
    }
  }
  
  # Final selected features
  selected <- x[, selected_x, drop = FALSE]
  
  # Return
  list(accuracies = acc_log, selected = selected, num_selected = num_selected_log)
}