# Date: 2024-11-29
# Author: Zihan Li

# Dependencies
library(dplyr)

individual_data_div <- function(data_path, stim_file, coord_file){
##########################################################################
# This file is used for division of all data
# Put stim + voxel_activation + coord data of each subject into 
# individual folders under the data_path directory
##########################################################################
  
  # Read in files
  stim_data <- read.csv(file.path(data_path, stim_file))
  coord_data <- read.csv(file.path(data_path, coord_file))
  colnames(coord_data) <- c("x", "y", "z", "subject")
  
  # Split the data by subject
  stim_list <- split(stim_data, stim_data$subject)
  coord_list <- split(coord_data, coord_data$subject)
  
  for (id in names(stim_list)) {
    
    # divide stim data
    formatted_id <- sprintf("%02d", as.numeric(id))  # Format as "jlpxx.csv" data files
    folder_name <- file.path(data_path, paste0("jlp", formatted_id))  # Create folder path under data_path
    dir.create(folder_name, showWarnings = FALSE)  # If not existing, create the folder
    
    file_name <- file.path(folder_name, paste0("stim", formatted_id, ".csv"))  # Create full file path
    write.csv(stim_list[[id]], file_name, row.names = FALSE)  # Save individual stim file
    
    # copy voxel data
    voxel_data <- read.csv(file.path(data_path, paste0("jlp", formatted_id, ".csv")))
    file_name <- file.path(folder_name, paste0("jlp", formatted_id, ".csv"))
    write.csv(voxel_data, file_name, row.names = FALSE)
    
    # divide coord data
    file_name <- file.path(folder_name, paste0("coord", formatted_id, ".csv"))  # Create full file path
    write.csv(coord_list[[id]], file_name, row.names = FALSE)  # Save individual coord file
  }
  
  print(paste("Individual data of voxel signal, stimuli and coordinates information have been created in: ", data_path))
}




