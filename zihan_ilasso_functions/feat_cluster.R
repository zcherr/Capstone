# Date: 2024-11-23
# Author: Zihan Li

# Dependencies
library(cluster)
library(tidyverse)

feat_cluster <- function(df, cols=NULL, method = "ward.D2", ncluster=length(cols), seed=42){
############################################################################
# This function implement hierarchical clusters of data.
# The clustering is based on specified parameter columns.
#
# Input:
# df - data containing paramters to cluster on
# cols - columns of clustering criteria info, vector/list
# method - clustering computation method, see doc of `cluster`
# ncluster = number of desired clusters, by default the length of the cols
#
# Output:
# hc - `hclust` obj
# data_clustered - df obj with additional tag col of the clustering result
############################################################################
  
  # Create clustering based on Euclidean distance
  hc <- hclust(dist(df[cols]), method = method)
  # Cut cluster branches and insert to data
  df$cluster <- cutree(hc, k=ncluster)
  df_summary <- NULL
  data_clusterd <- NULL
  
  # With specifed 
  if (!is.null(cols)){
    # Calculate average 
    df_summary <- df |> pivot_longer(cols = cols,
                       names_to = "class",
                       values_to = "value") |> 
      group_by(cluster, class) |> 
      summarize(mean_value = mean(value), .groups = "drop")
    
    # Generate cluster-feat category mapping pair
    pairs <- df_summary |> 
      group_by(cluster) |> 
      slice_max(mean_value, 
                n = 1,
                with_ties = F) |> 
      select(cluster, class)
      
    # Insert back a feature category column according to the cluster
    df_clustered <- df |> 
      left_join(pairs, by = "cluster") |> 
      select(-cluster) |> 
      mutate(cluster = setNames(seq_along(cols), cols)[class]) # The numeric cluster is consistent as long as input `cols` is consistent
    
    # Mismatch between cols and ncluster means special cases, recompute the means
    if (length(cols) != ncluster){
      df_summary <- df |> pivot_longer(cols = cols,
                                       names_to = "class",
                                       values_to = "value") |> 
        group_by(cluster, class) |> # The cluster has been reassigned
        summarize(mean_value = mean(value), .groups = "drop")
    }
  }
  else{
    stop("Error: No feature column(s) specified for clustering.")
  }

  # Return
  # If no cols input; only return the cluster obj
  return(list(hc = hc, summary = df_summary, data_clustered=df_clustered))
  
}


# NOTEs on `ncluster`:
# This could help solve the issue of weird dominating voxel leaning toward
# category and set the rest neighbors wrongly to another category, by 
# assigning them to single category and combine with neighbor branch.



