Adstock <- function(t, weights){
  (t %*% weights) / sum(weights)
}