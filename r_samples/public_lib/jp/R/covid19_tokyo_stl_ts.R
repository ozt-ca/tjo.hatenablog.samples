d <- read.csv('https://stopcovid19.metro.tokyo.lg.jp/data/130001_tokyo_covid19_patients.csv')
d1 <- data.frame(day = d[, 5], num = 1)

library(dplyr)
d1$day <- as.Date(d1$day)
d2 <- d1 %>% group_by(day) %>% summarise(sum(num)) %>% as.data.frame()
names(d2)[2] <- 'num'
dayseq <- seq(from = as.Date(d2$day[1]), to = as.Date(d2$day[nrow(d2)]), by = 'day')
dayseq <- as.data.frame(dayseq)
names(dayseq) <- 'day'
d3 <- left_join(dayseq, d2, by = 'day')
d3[which(is.na(d3$num)), 2] <- 0
dts <- stl(ts(as.numeric(d3$num), frequency = 7), s.window = 'per')
mtitle <- paste0('Tokyo, daily from ', d3$day[1], ' to ', d3$day[nrow(d3)])
plot(d3$day, d3$num, main = mtitle,
     xlab = 'Date', ylab = 'Positive reported', type = 'l',
     ylim = c(-10, 230), col = 'black', lwd = 1)
par(new = T)
plot(d3$day, dts$time.series[, 2], main = mtitle,
     xlab = 'Date', ylab = 'Positive reported', type = 'l',
     ylim = c(-10, 230), col = 'blue', lwd = 3)
par(new = T)
plot(d3$day, dts$time.series[, 2] + dts$time.series[, 3],
     main = mtitle, xlab = 'Date', ylab = 'Positive reported',
     type = 'l', col = 'red', ylim = c(-10, 230), lty = 2)
legend('topleft', legend = c('Reported', 'Trend', 'Trend + Seasonality'),
       col = c('black', 'blue', 'red'), lty = c(1, 1, 3),
       lwd = c(1, 3, 2), ncol = 1)