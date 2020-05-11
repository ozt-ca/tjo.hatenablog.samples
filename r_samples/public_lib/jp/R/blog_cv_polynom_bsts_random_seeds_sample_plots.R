library(bsts) # Call BSTS

n <- 360 # Length of each random walk
r_mean <- 0 # Mean of each random walk
r_sd <- 20 # SD of each random walk
r_int <- 1000 # Intercept of each random walk

x <- 1:n # x vector: a basic component of independent variable
l_range <- 1:300 # Range of learning dataset
t_range <- 301:360 # Range of test dataset
dcap <- 20 # Maximum limit of degree: default is 20

q_range <- 101:300 # Range of random seeds: of course you can change this range
p_range <- sample(q_range, 4, replace = F)

png('cv_polynom_bsts_seeds.png', width = 1600, height = 900)
par(mfrow = c(2, 2))

# Loop for each random seed
for (p in p_range){
  
  set.seed(p) # Set a random seed
  print(paste0(p, 'th loop'))
  
  y <- cumsum(rnorm(n, r_mean, r_sd)) + r_int # Generate a random walk
  y_range <- c(min(y) - (max(y) - min(y)) * 0.2, max(y) + (max(y) - min(y)) * 0.2)
  
  # Set up a data frame for each total dataset
  d <- data.frame(y = y, 
                  x1 = x, x2 = x^2, x3 = x^3, x4 = x^4, x5 = x^5,
                  x6 = x^6, x7 = x^7, x8 = x^8, x9 = x^9, x10 = x^10,
                  x11 = x^11, x12 = x^12, x13 = x^13, x14 = x^14, x15 = x^15,
                  x16 = x^16, x17 = x^17, x18 = x^18, x19 = x^19, x20 = x^20
  )
  d_learn <- d[l_range, ] # Learn dataset, 1:300
  d_train <- d_learn[1:(round(0.8 * nrow(d_learn))),] # Training
  d_val <- d_learn[(round(0.8 * nrow(d_learn)) + 1):nrow(d_learn),] # Validation
  
  # CV procedure
  res <- rep(0, 20) # 20 steps CV
  for (j in 1:20){
    # Polynomial fitting with increasing the degree
    fit <- lm(y ~., d_train[, 1:(1 + j)])
    res[j] <- rmse(d_val$y, predict(fit, d_val[, 1:(1 + j)])) # Record RMSE
  }
  idx <- which(res == min(res)) # Choose the best one with the least RMSE
  
  fit_best <- lm(y ~ ., d_train[, 1:(2 + idx)]) # Best polynomial fitting model
  fit_all <- lm(y ~ ., d_train[, 1:(dcap + 1)]) # Full polynomial fitting model
  
  # Fit BSTS model with local level + random walk
  ss1 <- AddLocalLevel(list(), d_learn$y)
  fit_bs_ll <- bsts(d_learn$y, ss1, niter = 500)
  # Fit BSTS model with local linear trend
  ss2 <- AddLocalLevel(list(), d_learn$y)
  ss2 <- AddLocalLinearTrend(ss2, d_learn$y)
  fit_bs_lt <- bsts(d_learn$y, ss2, niter = 500)
  
  print(paste0(p, 'th loop'))
  
  newdata <- d[t_range, ] # Test dataset, 301:360
  # Prediction by the best model
  pred_best <- predict(fit_best, newdata = newdata[, 1:(2 + idx)])
  # Prediction by the full model
  pred_all <- predict(fit_all, newdata = newdata[, 1:(dcap + 1)])
  # Prediction by BSTS model with local level + random walk
  pred_bs_ll <- predict(fit_bs_ll, horizon = length(t_range), burn = 100)
  # Prediction by BSTS model with local linear trend
  pred_bs_lt <- predict(fit_bs_lt, horizon = length(t_range), burn = 100)

  plot(d_learn$x1, d_learn$y, type = 'l', xlim = c(0, n), ylim = y_range, col = 'black',
       xlab = '', ylab = '', main = paste0('Random seed ', p))
  par(new = T)
  plot(newdata$x1, newdata$y, type ='l', xlim = c(0, n), ylim = y_range, col = 'blue',
       xlab = '', ylab = '', lwd = 3, lty = 2)
  par(new = T)
  plot(newdata$x1, pred_best, type = 'l', xlim = c(0, n), ylim = y_range, col = 'red',
       xlab = '', ylab = '', lwd = 2)
  par(new = T)
  plot(newdata$x1, pred_all, type = 'l', xlim = c(0, n), ylim = y_range, col = 'green',
       xlab = '', ylab = '', lwd = 2)
  par(new = T)
  plot(newdata$x1, pred_bs_ll$mean, type = 'l', xlim = c(0, n), ylim = y_range,
       col = 'orange', xlab = '', ylab = '', lwd = 2)
  par(new = T)
  plot(newdata$x1, pred_bs_lt$mean, type = 'l', xlim = c(0, n), ylim = y_range,
       col = 'purple', xlab = '', ylab = '', lwd = 2)
  legend('bottomleft', legend = c('Train + Val', 'Test', 'Polynom w/ CV', 'Polynom w/o CV',
                               'BSTS local level', 'BSTS local linear trend'),
         lty = c(1, 3, 1, 1, 1, 1), lwd = c(1, 3, 2, 2, 2, 2),
         col = c('black', 'blue', 'red', 'green', 'orange', 'purple'),
         cex = 1.5, ncol = 2)
  segments(l_range[length(l_range)], y_range[1],
           l_range[length(l_range)], y_range[2], col = 'black', lty = 3)
}
dev.off()