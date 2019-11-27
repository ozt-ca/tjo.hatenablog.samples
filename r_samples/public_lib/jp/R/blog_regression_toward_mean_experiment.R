## 1st part

set.seed(1)
x <- runif(30, 0, 10)
set.seed(2)
y <- -0.1 + 0.01 * x + rnorm(30, 0, 0.1)
d <- data.frame(x = x, y = y)
fit <- lm(y ~ x, d)
p <- predict(fit, d)
col <- ifelse(y > p, 4, 2)
plot(x, y, xlim = c(0, 10), ylim = c(-1, 1), cex = 2, col = col)
abline(reg = fit, col = 'purple', lwd = 3)

## 2nd part

s <- rep(0, 100)
x <- matrix(0, nrow = 100, ncol = 1000)

for (i in 1:100){
  set.seed(i)
  x[i, ] <- rbinom(1000, 1, 0.01)
  s[i] <- sum(x[i, ])
}

which(s == 10)
t <- which(s == 10)
length(t) # 14

png('RTM_experiment2_14plots.png',
    height = 1000, width = 1000)
par(mfrow = c(4, 4))
par(mar = c(2, 2, 2, 2))
for (i in 1:14){
  set.seed(t[i])
  y <- rbinom(1000, 1, 0.01)
  plot(y, xlab = '', ylab = '', col = y + 1, cex = y + 1)
}
dev.off()