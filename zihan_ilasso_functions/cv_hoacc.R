# Date: 2024-11-20
# Author: Zihan, adapted from Tim

cv_hoacc <- function(x, y, nho, alpha=1, type="class", balance=F, seed=42){
########################################################################
# This function will generate the CV accuracy of the given data.
# (1) for ilasso
# (2) for L2 final fitting
#
# Detailed steps:
# - First, split the data into test and test
# - Second, run CV with trn_set and give the best lambda
# - Third, refit with chosen lambda
# - Finally, use refitted model to predict in test(ho)_set for acc
# 
# Input:
# x, y - feats and labels
# nho - number of hold-out items
# alpha - hyperparameter determining the norm; ba default lasso
# type - type of task
# balance - whether control the balance of classes in test data
# seed - controlling the fake randomness
#
# Output: 
# (call as  "<obj>$<output_arg>" when used)
# best_lambda - corresponding lambda
# acc - accuracy
########################################################################
  
  # ---- Split train/test data ----
  split <- train_test_split(x=x, y=y, nho=nho, alpha=alpha, type=type, balance=balance, seed=seed)
  ho_x <- split$ho_x  # Test features
  ho_y <- split$ho_y    # Test labels
  trn_x <- split$trn_x  # Train features
  trn_y <- split$trn_y    # Train labels
  
  # ---- Cross validation ----
  # Step 1: Fit model using CV to find the best lambda
  cv_fit <- cv.glmnet(trn_x, trn_y, family = "multinomial", alpha = alpha)  # Cross-validate with train set
  best_lambda <- cv_fit$lambda.min                 # Select the best lambda
  
  # Step 2: Refit the model using the best lambda
  final_fit <- glmnet(trn_x, trn_y, family = "multinomial", alpha = alpha, lambda = best_lambda)
  
  # Step 3: Predict on the holdout/test set
  preds <- predict(final_fit, newx = ho_x, type = "class")
  
  # Step 4: Calculate accuracy
  acc <- mean(preds == ho_y)
  
  # ---- Output the selected lambda and accuracy ----
  # L1/LASSO: only return the lambda and accuracy
  if (alpha == 1){
    list(lambda = best_lambda, accuracy = acc)
  }
  # L2: return the model also to get the coefs
  else if (alpha == 0){
    # If we're fitting with L2 norm, we also want the final model with ALL data
    final_fit <- glmnet(x, y, family = "multinomial", alpha = alpha, lambda = best_lambda)
    # return
    list(m = final_fit, lambda = best_lambda, accuracy = acc)
  }
}
