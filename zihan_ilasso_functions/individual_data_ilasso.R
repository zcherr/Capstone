# Date: 2024-11-29
# Author: Zihan Li

individual_data_process <- function(data, nfold = 10, 
                                    max_iter = 10, seed = 137, 
                                    cache_dir = "./cache", nho=10, 
                                    use_cache = T, save_cache = T) {
########################################################################
# This is the pipe trains models to select voxels from individual data.
# Lasso fitting could be cached optionally.
#
# Input:
# data - list containing data of all subjects (feature-label; coord)
# nfold - # folds in L1 CV selection
# max_iter - # anticipated max iteration
# seed - random seed
# cache_dir - directory for caching
# nho - # test items in final L2 fitting
# use_cache - whether use cached L1/lasso model
# save_cache - whether save current L1/lasso model in cache dir
#
# Output:
# data - list containing data of all subjects
# Added:
# (1) selected features with coefficients, clustered into categories
# (2) accuracy log in lasso fitting
# (3) # selected log in lasso fitting
#########################################################################
  
  # Create the cache directory if it doesn't exist
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir)
  }
  
  names <- names(data)
  
  for (i in 1:length(names)) {
    
    subject_name <- names[i]
    
    # Initialize progress display
    flush.console()
    print(paste("Processing for subject:", subject_name))
    
    x <- data[[i]]$x
    y <- data[[i]]$y
    coord <- data[[i]]$coord
    
    # Cache file path for the subject
    cache_file <- file.path(cache_dir, paste0("l1_fit_", subject_name, ".rds"))
    
    if (use_cache && file.exists(cache_file)) {
      # Use cache if the file exists and use_cache is TRUE
      print("Loading cached L1 fit results...")
      l1_fit <- readRDS(cache_file)
    } 
    else {
      # Recompute L1 fit if no cache exists or use_cache is FALSE
      print("Running L1 fit (Voxels Selection):")
      l1_fit <- iter_lasso_cv_full(x, y, nfold = nfold, max_iter = max_iter, seed = seed)
      
      # Save to cache if save_cache is TRUE
      if (save_cache) {
        saveRDS(l1_fit, cache_file)
      }
    }
    
    # Indicate progress with the # voxels selected
    flush.console()
    print(paste("# Total voxels Selected:", ncol(l1_fit$selected)))
    
    # Subsequent processing (L2 fitting, Coordinates combining, clustering)
    print("L2 Fitting:")
    l2_fit <- cv_hoacc(l1_fit$selected, y, nho = nho, balance = T, alpha = 0)
    print(paste("Accuracy:", l2_fit$accuracy))
    
    print("Combining Coordinates:")
    result <- combine_coord(get_coefs(l2_fit$m), coord, feat_colname = "voxel")
    
    print("Clustering:")
    result_tagged <- feat_cluster(result, cols = c("face", "place", "object"), ncluster = 3)
    
    # Add result to data
    print(paste("Finished processing:", subject_name))
    data[[i]]$result <- result_tagged
    data[[i]]$lasso_accuracies <- l1_fit$accuracies
    data[[i]]$lasso_num_feats <- l1_fit$num_selected
  }
  
  # return
  data
}
