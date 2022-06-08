library(keras)

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

plot(d[,-3], col = d[, 3] + 1, xlim = c(-4, 4), ylim = c(-4, 4),
     cex = 0.1, pch = 19)

x_train <- as.matrix(d[, -3])
y_train <- as.matrix(d[, 3])

us_idx <- sample(1:37500, 2500, replace = F)
x_train_us <- x_train[c(us_idx, c(37501:40000)),]
y_train_us <- y_train[c(us_idx, c(37501:40000))]

rnd_idx <- sample(5000)
x_train_us <- x_train_us[rnd_idx,]
y_train_us <- y_train_us[rnd_idx]

all_idx <- sample(40000)
x_train_all <- x_train[all_idx,]
y_train_all <- y_train[all_idx,]

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
model %>% fit(x_train_us, y_train_us, epochs = 15, batch_size = 100)

pred_class1 <- model %>% predict(x_test, batch_size = 100)
plot(x_train_us, col = y_train_us + 1, xlim = c(-4, 4), ylim = c(-4, 4),
     cex = 0.1, pch = 19)
par(new = T)
contour(px, py, array(pred_class1, dim = c(length(px), length(py))),
        xlim = c(-4, 4), ylim = c(-4, 4), levels = 0.5, drawlabels = F,
        col = 'purple', lwd = 5)


unfreeze_weights(model, from = 2)

model %>% compile(
  loss = 'binary_crossentropy',
  optimizer = optimizer_sgd(learning_rate = 0.001),
  metrics = c('accuracy')
)
model %>% fit(x_train_all, y_train_all, epochs = 15, batch_size = 100)

pred_class2 <- model %>% predict(x_test, batch_size = 100)
plot(d[,-3], col = d[, 3] + 1, xlim = c(-4, 4), ylim = c(-4, 4),
     cex = 0.1, pch = 19)
par(new = T)
contour(px, py, array(pred_class2, dim = c(length(px), length(py))),
        xlim = c(-4, 4), ylim = c(-4, 4), levels = 0.5, drawlabels = F,
        col = 'purple', lwd = 5)
rm(model)