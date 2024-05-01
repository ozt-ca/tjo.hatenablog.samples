library(ggplot2)

xo <- seq(0, 5, 0.1)
yo <- xo * (xo - 2.5) * (xo - 4.5)

plot(xo, yo, type = 'l', xlim = c(0, 5), ylim = c(-6, 7))

set.seed(119)
x <- sample(xo, 15, replace = F)
y <- x * (x - 2.5) * (x - 4.5) + rnorm(15, 0, 1)

par(new = T)
plot(x, y, type = 'p', cex = 2, xlim = c(0, 5), ylim = c(-6, 7))

d3 <- data.frame(y = y,
                 x1 = x, x2 = x^2, x3 = x^3)
d9 <- data.frame(y = y,
                 x1 = x, x2 = x^2, x3 = x^3,
                 x4 = x^4, x5 = x^5, x6 = x^6,
                 x7 = x^7, x8 = x^8, x9 = x^9)

fit3 <- lm(y ~ ., d3)
fit9 <- lm(y ~ ., d9)

do3 <- data.frame(y = yo,
                 x1 = xo, x2 = xo^2, x3 = xo^3)
do9 <- data.frame(y = yo,
                 x1 = xo, x2 = xo^2, x3 = xo^3,
                 x4 = xo^4, x5 = xo^5, x6 = xo^6,
                 x7 = xo^7, x8 = xo^8, x9 = xo^9)

out3 <- predict(fit3, newdata = do3)
out9 <- predict(fit9, newdata = do9)

d <- data.frame(x = x, y = y, label = 'sample')

d_all <- rbind(data.frame(x = xo, y = out3, label = 'deg 3'),
               data.frame(x = xo, y = out9, label = 'deg 9'))

p_all <- ggplot() +
  geom_point(data = d, shape = 1, size = 10,
             mapping = aes(x = x, y = y)) +
  geom_line(data = d_all, linewidth = 1,
            mapping = aes(x = x, y = y, colour = label)) +
  scale_colour_brewer(palette = 'Dark2') +
  theme(legend.title = element_blank(),
        legend.text = element_text(size = 24),
        axis.text.x = element_blank(),
        axis.text.y = element_blank()) +
  labs(x = NULL, y = NULL)
plot(p_all)

jpeg('blog_ggplot2_reg_overfit.jpg', width = 960, height = 720)
plot(p_all)
dev.off()