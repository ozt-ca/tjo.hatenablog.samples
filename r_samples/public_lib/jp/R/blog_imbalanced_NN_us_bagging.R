library(keras)
library(tcltk)

set.seed(1001)
x1 <- cbind(rnorm(10000, 1, 1), rnorm(10000, 1, 1))
set.seed(1002)
x2 <- cbind(rnorm(10000, -1, 1), rnorm(10000, 1, 1))
set.seed(1003)
x3 <- cbind(rnorm(10000, -1, 1), rnorm(10000, -1, 1))
set.seed(4001)
x41 <- cbind(rnorm(2500, 0.5, 0.5), rnorm(2500, -0.5, 0.5))
set.seed(4002)
x42 <- cbind(rnorm(2500, 1, 0.5), rnorm(2500, -0.5, 0.5))
set.seed(4003)
x43 <- cbind(rnorm(2500, 0.5, 0.5), rnorm(2500, -1, 0.5))
set.seed(4004)
x44 <- cbind(rnorm(2500, 1, 0.5), rnorm(2500, -1, 0.5))
d <- rbind(x1, x2, x3, x42, x44, x43, x41)
d <- data.frame(x = d[, 1], y = d[, 2],
                label = c(rep(0, 37500), rep(1, 2500)))

px <- seq(-4, 4, 0.03)
py <- seq(-4, 4, 0.03)
x_test <- expand.grid(px, py)
x_test <- as.matrix(x_test)

model <- keras_model_sequential() 
model %>% 
  layer_dense(units = 5, input_shape = 2) %>% 
  layer_activation(activation = 'relu') %>% 
  layer_dense(units = 7) %>%
  layer_activation(activation = 'relu') %>%
  layer_dense(units = 1, activation = 'sigmoid')
model %>% compile(
  loss = 'binary_crossentropy',
  optimizer = optimizer_sgd(learning_rate = 0.08),
  metrics = c('accuracy')
)

outbag.nn <- c()
iter <- 25
pb <- txtProgressBar(min = 1, max = iter, style = 3)
for (i in 1:iter){
  set.seed(100 + i)
  train.tmp <- d[d$label==0, ]
  train0 <- train.tmp[sample(37500, 2500, replace=F),]
  train1 <- d[37501:40000, ]
  train <- rbind(train0, train1)[sample(5000),]
  x_train <- as.matrix(train[, -3])
  y_train <- as.matrix(train[, 3])
  model %>% fit(x_train, y_train, epochs = 15, batch_size = 100)
  tmp <- model %>% predict(x_test, batch_size = 100)
  outbag.nn <- cbind(outbag.nn, tmp)
  setTxtProgressBar(pb, i)
}
outbag.nn.grid <- apply(outbag.nn, 1, mean)
plot(d[,-3], col = d[, 3] + 1, xlim = c(-4, 4), ylim = c(-4, 4),
     cex = 0.1, pch = 19)
par(new=T)
contour(px, py, array(outbag.nn.grid, c(length(px), length(py))),
        levels = 0.5, col = 'purple', lwd = 5, drawlabels = F)
