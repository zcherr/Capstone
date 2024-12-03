#Function to estimate hold-out accuracy for l1-regularization classification
cv_accuracy <- function(x, y, num_hold_out, alpha=1){
  # x = input matrix
  # y = factor containing category label for each row of x
  # num_hold_out = number of items to hold out for test
  
  nitems <- dim(x)[1] #Number of items in x matrix
  
  tstitems <- sample(nitems,num_hold_out) #Choose nho items at random for hold-out set
  trnitems <- setdiff(c(1:nitems), tstitems) #Use remaining items for training set
  
  #Put test items in the test set
  x_tst <- x[tstitems,] 
  y_tst <- y[tstitems]
  
  #Put remaining items in the training set
  x_trn <- x[trnitems,] # the data type looks diff from `x_tst`, due to the size
  y_trn <- y[trnitems]
  
  #Search for best lambda
  lam <- cv.glmnet(x = x_trn, y = y_trn, family = "multinomial", alpha=alpha)$lambda.min
  
  #Refit model using chosen lambda
  m <- glmnet(x = x_trn, y = y_trn, family = "multinomial", lambda = lam, alpha=alpha)
  
  #Predict class label for test items
  pclass <- predict(m, x_tst, type = "class")
  
  return(c(lam, mean(pclass==y_tst))) #Return selected lambda and mean proportion correct on hold-outs 
}