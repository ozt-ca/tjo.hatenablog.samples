# Create a sample data matrix
seed_prob <- c(0.05, 0.05, 0.8, 0.05, 0.025, 0.025)
set.seed(101)
d <- t(rmultinom(100000, 1, seed_prob))

# Set a hyper parameter
inc <- 1e-4

# Initiate an arm probability
prob <- rep(1/6, 6)

# Set a result vector
res <- rep(0, nrow(d))

# Iterate multi-arm bandit computation
for (i in 1:nrow(d)){
  pred <- rmultinom(1, 1, prob) # Predict which arm returns 1
  res[i] <- t(pred) %*% d[i, ] # Compute an internal prod for answer
  # if 1, update the arm probability to reinforce
  if (res[i] == 1 && min(prob) > 0){
    prob[which(pred > 0)] <- prob[which(pred > 0)] + inc
    prob[which(pred == 0)] <- prob[which(pred == 0)] - inc/5
  }
  # if 0, update it to less reinforce
  if (res[i] == 0 && min(prob) > 0){
    prob[which(pred > 0)] <- prob[which(pred > 0)] - inc
    prob[which(pred == 0)] <- prob[which(pred == 0)] + inc/5
  }
  
  # Adjust a scale of the arm probability
  if (min(prob) < 0){
    prob <- (prob - min(prob)) / sum(prob)
  }
  if (max(prob) > 1){
    prob <- (prob - (max(prob) - 1)) / sum(prob)
  }
}

# Check and plot a trajectory of reinforcement learning
res_bin <- rep(0, 1000)
for (i in 1:1000){
  res_bin[i] <- sum(res[((i-1) * 100 + 1) : (i * 100)]) / 100
}
plot(res_bin, type = 'l',
     xlab = 'Iteration', ylab = 'Correct answer probability for 100 epochs')
segments(0, max(seed_prob), 1000, max(seed_prob), col = 'red', lwd = 5, lty = 3)