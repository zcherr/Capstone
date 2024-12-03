# Date: 2024-11-21
# Author: Zihan

train_test_split <- function(x, y, nho, alpha=1, type="class", balance=F, seed=42){
#############################################################################
# This function generates trn/test (mainly) for (glmnet) classification task.
# In lasso mode, it generates randomly sample. (may not be balanced)
# In L2 mode, it generates balanced sample for each category.
# 
# Input:
# x, y - full data
# nho - number of hold out data
# alpha - regularization in glmnet
# type - type of the task
# balance - whether balance the num of diff cats in test data
# seed - random seed
# 
# Output:
# (call as  "<obj>$<output_arg>" when used)
# ho_x, ho_y - hold out data
# trn_x, trn_y - training data
############################################################################
  
  # Initialization for randomness
  set.seed(seed)
  
  # Split train/test data
  n <- nrow(x)
  # Check if there are enough data
  if (n < nho) {
    stop(paste("Not enough data to split", n, "(actual) <", nho, "(desired hold-out)"))
  }
  
  if (!balance | type == "regression"){
    
    ho_indices <- sample(1:n, size = nho)  # Holdout/test indices
    ho_x <- x[ho_indices, ]  # Test features
    ho_y <- y[ho_indices]    # Test labels
    trn_x <- x[-ho_indices, ]  # Train features
    trn_y <- y[-ho_indices]    # Train labels
    
  } else if (balance){
    
    ncats <- length(unique(y))  # Number of unique classes
    neach <- nho %/% ncats      # Number of samples per class
    indices_test <- c()         # To store test indices
    
    for (cat in 1:ncats) {
      # Get the actual class label from unique(y)
      class_label <- unique(y)[cat]
      # Get indices for the current class
      class_indices <- which(y == class_label)
      # Check if there are enough samples in this class
      if (length(class_indices) < neach) {
        stop(paste("Not enough samples in class", class_label, "to allocate", neach, "test samples."))
      }
      # Sample from current class
      indices_test <- append(indices_test, sample(class_indices, size = neach))
    }
    
    # Finalize test and train splits
    ho_x <- x[indices_test, ]  # Test features
    ho_y <- as.character(y[indices_test])    # Test labels; char is compatible with glmnet results
    trn_x <- x[-indices_test, ]  # Train features
    trn_y <- as.character(y[-indices_test])    # Train labels
  }
  
  # Return the divided data sets
  list(trn_x = trn_x, trn_y = trn_y, ho_x = ho_x, ho_y = ho_y)
  
}