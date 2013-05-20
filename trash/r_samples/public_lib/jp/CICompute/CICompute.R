CICompute <- function(npar,nratio,nboot) {
  Data<-c(rep(1,ceiling(npar*nratio)),rep(0,floor(npar*(1-nratio))))
  Data<-as.matrix(Data)
  
  ResultBoot      <- matrix(NA, nboot, npar)
  
  for(i in 1:nboot){
    BootID          <- sample(1:nrow(Data), nrow(Data), replace = T)
    BootSample      <- Data[BootID, ]
    ResultBoot[i, ] <- mean(BootSample)
  }
  
  (MeanBoot <- mean(ResultBoot[, 1]))
  (SDBoot   <- sd(ResultBoot[, 1]))
  hist(ResultBoot)
  
  ci_low<-MeanBoot - 1.96*SDBoot
  ci_up<-MeanBoot + 1.96*SDBoot
  return(list(MeanBoot=MeanBoot,SDBoot=SDBoot,ci_low=ci_low,ci_up=ci_up,ResultBoot=ResultBoot))
}