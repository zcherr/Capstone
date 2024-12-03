# Date: 2024-11-21
# Author: Zihan, adapted from Tim

get_selected_feats <- function(m){
############################################################################
# This function extracts non-zero features in fitted glmnet model.
# Input:
# m - fitted model
# Output:
# feats - selected features (names, in a list)
############################################################################
  
  # Get list of model coefficients
  mcoefs <- coef(m)
  ncats <- length(mcoefs) # How many categories were there
  feats <- c() # Initiate column vector for output
  
  # For each output category
  for(i in c(1:ncats)){
    # Extract the coefficients; remove intercept
    cur_coef <- as.matrix(mcoefs[[i]])[-1, , drop = F]
    # Get feature names of non-zero coefficients
    selected <- rownames(cur_coef)[apply(cur_coef, 1, function(row) any(row != 0))] 
    # Append to output vector
    feats <- append(feats, selected) 
  }
  
  # Get unique feature names
  feats <- unique(feats) 
  # Return vector of selected feature names from the model
  feats 
  
}
