d <- read.csv('sample_marketing.csv')
d <- d[1:98,] # Adjust the length of the dataset to 7days seasonality
tl <- 7 # length of test period
validate <- rep(0,tl)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
for (k in 1:tl)
{
d_train <- d[1:(nrow(d)-tl+k-1),]
d_test <- d[(nrow(d)-tl+k),-1]
dvar <- d_train[,-1]
dat <- list(N=nrow(dvar), M=ncol(dvar), y=d_train$cv, X=dvar)

fit <- stan(file='sample_marketing.stan', data=dat, iter=1000, chains=4, verbose=F)

slength <- 2000
fit.smp<-extract(fit)

t_s<-density(fit.smp$s_trend)
s_trend<-t_s$x[t_s$y==max(t_s$y)]
t_s<-density(fit.smp$s_season)
s_season<-t_s$x[t_s$y==max(t_s$y)]
t_s<-density(fit.smp$s_q)
s_q<-t_s$x[t_s$y==max(t_s$y)]

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

val_trend <- rep(0,3)
for (i in 1:2)
{
	val_trend[i] <- trend[nrow(d_train)-i]
}
val_trend[3] <- 2*val_trend[2] - val_trend[1] + rnorm(1,0,s_trend)

val_season <- season[k] + rnorm(1,0,s_season)

validate[k] <- d_int + cumsum(trend)[nrow(d_train)] + sum(d_test*beta) + val_trend[3] + val_season
}

(rmse <- sqrt(sum((validate-d$cv[(nrow(d)-tl+1):nrow(d)])^2) / tl))
matplot(cbind(d$cv[(nrow(d)-tl+1):nrow(d)], validate), type='l', lty=1, lwd=c(2,3), ylab='')
legend('topleft', legend=c('Validate', 'Predict'), lty=1, lwd=c(2,3), col=c(1,2))
