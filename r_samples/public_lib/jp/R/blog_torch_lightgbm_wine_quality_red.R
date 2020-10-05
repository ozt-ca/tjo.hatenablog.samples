# Load the datasets
w_train <- read.csv("https://github.com/ozt-ca/tjo.hatenablog.samples/raw/master/r_samples/public_lib/jp/exp_uci_datasets/wine/wine_red_train.csv")
w_test <- read.csv("https://github.com/ozt-ca/tjo.hatenablog.samples/raw/master/r_samples/public_lib/jp/exp_uci_datasets/wine/wine_red_test.csv")

# Transform "quality" into binary
w_train$quality[w_train$quality < 6] <- 0
w_test$quality[w_test$quality < 6] <- 0
w_train$quality[w_train$quality > 0] <- 1
w_test$quality[w_test$quality > 0] <- 1

# Normalize
c_scale <- function(x){
  x <- (x - min(x)) / (max(x) - min(x))
}

w_train[, -12] <- apply(w_train[, -12], 2, c_scale)
w_test[, -12] <- apply(w_test[, -12], 2, c_scale)


## Try Torch

library(torch)

Sys.setenv(KMP_DUPLICATE_LIB_OK="TRUE") # Delete if you don't need

# Create a {torch} dataset
df_dataset <- dataset(
  
  "wine",

    initialize = function(df, response_variable) {
    self$df <- df[,-which(names(df) == response_variable)]
    self$response_variable <- df[[response_variable]]
  },
 
   .getitem = function(index) {
    response <- torch_tensor(self$response_variable[index])
    x <- torch_tensor(as.numeric(self$df[index,]))
    
    list(x = x, y = response)
  },
  
  .length = function() {
    length(self$response_variable)
  }
  
)

wtrain_ds <- df_dataset(w_train, "quality")
wtest_ds <- df_dataset(w_test, "quality")

wtrain_dl <- dataloader(wtrain_ds, batch_size = 32, shuffle = T)
wtest_dl <- dataloader(wtest_ds, batch_size = 1, shuffle = F)

# Define a network
net <- nn_module(
  
  "wine_DNN",
  
  initialize = function() {
    self$fc1 <- nn_linear(11, 66)
    self$fc2 <- nn_linear(66, 44)
    self$fc3 <- nn_linear(44, 1)
    self$dropout <- nn_dropout(0.5)
  },
  
  forward = function(x) {
    x %>% 
      self$fc1() %>%
      nnf_relu() %>%
      self$fc2() %>%
      nnf_relu() %>%
      self$dropout() %>%
      self$fc3() %>%
      nnf_sigmoid()
  }
)

model <- net()
model$to(device = "cpu")

optimizer <- optim_adam(model$parameters)

# Run a learning iteration
for (epoch in 1:20) {
  
  l <- c()
  
  for (b in enumerate(wtrain_dl)) {
    optimizer$zero_grad()
    output <- model(b[[1]]$to(device = "cpu"))
    loss <- nnf_binary_cross_entropy_with_logits(output, b[[2]]$to(device = "cpu"))
    loss$backward()
    optimizer$step()
    l <- c(l, loss$item())
  }
  
  cat(sprintf("Loss at epoch %d: %3f\n", epoch, mean(l)))
}

# Evaluate and predict labels for test data
model$eval()

i <- 1
pred_labels <- rep(0, nrow(w_test))

for (b in enumerate(wtest_dl)) {
  output <- model(b[[1]]$to(device = "cpu"))
  pred_labels[i] <- round(output$item(), 0)
  i <- i + 1
}

table(w_test$quality, pred_labels)
sum(diag(table(w_test$quality, pred_labels)))


## Try LightGBM

library(lightgbm)

# Run a learning procedure
bst <- lightgbm(
  data = as.matrix(w_train[, -12])
  , label = w_train$quality
  , num_leaves = 4L
  , learning_rate = 1.0
  , nrounds = 2L
  , objective = "binary"
)

# Predict labels for test data & evaluate
pred <- predict(bst, as.matrix(w_test[, -12]))
table(w_test$quality, round(pred, 0))
sum(diag(table(w_test$quality, round(pred, 0)))) / nrow(w_test)
