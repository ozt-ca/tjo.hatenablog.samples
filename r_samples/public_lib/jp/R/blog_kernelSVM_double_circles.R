library(e1071)
library(scatterplot3d)

dc <- read.csv('https://raw.githubusercontent.com/ozt-ca/tjo.hatenablog.samples/master/r_samples/public_lib/jp/double_circle.txt', sep = '\t')

plot(dc[, -3], col = c(rep('blue', 300), rep('red', 300)),
     xlim = c(-4, 4), ylim = c(-4, 4), pch = 19, cex=1.5)

zdc<-rep(0, 600)
for (i in 1:600){
  for (j in 1:600){
    zdc[i] <- zdc[i] + exp(-((dc[i, 1] - dc[j, 1])^2 +
                               (dc[i, 2]-dc[j, 2])^2))
    }
}
scatterplot3d(dc$x, dc$y, zdc,
              color = c(rep('blue', 300), rep('red', 300)),
              pch = 19, cex.symbols = 1.5)
scatterplot3d(dc$x, dc$y, zdc,
              color = c(rep('blue', 300), rep('red', 300)),
              pch = 19, cex.symbols=1.5, angle=0)

dc$label <- as.factor(dc$label)
fit <- e1071::svm(label ~., dc)

px <- seq(-4, 4, by = 0.02)
py <- seq(-4, 4, by = 0.02)
plain <- expand.grid(px, py)
names(plain) <- names(dc[, -3])

bdry <- predict(fit, plain)

plot(dc[, -3], col = c(rep('blue', 300), rep('red', 300)),
     xlim = c(-4, 4), ylim = c(-4, 4), pch = 19, cex=1.5)
par(new = T)
contour(px, py, array(bdry, dim = c(length(px), length(py))),
        drawlabels = T, lwd = 3, col='purple')