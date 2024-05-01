library(ggplot2)
library(e1071)
library(randomForest)

d <- rbind(data.frame(x = rnorm(1000, 1, 0.5), y = rnorm(1000, 1, 0.5),
                      label = 0),
           data.frame(x = rnorm(1000, -1, 0.5), y = rnorm(1000, -1, 0.5),
                      label = 1))
d$label <- as.factor(d$label)

px <- seq(-3, 3, 0.02)
pgrid <- expand.grid(px, px)
names(pgrid) <- names(d)[-3]

fit1 <- svm(label ~., d, gamma = 750)
out1 <- predict(fit1, newdata = pgrid)

fit2 <- randomForest(label ~., d)
out2 <- predict(fit2, newdata = pgrid)

fit3 <- glm(label ~., d, family = binomial)
out3 <- round(predict(fit3, newdata = pgrid, type = 'response'))

dgrid1 <- cbind(pgrid, out1)
dgrid2 <- cbind(pgrid, out2)
dgrid3 <- cbind(pgrid, out3)

p1 <- ggplot(data = d, mapping = aes(x = x, y = y)) +
  geom_point(mapping = aes(color = label)) +
  scale_color_hue() +
  theme(legend.position = 'none',
        axis.text.x = element_blank(),
        axis.text.y = element_blank()) +
  labs(x = NULL, y = NULL)
print(p1)

p2 <- ggplot(data = d, mapping = aes(x = x, y = y)) +
  geom_point(mapping = aes(color = label)) +
  scale_color_hue() +
  theme(legend.position = 'none',
        axis.text.x = element_blank(),
        axis.text.y = element_blank()) +
  labs(x = NULL, y = NULL) +
  geom_contour(data = dgrid1,
               mapping = aes(x = x, y = y, z = as.numeric(out1)))
print(p2)

p3 <- ggplot(data = d, mapping = aes(x = x, y = y)) +
  geom_point(mapping = aes(color = label)) +
  scale_color_hue() +
  theme(legend.position = 'none',
        axis.text.x = element_blank(),
        axis.text.y = element_blank()) +
  labs(x = NULL, y = NULL) +
  geom_contour(data = dgrid2,
               mapping = aes(x = x, y = y, z = as.numeric(out2)))
print(p3)

p4 <- ggplot(data = d, mapping = aes(x = x, y = y)) +
  geom_point(mapping = aes(color = label)) +
  scale_color_hue() +
  theme(legend.position = 'none',
        axis.text.x = element_blank(),
        axis.text.y = element_blank()) +
  labs(x = NULL, y = NULL) +
  geom_contour(data = dgrid3,
               mapping = aes(x = x, y = y, z = as.numeric(out3)))
print(p4)

jpeg('blog_ggplot2_classify_overfit1.jpg', width = 640, height = 640)
print(p1)
dev.off()
jpeg('blog_ggplot2_classify_overfit2.jpg', width = 640, height = 640)
print(p2)
dev.off()
jpeg('blog_ggplot2_classify_overfit3.jpg', width = 640, height = 640)
print(p3)
dev.off()
jpeg('blog_ggplot2_classify_overfit4.jpg', width = 640, height = 640)
print(p4)
dev.off()