# Date: 2024-11-22
# Author: Zihan

get_coefs <- function(m){
##########################################################################
# This function extracts the beta coefficients of given glmnet model.
# 
# Input:
# m - fitted glmnet model, `glmnet` model obj
# Output:
# coefs - coefs of categories, matrix
##########################################################################
  
  # Number of the categories of the labels
  ncats <- length(m$beta)
  coefs <- NULL
  
  # Combine the coefs together in order
  for (cat in 1:ncats){
    coefs <- cbind(coefs, m$beta[[cat]])
  }
  # Rename the header
  colnames(coefs) <- rownames(m$dfmat)
  
  # Return
  coefs <- as.matrix(coefs)
  coefs
}