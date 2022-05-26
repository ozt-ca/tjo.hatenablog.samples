# Large dataset

d <- read.csv('https://github.com/ozt-ca/tjo.hatenablog.samples/raw/master/r_samples/public_lib/jp/xor_complex_large.txt', header = T, sep = '\t')
x_train <- as.matrix(d[, -3])
y_train <- as.matrix(d[, 3]) - 1

library(keras)
model <- keras_model_sequential() 

model %>% 
  layer_dense(units = 5, input_shape = 2) %>% 
  layer_activation(activation = 'relu') %>% 
  layer_dense(units = 7) %>%
  layer_activation(activation = 'relu') %>%
  layer_dense(units = 1, activation = 'sigmoid')

model %>% compile(
  loss = 'binary_crossentropy',
  optimizer = optimizer_sgd(lr = 0.05),
  metrics = c('accuracy')
)
model %>% fit(x_train, y_train, epochs = 5, batch_size = 100)

px <- seq(-4, 4, 0.03)
py <- seq(-4, 4, 0.03)
x_test <- expand.grid(px, py)
x_test <- as.matrix(x_test)
pred_class <- model %>% predict(x_test, batch_size = 100)
pred_class <- round(pred_class, 0)
plot(d[, -3], col = c(rep(1, 50000), rep(2, 50000)), pch = 19, cex = 0.2,
     xlim = c(-4, 4), ylim = c(-4, 4), main = "DNN: Large dataset")
par(new = T)
contour(px, py, array(pred_class, dim = c(length(px), length(py))),
        xlim = c(-4, 4), ylim = c(-4, 4), levels = 0.5, drawlabels = F,
        col = 'purple', lwd = 5)

unfreeze_weights(model, from = 2)


# Small dataset: fine-tuned
d <- read.csv('https://github.com/ozt-ca/tjo.hatenablog.samples/raw/master/r_samples/public_lib/jp/xor_complex_small.txt', header = T, sep = ' ')
x_train <- as.matrix(d[, -3])
y_train <- as.matrix(d[, 3]) - 1

model %>% fit(x_train, y_train, epochs = 5, batch_size = 5)

px <- seq(-4, 4, 0.03)
py <- seq(-4, 4, 0.03)
x_test <- expand.grid(px, py)
x_test <- as.matrix(x_test)
pred_class <- model %>% predict(x_test, batch_size = 100)
pred_class <- round(pred_class, 0)
plot(d[, -3], col = c(rep(1, 50), rep(2, 50)), pch = 19, cex = 2,
xlim = c(-4, 4), ylim = c(-4, 4), main = "DNN: Small dataset with fine-tuning")
par(new = T)
contour(px, py, array(pred_class, dim = c(length(px), length(py))),
xlim = c(-4, 4), ylim = c(-4, 4), levels = 0.5, drawlabels = F,
col = 'purple', lwd = 5)

rm(model)


# Small dataset: raw model

d <- read.csv('https://github.com/ozt-ca/tjo.hatenablog.samples/raw/master/r_samples/public_lib/jp/xor_complex_small.txt', header = T, sep = ' ')
x_train <- as.matrix(d[, -3])
y_train <- as.matrix(d[, 3]) - 1

library(keras)
model <- keras_model_sequential() 

model %>% 
  layer_dense(units = 5, input_shape = 2) %>% 
  layer_activation(activation = 'relu') %>% 
  layer_dense(units = 7) %>%
  layer_activation(activation = 'relu') %>%
  layer_dense(units = 1, activation = 'sigmoid')

model %>% compile(
  loss = 'binary_crossentropy',
  optimizer = optimizer_sgd(lr = 0.05),
  metrics = c('accuracy')
)
model %>% fit(x_train, y_train, epochs = 5, batch_size = 5)

px <- seq(-4, 4, 0.03)
py <- seq(-4, 4, 0.03)
x_test <- expand.grid(px, py)
x_test <- as.matrix(x_test)
pred_class <- model %>% predict(x_test, batch_size = 5)
pred_class <- round(pred_class, 0)
plot(d[, -3], col = c(rep(1, 50), rep(2, 50)), pch = 19, cex = 2,
     xlim = c(-4, 4), ylim = c(-4, 4), main = "DNN: Small dataset without fine-tuning")
par(new = T)
contour(px, py, array(pred_class, dim = c(length(px), length(py))),
        xlim = c(-4, 4), ylim = c(-4, 4), levels = 0.5, drawlabels = F,
        col = 'purple', lwd = 5)
