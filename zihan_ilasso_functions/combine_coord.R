# Date: 2024-11-22
# Author: Zihan

combine_coord <- function(coefs, coord, feat_colname = "feature"){
##############################################################################
# This function combines the beta coefficients with coordinates of the voxels.
# 
# Input:
# coefs - coefs of categories, matrix (will be coerced as df)
# coord - coordinates of voxels, matrix, string
# feat_colname - column name of the features
# Output:
# combined_df - df obj combining the coefs and coordinates w/ new feat col
##############################################################################
  
  # Select/join data; `merge` will handle them auto as df
  combined_df <- merge(coefs, coord, by=0) 
  colnames(combined_df)[1] <- feat_colname
  
  combined_df
  
}