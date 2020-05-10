library(Metrics)

n <- 360
x <- 1:n

k <- 100
cv <- rep(0, k)
ncv <- rep(0, k)

for (q in 1:k){
  set.seed(q)
  y <- cumsum(rnorm(360, 0, 20)) + 1000
  d <- data.frame(y = y, 
                  x1 = x, x2 = x^2, x3 = x^3, x4 = x^4, x5 = x^5,
                  x6 = x^6, x7 = x^7, x8 = x^8, x9 = x^9, x10 = x^10,
                  x11 = x^11, x12 = x^12, x13 = x^13, x14 = x^14, x15 = x^15,
                  x16 = x^16, x17 = x^17, x18 = x^18, x19 = x^19, x20 = x^20
  )
  d_learn <- d[1:300, ]
  d_train <- d_learn[1:(round(0.8 * nrow(d_learn))),]
  d_val <- d_learn[(round(0.8 * nrow(d_learn)) + 1):nrow(d_learn),]
  
  res <- rep(0, 20)
  for (j in 1:20){
    fit <- lm(y ~., d_train[, 1:(1 + j)])
    res[j] <- rmse(d_val$y, predict(fit, d_val[, 1:(1 + j)]))
  }
  idx <- which(res == min(res))
  fit_best <- lm(y ~ ., d_train[, 1:(2 + idx)])
  fit_all <- lm(y ~ ., d_train)
  newdata <- d[301:360, ]
  pred_best <- predict(fit_best, newdata = newdata[, 1:(2 + idx)])
  pred_all <- predict(fit_all, newdata = newdata)
  cv[q] <- rmse(pred_best, newdata$y)
  ncv[q] <- rmse(pred_all, newdata$y)
}
boxplot(cv, ncv, names = c('With CV', 'Without CV'))
t.test(cv, ncv)
