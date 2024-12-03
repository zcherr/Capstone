# Date: 2024-11-25
# Author: Zihan Li

# Dependencies
library(rsample)

cv_splits <- function(x, y, nfold=10, seed=42){
###################################################################
# This function split input data into n folds.
# Splits are stratified by label classes.
#
# Input:
# x - features
# y - labels
# 
# Output:
# (usage eg: splits[[i]]$x_ho)
# splits - list of splited data
# x's - matrix
# y's - factor
###################################################################
  
  # Randomness control
  set.seed(seed)
  
  # split data
  folds <- vfold_cv(data.frame(x, class = y), v = nfold, strata = "class")
  splits <- c()
  
  for (i in 1:nfold){
    # Extract indices
    trn_index <- folds$splits[[i]]$in_id
    tst_index <- setdiff(1:length(y), trn_index)
    
    # Split data (w/ feature names)
    split <- list(
      x_trn = x[trn_index, ],
      y_trn = y[trn_index],
      x_ho = x[tst_index, ],
      y_ho = y[tst_index]
    )
  
    # Append split to the splits list
    splits[[i]] <- split
  }
 
  # Return
  splits
}