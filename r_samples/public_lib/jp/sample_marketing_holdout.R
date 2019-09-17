# Data preparation

d <- read.csv('sample_marketing.csv')
d_train <- d[1:91, ]
d_test <- d[92:100, ]
dvar <- d_train[, -1]
dat <- list(N = nrow(d_train), M = ncol(dvar),
            y = d_train$cv, X = dvar)

# Time series modeling with Bayesian

library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
fit <- stan(file = 'sample_marketing_holdout.stan', data = dat,
            iter = 1000, chains = 4)

# Extract samples / parameters, and estimate fitted values

slength <- 2000
fit.smp <- extract(fit)
tmp <- density(fit.smp$s_trend)
s_trend <- tmp$x[tmp$y == max(tmp$y)]
tmp <- density(fit.smp$s_season)
s_season <- tmp$x[tmp$y == max(tmp$y)]
tmp <- density(fit.smp$s_q)
s_q <- tmp$x[tmp$y == max(tmp$y)]
beta <- rep(0, ncol(dvar))
for (i in 1:ncol(dvar)) {
  tmp <- density(fit.smp$beta[(slength * (i - 1) + 1) : (slength * i)])
  beta[i] <- tmp$x[tmp$y == max(tmp$y)]
}
trend <- rep(0, nrow(dvar))
for (i in 1:nrow(dvar)) {
  tmp <- density(fit.smp$trend[, i])
  trend[i] <- tmp$x[tmp$y == max(tmp$y)]
}
season <- rep(0, nrow(dvar))
for (i in 1:nrow(dvar)) {
  tmp <- density(fit.smp$season[,i])
  season[i] <- tmp$x[tmp$y == max(tmp$y)]
}
beta_prod<-rep(0, nrow(dvar))
for (i in 1:ncol(dvar)) {
  beta_prod <- beta_prod + dvar[, i] * beta[i]
}
pred <- beta_prod + cumsum(trend) + season
matplot(cbind(d_train$cv, pred), type = 'l', lty = 1,
        lwd = c(2, 3), ylab = '', xlim = c(0, 100), ylim = c(180, 980))
legend('topleft', legend = c('Data', 'Fitted'),
       lty = 1, lwd = c(2, 3), col = c(1, 2))

# Validation

fc_dvar <- d_test[, -1]

val_trend <- rep(0, nrow(fc_dvar))
for (i in 1:2) {
  val_trend[i] <- trend[nrow(d_train) - 3 + i]
}
for (i in 3:nrow(fc_dvar)){
  val_trend[i] <- 2 * val_trend[i - 1] - val_trend[i - 2] + rnorm(1, 0, s_trend)
}

val_season <- season[(length(season) - 14 + 1):(length(season) - 14 + nrow(fc_dvar))] + rnorm(nrow(fc_dvar), 0, s_season)

fc_beta_prod <- rep(0, nrow(fc_dvar))
for (i in 1:ncol(fc_dvar)) {
  fc_beta_prod <- fc_beta_prod + fc_dvar[, i] * beta[i]
}

validate <- cumsum(trend)[nrow(d_train)] + fc_beta_prod + cumsum(val_trend) + val_season

# Machine learning: Random Forest

library(randomForest)
d_train.rf <- randomForest(cv~., d_train)
pred.rf <- predict(d_train.rf, newdata = d_train[, -1])
validate.rf <- predict(d_train.rf, newdata = d_test[, -1])

# Plotting w/o days

matplot(cbind(d_train$cv, pred, pred.rf), type = 'l', lty = 1,
        lwd = c(2, 3, 3), ylab = '', xlim = c(0, 100), ylim = c(150, 1050))
segments(91, 0, 91, 1100, lty = 3, col = 1, lwd = 2)
par(new = T)
matplot(cbind(d_test$cv, validate, validate.rf), type = 'l', lty = 1,
        col = c('blue', 'purple', '#008000'),
        lwd = c(2, 3, 3), ylab = '', xlim = c(-91, 9), ylim = c(150, 1050),
        axes = F)
legend('topleft', legend = c('Data', 'Fitted TS', 'Fitted RF',
                             'Actual', 'Forecast TS', 'Forecast RF'),
       lty = 1, lwd = rep(c(2, 3, 3), 2),
       col = c(1, 2, 3, 'blue', 'purple', '#008000'),
       ncol = 2, cex = 0.75)

# RF w/ days

d_day <- cbind(d, rep(c('Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat', 'Sun'), 15)[1:nrow(d)])
names(d_day)[5] <- 'day'
day_train <- d_day[1:91, ]
day_test <- d_day[92:100, ]
day_train.rf <- randomForest(cv~., day_train)
pred.rfday <- predict(day_train.rf, newdata = day_train[, -1])
validate.rfday <- predict(day_train.rf, newdata = day_test[, -1])

# Plotting w/ days

matplot(cbind(d_train$cv, pred, pred.rfday), type = 'l', lty = 1,
        lwd = c(2, 3, 3), ylab = '', xlim = c(0, 100), ylim = c(150, 1050))
segments(91, 0, 91, 1100, lty = 3, col = 1, lwd = 2)
par(new = T)
matplot(cbind(d_test$cv, validate, validate.rfday), type = 'l', lty = 1,
        col = c('blue', 'purple', '#008000'),
        lwd = c(2, 3, 3), ylab = '', xlim = c(-91, 9), ylim = c(150, 1050),
        axes = F)
legend('topleft', legend = c('Data', 'Fitted TS', 'Fitted RF w day',
                             'Actual', 'Forecast TS', 'Forecast RF w day'),
       lty = 1, lwd = rep(c(2, 3, 3), 2),
       col = c(1, 2, 3, 'blue', 'purple', '#008000'),
       ncol = 2, cex = 0.75)

# Evaluation

library(Metrics)
rmse(d_test$cv, validate) # Bayesian TS
rmse(d_test$cv, validate.rf) # RF w/o days
rmse(d_test$cv, validate.rfday) # RF w/ days

# Plotting w/ trends

matplot(cbind(d_train$cv, pred, pred.rfday, cumsum(trend)), type = 'l', lty = 1,
        lwd = c(2, 3, 3, 5), ylab = '', xlim = c(0, 100), ylim = c(150, 1050),
        col = c(1, 2, 3, 'orange'))
segments(91, 0, 91, 1100, lty = 3, col = 1, lwd = 2)
par(new = T)
matplot(cbind(d_test$cv, validate, validate.rfday, cumsum(val_trend) + cumsum(trend)[nrow(d_train)]), type = 'l', lty = 1,
        col = c('blue', 'purple', '#008000', 'orange'),
        lwd = c(2, 3, 3, 5), ylab = '', xlim = c(-91, 9), ylim = c(150, 1050),
        axes = F)
legend('topleft', legend = c('Data', 'Fitted TS', 'Fitted RF w day',
                             'Actual', 'Forecast TS', 'Forecast RF w day',
                             'Trend'),
       lty = 1, lwd = rep(c(2, 3, 3, 5), 2),
       col = c(1, 2, 3, 'blue', 'purple', '#008000', 'orange'),
       ncol = 2, cex = 0.75)