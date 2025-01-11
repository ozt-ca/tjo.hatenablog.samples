d <- read.csv('housing.csv', sep = '\t')
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