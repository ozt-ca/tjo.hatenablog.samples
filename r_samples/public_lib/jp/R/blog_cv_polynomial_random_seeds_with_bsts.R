library(Metrics) # Just for computing RMSE
library(bsts) # Call BSTS

n <- 360 # Length of each random walk
r_mean <- 0 # Mean of each random walk
r_sd <- 20 # SD of each random walk
r_int <- 1000 # Intercept of each random walk

x <- 1:n # x vector: a basic component of independent variable
l_range <- 1:359 # Range of learning dataset
t_range <- 360:360 # Range of test dataset
dcap <- 20 # Maximum limit of degree: default is 20

q_range <- 101:300 # Range of random seeds: of course you can change this range
cv <- rep(0, length(q_range)) # Vector for storing results of polynomial fitting with CV
ncv <- rep(0, length(q_range)) # Vector for storing results of polynomial fitting without CV
bsll <- rep(0, length(q_range)) # Vector for storing results of bsts with local level
bslt <- rep(0, length(q_range)) # Vector for storing results of bsts with local linear trend

# Loop for each random seed
for (q in q_range){
  
  set.seed(q) # Set a random seed
  print(paste0(q, 'th loop'))
  
  y <- cumsum(rnorm(n, r_mean, r_sd)) + r_int # Generate a random walk
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
  
  print(paste0(q, 'th loop'))
  
  newdata <- d[t_range, ] # Test dataset, 301:360
  # Prediction by the best model
  pred_best <- predict(fit_best, newdata = newdata[, 1:(2 + idx)])
  # Prediction by the full model
  pred_all <- predict(fit_all, newdata = newdata[, 1:(dcap + 1)])
  # Prediction by BSTS model with local level + random walk
  pred_bs_ll <- predict(fit_bs_ll, horizon = length(t_range), burn = 100)
  # Prediction by BSTS model with local linear trend
  pred_bs_lt <- predict(fit_bs_lt, horizon = length(t_range), burn = 100)
  
  
  # Store results for each random seed
  cv[q - q_range[1] + 1] <- rmse(pred_best, newdata$y)
  ncv[q - q_range[1] + 1] <- rmse(pred_all, newdata$y)
  bsll[q - q_range[1] + 1] <- rmse(pred_bs_ll$median, newdata$y)
  bslt[q - q_range[1] + 1] <- rmse(pred_bs_lt$median, newdata$y)
}

paste0('cv_', dcap, 'deg_polynom_bsts_random_seeds_',
       q_range[1], '_', q_range[length(q_range)], '.RData')
save.image(paste0('cv_', dcap, 'deg_polynom_bsts_random_seeds_',
                  q_range[1], '_', q_range[length(q_range)], '.RData'))

# Final evaluation
# Boxplot
boxplot(cv, ncv, bsll, bslt,
        names = c('With CV', 'Without CV', 'BSTS local level', 'BSTS local linear trend'))
boxplot(cv, bsll, bslt,
        names = c('With CV', 'BSTS local level', 'BSTS local linear trend'))
t.test(cv, ncv) # Welch's two-sample t-test
wilcox.test(cv, ncv) # Ranksum test
t.test(cv, bsll)
t.test(cv, bslt)