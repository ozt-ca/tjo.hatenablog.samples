#########
## DNN ##
#########

# Large dataset

d <- read.csv('xor_complex_large.txt', header = T, sep = '\t')
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

# Medium dataset

d <- read.csv('xor_complex_medium.txt', header = T, sep = '\t')
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
plot(d[, -3], col = c(rep(1, 5000), rep(2, 5000)), pch = 19, cex = 0.4,
     xlim = c(-4, 4), ylim = c(-4, 4), main = "DNN: Medium dataset")
par(new = T)
contour(px, py, array(pred_class, dim = c(length(px), length(py))),
        xlim = c(-4, 4), ylim = c(-4, 4), levels = 0.5, drawlabels = F,
        col = 'purple', lwd = 5)


# Small dataset

d <- read.csv('xor_complex_small.txt', header = T, sep = ' ')
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
plot(d[, -3], col = c(rep(1, 50), rep(2, 50)), pch = 19, cex = 2,
     xlim = c(-4, 4), ylim = c(-4, 4), main = "DNN: Small dataset")
par(new = T)
contour(px, py, array(pred_class, dim = c(length(px), length(py))),
        xlim = c(-4, 4), ylim = c(-4, 4), levels = 0.5, drawlabels = F,
        col = 'purple', lwd = 5)


#########
## SVM ##
#########

# Large dataset

d <- read.csv('xor_complex_large.txt', header = T, sep = '\t')
d[, 3] <- d[, 3] - 1
d[, 3] <- as.factor(d[, 3])

library(e1071)
fit <- svm(label ~., data = d)

px <- seq(-4, 4, 0.03)
py <- seq(-4, 4, 0.03)
d_test <- expand.grid(px, py)
names(d_test) <- names(d)[-3]
pred_class <- predict(fit, newdata = d_test)
plot(d[, -3], col = c(rep(1, 50000), rep(2, 50000)), pch = 19, cex = 0.2,
     xlim = c(-4, 4), ylim = c(-4, 4), main = "SVM: Large dataset")
par(new = T)
contour(px, py, array(pred_class, dim = c(length(px), length(py))),
        xlim = c(-4, 4), ylim = c(-4, 4), levels = 0.5, drawlabels = F,
        col = 'purple', lwd = 5)

# Medium dataset

d <- read.csv('xor_complex_medium.txt', header = T, sep = '\t')
d[, 3] <- d[, 3] - 1
d[, 3] <- as.factor(d[, 3])

library(e1071)
fit <- svm(label ~., data = d)

px <- seq(-4, 4, 0.03)
py <- seq(-4, 4, 0.03)
d_test <- expand.grid(px, py)
names(d_test) <- names(d)[-3]
pred_class <- predict(fit, newdata = d_test)
plot(d[, -3], col = c(rep(1, 5000), rep(2, 5000)), pch = 19, cex = 0.4,
     xlim = c(-4, 4), ylim = c(-4, 4), main = "SVM: Medium dataset")
par(new = T)
contour(px, py, array(pred_class, dim = c(length(px), length(py))),
        xlim = c(-4, 4), ylim = c(-4, 4), levels = 0.5, drawlabels = F,
        col = 'purple', lwd = 5)


# Small dataset

d <- read.csv('xor_complex_small.txt', header = T, sep = ' ')
d[, 3] <- d[, 3] - 1
d[, 3] <- as.factor(d[, 3])

library(e1071)
fit <- svm(label ~., data = d)

px <- seq(-4, 4, 0.03)
py <- seq(-4, 4, 0.03)
d_test <- expand.grid(px, py)
names(d_test) <- names(d)[-3]
pred_class <- predict(fit, newdata = d_test)
plot(d[, -3], col = c(rep(1, 50), rep(2, 50)), pch = 19, cex = 2,
     xlim = c(-4, 4), ylim = c(-4, 4), main = "SVM: Small dataset")
par(new = T)
contour(px, py, array(pred_class, dim = c(length(px), length(py))),
        xlim = c(-4, 4), ylim = c(-4, 4), levels = 0.5, drawlabels = F,
        col = 'purple', lwd = 5)
