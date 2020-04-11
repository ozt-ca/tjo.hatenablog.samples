n <- 360
x_org <- 1:n
x_org2 <- x_org[1:300]
set.seed(102)
# y_org <- arima.sim(model = list(ar = 0.999, ma = 0.999), n = n) * 100 + 5000
y_org <- cumsum(rnorm(n, 0, 20)) + 1000
par(mfrow = c(1, 1))
plot(y_org[1:30], type = 'l', xlab = '', ylab = '')

library(Metrics)

par(mfrow = c(3, 4))
for (i in 1:10){
  x <- x_org[1:(i * 30)]
  y <- y_org[1:(i * 30)]
  d <- data.frame(y = y, 
                  x1 = x, x2 = x^2, x3 = x^3, x4 = x^4, x5 = x^5,
                  x6 = x^6, x7 = x^7, x8 = x^8, x9 = x^9, x10 = x^10,
                  x11 = x^11, x12 = x^12, x13 = x^13, x14 = x^14, x15 = x^15,
                  x16 = x^16, x17 = x^17, x18 = x^18, x19 = x^19, x20 = x^20
  )

  d_train <- d[1:(round(0.8 * nrow(d))),]
  d_test <- d[(round(0.8 * nrow(d)) + 1):nrow(d),]
  
  res <- rep(0, 20)
  for (j in 1:20){
    fit <- lm(y ~., d_train[, 1:(1 + j)])
    res[j] <- rmse(d_test$y, predict(fit, d_test[, 1:(1 + j)]))
  }
  idx <- which(res == min(res))
  fit_best <- lm(y ~ ., d[, 1:(2 + idx)])
  plot(x, y, type = 'l', xlim = c(0, 360), ylim = c(700, 1500), xlab = '', ylab = '')
  xp <- x_org[1:((i * 30) + 60)]
  newdata = data.frame(x1 = xp, x2 = xp^2, x3 = xp^3, x4 = xp^4,
                       x5 = xp^5, x6 = xp^6, x7 = xp^7, x8 = xp^8,
                       x9 = xp^9, x10 = xp^10, x11 = xp^11, x12 = xp^12,
                       x13 = xp^13, x14 = xp^14, x15 = xp^15, x16 = xp^16,
                       x17 = xp^17, x18 = xp^18, x19 = xp^19, x20 = xp^20)
  pred <- predict(fit_best, newdata = newdata[, 1:(2 + idx)])
  par(new = T)
  plot(xp, pred, type = 'l', col = 'red', lwd = 3, xlim = c(0, 360), ylim = c(700, 1500),
       axes = F, xlab = '', ylab = '')
}
plot(x_org[1:300], y_org[1:300], type = 'l', xlim = c(0, 360), ylim = c(700, 1500),
     xlab = '', ylab = '')
par(new = T)
plot(x_org, pred, type = 'l', col = 'red', lwd = 3, xlim = c(0, 360), ylim = c(700, 1500),
     axes = F, xlab = '', ylab = '')
par(new = T)
plot(x_org[301:n], y_org[301:n], type = 'l', col = 'blue', lwd = 3,
     xlim = c(0, 360), ylim = c(700, 1500), axes = F, xlab = '', ylab = '')
legend('bottomleft', legend = c('Data', 'Predict', 'True'), col = c('black', 'red', 'blue'),
       lwd = c(1, 3, 3), ncol = 2, cex = 0.4)

par(mfrow = c(1, 1))
plot(x_org[1:300], y_org[1:300], type = 'l', xlim = c(0, 360), ylim = c(700, 1500),
     xlab = '', ylab = '')
par(new = T)
plot(x_org, pred, type = 'l', col = 'red', lwd = 3, xlim = c(0, 360), ylim = c(700, 1500),
     axes = F, xlab = '', ylab = '')
par(new = T)
plot(x_org[301:n], y_org[301:n], type = 'l', col = 'blue', lwd = 3,
     xlim = c(0, 360), ylim = c(700, 1500), axes = F, xlab = '', ylab = '')
legend('bottomleft', legend = c('Data', 'Predict', 'True'), col = c('black', 'red', 'blue'),
       lwd = c(1, 3, 3), ncol = 2)