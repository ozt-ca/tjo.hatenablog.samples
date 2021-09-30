# Computing Variance Inflation Factors for a single dataset
# Simple implementation: just run this script to use the function below
#
# Arguments
# d: data frame
# idx: index of dependent (target) variable which can be omitted

vif <- function(d, idx = NULL){
  d1 <- d
  if (!is.null(idx)){
    d1 <- d[, -idx]
  }
  dnam <- names(d1)
  m <- ncol(d1)
  
  fm <- c()
  for (i in 1:m){
    fm[[i]] <- as.formula(paste(paste(dnam[i], '~'), paste(dnam[-i], collapse = '+')))
  }
  
  vif_val <- data.frame(var = dnam, vif = 0)
  for (i in 1:m){
    vif_val$vif[i] <- 1 / ( 1- summary(lm(fm[[i]], d1))$r.square)
  }
  return(vif_val)
}