d <- read.csv('https://raw.githubusercontent.com/ozt-ca/tjo.hatenablog.samples/refs/heads/master/r_samples/public_lib/jp/R/housing.csv', sep = '\t')
d$CHAS <- as.factor(d$CHAS)
d$RAD <- as.integer(d$RAD)
summary(d)
d.lm <- lm(MEDV ~ ., d)
summary(d.lm)

d1 <- d
d1$X1 <- d1$CRIM + rnorm(nrow(d1), 0, sd(d1$CRIM) / 10)
d1$X2 <- d1$NOX + rnorm(nrow(d1), 0, sd(d1$NOX) / 10)
summary(d1)
d1.lm <- lm(MEDV ~ ., d1)
summary(d1.lm)

car::vif(d.lm)
car::vif(d1.lm)

d1.cv.glmnet <- glmnet::cv.glmnet(as.matrix(d1[, -13]), as.matrix(d1[, 13]),
                                 family = 'gaussian', alpha = 1)
coef(d1.cv.glmnet, s = d1.cv.glmnet$lambda.min)

cv::cv(d.lm)
cv::cv(d1.lm)