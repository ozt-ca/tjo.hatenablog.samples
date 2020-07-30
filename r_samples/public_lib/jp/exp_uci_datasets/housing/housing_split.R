d <- read.csv('housing.csv')

set.seed(14)
idx <- sample(nrow(d), round(nrow(d) * 0.1, 0), replace = F)
d_train <- d[-idx, ]
d_test <- d[idx, ]
par(mfrow = c(1, 2))
hist(d_train$MEDV)
hist(d_test$MEDV)

write.table(d_train, 'housing_train.csv', sep = ',', quote = F,
            row.names = F, col.names = T)
write.table(d_test, 'housing_test.csv', sep = ',', quote = F,
            row.names = F, col.names = T)
