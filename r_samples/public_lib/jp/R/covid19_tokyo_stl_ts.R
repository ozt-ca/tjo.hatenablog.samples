d <- read.csv('https://stopcovid19.metro.tokyo.lg.jp/data/130001_tokyo_covid19_patients.csv')
d1 <- data.frame(day = d[, 5], num = 1)

library(dplyr)
d1$day <- as.Date(d1$day)
d2 <- d1 %>% group_by(day) %>% summarise(sum(num)) %>% as.data.frame()
names(d2)[2] <- 'num'
d2[69, ] <- c('2020-04-27', 39)
dayseq <- seq(from = as.Date('2020-01-24'), to = as.Date('2020-04-27'), by = 'day')
dayseq <- as.data.frame(dayseq)
names(dayseq) <- 'day'
d3 <- left_join(dayseq, d2, by = 'day')
d3[which(is.na(d3$num)), 2] <- 0
dts <- stl(ts(as.numeric(d3$num), frequency = 7), s.window = 'per')
plot(d3$day, dts$time.series[, 2], main = 'Tokyo, daily',
     xlab = 'Date', ylab = 'Positive reported', type = 'l',
     ylim = c(-10, 230), col = 'blue', lwd = 3)
par(new = T)
plot(d3$day, dts$time.series[, 2] + dts$time.series[, 3],
     main = 'Tokyo, daily',xlab = 'Date', ylab = 'Positive reported',
     type = 'l', col = 'red', ylim = c(-10, 230))
legend('topleft', legend = c('Trend', 'Trend + Seasonality'),
       col = c('blue', 'red'), lty = 1, lwd = c(3, 1), ncol = 1)