set.seed(101)
d <- t(rmultinom(100000, 1, c(0.05, 0.05, 0.8, 0.05, 0.025, 0.025)))

inc <- 1e-4
prob <- rep(1/6, 6)
res <- rep(0, nrow(d))
for (i in 1:nrow(d)){
  pred <- rmultinom(1, 1, prob)
  res[i] <- t(pred) %*% d[i, ]
  if (res[i] == 1 && min(prob) > 0){
    prob[which(pred > 0)] <- prob[which(pred > 0)] + inc
    prob[which(pred == 0)] <- prob[which(pred == 0)] - inc/5
  }
  if (res[i] == 0 && min(prob) > 0){
    prob[which(pred > 0)] <- prob[which(pred > 0)] - inc
    prob[which(pred == 0)] <- prob[which(pred == 0)] + inc/5
  }
  if (min(prob) < 0){
    prob <- (prob - min(prob)) / sum(prob)
  }
  if (max(prob) > 1){
    prob <- (prob - (max(prob) - 1)) / sum(prob)
  }
}

res_bin <- rep(0, 1000)
for (i in 1:1000){
  res_bin[i] <- sum(res[((i-1) * 100 + 1) : (i * 100)]) / 100
}
plot(res_bin, type = 'l',
     xlab = 'Iteration', ylab = 'Correct answer probability for 100 epochs')