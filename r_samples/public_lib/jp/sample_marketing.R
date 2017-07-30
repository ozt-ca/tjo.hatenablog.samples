d <- read.csv('sample_marketing.csv')
dvar <- d[,-1]
dat <- list(N=nrow(d), M=ncol(dvar), y=d$cv, X=dvar)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
fit <- stan(file='sample_marketing.stan', data=dat, iter=1000, chains=4)
slength <- 2000
dvar <- d[,-1]
fit.smp<-extract(fit)
t_d<-density(fit.smp$d_int)
d_int<-t_d$x[t_d$y==max(t_d$y)]
beta<-rep(0,ncol(dvar))
for (i in 1:ncol(dvar)) {
	tmp<-density(fit.smp$beta[(slength*(i-1)+1):(slength*i)])
	beta[i]<-tmp$x[tmp$y==max(tmp$y)]
  }
trend<-rep(0,nrow(dvar))
for (i in 1:nrow(dvar)) {
	tmp<-density(fit.smp$trend[,i])
	trend[i]<-tmp$x[tmp$y==max(tmp$y)]
  }
season<-rep(0,nrow(dvar))
for (i in 1:nrow(dvar)) {
	tmp<-density(fit.smp$season[,i])
	season[i]<-tmp$x[tmp$y==max(tmp$y)]
  }
beta_prod<-rep(0,nrow(dvar))
for (i in 1:ncol(dvar)){beta_prod<-beta_prod + dvar[,i]*beta[i]}
pred <- d_int + beta_prod + cumsum(trend) + season
matplot(cbind(d$cv, pred), type='l', lty=1, lwd=c(2,3), ylab='')
legend('topleft', legend=c('Data', 'Fitted'), lty=1, lwd=c(2,3), col=c(1,2))