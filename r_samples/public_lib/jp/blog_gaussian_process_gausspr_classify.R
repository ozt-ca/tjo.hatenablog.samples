library(kernlab)
d <- read.csv('https://raw.githubusercontent.com/ozt-ca/tjo.hatenablog.samples/master/r_samples/public_lib/jp/xor_complex_small.txt', sep = ' ')
d$label <- as.factor(d$label-1)
px <- seq(-4, 4, 0.03)
py <- seq(-4, 4, 0.03)
pgrid <- expand.grid(px, py)
names(pgrid) <- names(d)[-3]

fit <- gausspr(label~., d, type = 'classification')
out <- predict(fit, newdata = pgrid, type = 'probabilities')
out_vec <- rep(0, nrow(out))
for (i in 1:nrow(out)){
  if (out[i, 1] > 0.5) out_vec[i] <- 1
}

plot(c(), type = 'n', xlim = c(-4, 4), ylim = c(-4, 4), xlab = '', ylab = '')
par(new = T)
rect(0, 0, 4, 4, col = '#dddddd')
par(new = T)
rect(-4, 0, 0, 4, col = '#ffdddd')
par(new = T)
rect(-4, -4, 0, 0, col = '#dddddd')
par(new = T)
rect(0, -4, 4, 0, col = '#ffdddd')
par(new = T)
plot(d[, -3], pch = 19, cex = 2, col = d$label, xlim = c(-4, 4), ylim = c(-4, 4),
     xlab = '', ylab = '')
par(new = T)
contour(px, py, array(out_vec, c(length(px), length(py))),
        col = 'purple', levels = 0.5, lwd = 3, drawlabels = F)