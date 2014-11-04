train_org <- read.csv("train.csv", header=TRUE)
test_org <- read.csv("test.csv", header=TRUE)
labels_org <- as.factor(train_org[,1])
train_org <- train_org[,-1]
test_idx<-c()
for (i in 1:10) {
	tmp1 <- which(labels_org == (i-1))
	tmp2 <- sample(tmp1, 1000, replace=F)
	test_idx <- c(test_idx, tmp2)
}
test <- train_org[test_idx,]
train <- train_org[-test_idx,]
labels_test <- labels[test_idx]
labels_train <- labels[-test_idx]
