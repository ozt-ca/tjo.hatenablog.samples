CICompute <- function(npar,nratio,nboot) {
# npar: Sample size
# nratio: A ratio assumed as the real ratio
# nboot: The number of iteration for bootstrap resampling

  Data<-c(rep(1,ceiling(npar*nratio)),rep(0,floor(npar*(1-nratio))))
  Data<-as.matrix(Data)
  
  ResultBoot      <- matrix(NA, nboot, npar)
  
  for(i in 1:nboot){
    BootID          <- sample(1:nrow(Data), nrow(Data), replace = T)
    BootSample      <- Data[BootID, ]
    ResultBoot[i, ] <- mean(BootSample)
  }
  
  (MeanBoot <- mean(ResultBoot[, 1])) # Estimated ratio
  (SDBoot   <- sd(ResultBoot[, 1])) # Estimated SD of the ratio
  hist(ResultBoot) # Plotting a histogram of the bootstrap samples
  
  ci_low<-MeanBoot - 1.96*SDBoot # Lower bound of 95% CI
  ci_up<-MeanBoot + 1.96*SDBoot # Upper bound of 95% CI
  return(list(MeanBoot=MeanBoot,SDBoot=SDBoot,ci_low=ci_low,ci_up=ci_up,ResultBoot=ResultBoot))
}