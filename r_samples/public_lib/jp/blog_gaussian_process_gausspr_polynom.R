library(kernlab)
x <- seq(-10, 10, length.out = 300)
set.seed(51)
y <- -1e-3 * x * (x + 9) * (x - 1) * (x - 9) + rnorm(300, 0, 0.5)
y_true <- -1e-3 * x * (x + 9) * (x - 1) * (x - 9)
plot(x, y, xlim = c(-11, 11), ylim = c(-3, 3), xlab = '', ylab = '')
lines(x, y_true, type = 'l', col = 'blue', lwd = 2)
d <- data.frame(x = x, y = y)
set.seed(71)
d1 <- d[sample(300, 50, replace = F),]
fit <- gausspr(y~x, d1)
fit
y_pred <- predict(fit, d)
par(new = T)
plot(d1$x, d1$y, pch = 19, col = 'purple',
     xlim = c(-11, 11), ylim = c(-3, 3), xlab = '', ylab = '')
lines(x, y_pred, type = 'l', col = 'red', lwd = 3)

library(e1071)
fit_svm <- svm(y~x, d1)
y_pred_svm <- predict(fit_svm, d)
lines(x, y_pred_svm, type = 'l', col = '#008000', lwd = 3)

legend('bottom', legend = c('True', 'GP', 'SVM'),
       col = c('blue', 'red', '#008000'), lwd = c(2, 3, 3))