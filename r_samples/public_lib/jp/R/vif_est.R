# Computing Variance Inflation Factors for a single dataset
# d: data frame
# y_idx: index of dependent (target) variable which can be omitted

vif_est <- function(d, y_idx = NULL){
  d1 <- d
  if (!is.null(y_idx)){
    d1 <- d[, -y_idx]
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