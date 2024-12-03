
# This is the pipe reads in otiginal data

individual_data_read <- function(){
  
  data <- c()
  
  subjects <- c(paste0("0", 3:9), 10)
  
  for (subj in subjects){
    path <- paste0("./fpo_data_all/jlp", subj)
    
    stim_file <- paste0("stim", subj, ".csv")
    voxel_file <- paste0("jlp", subj, ".csv")
    coord_file <- paste0("coord", subj, ".csv")
    
    stim <- read.csv(file.path(path, stim_file))
    voxel <- read.csv(file.path(path, voxel_file), header=F)
    coord <-  read.csv(file.path(path, coord_file)) |> as.matrix()
    
    rownames(coord) <- c(paste0(1:nrow(coord)))
    colnames(voxel) <- c(paste0(1:ncol(voxel)))
    
    x <- as.matrix(voxel)
    y <- factor(stim$category, levels = c("face", "place", "object"))
    
    subj_data <- list(x = x, y = y, coord = coord)
    data[[paste0("subj",subj)]] <- subj_data
  }
  
  print("Data of all subjects have been read in an integrated list.")
  
  # return
  data
}