d1 <- rnorm(n = 10000, mean = 10, sd = 2)
d2 <- c(rnorm(n = 5000, mean = 5, sd = 2), rnorm(n = 5000, mean = 15, sd = 2))
d3 <- rpois(n = 10000, lambda = 10)
d4 <- rep(c(0, 20), 5000)[sample(10000, 10000, replace = F)]

mean(d1)
var(d1)
mean(d2)
var(d2)
mean(d3)
var(d3)
mean(d4)
var(d4)

d <- data.frame(d1 = d1, d2 = d2, d3 = d3, d4 = d4)
d_first <- d[1:10, ]

write.table(d, 'four_distributions_same_mean.csv', quote = F,
            row.names = F, col.names = T, sep = ',')
write.table(d_first, 'four_distributions_same_mean_limit10.csv', quote = F,
            row.names = F, col.names = T, sep = ',')
