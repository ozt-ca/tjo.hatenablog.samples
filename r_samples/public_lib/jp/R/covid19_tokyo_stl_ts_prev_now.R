# Download the raw CSV file
d <- read.csv('https://stopcovid19.metro.tokyo.lg.jp/data/130001_tokyo_covid19_patients.csv')
# Extract date, with adding a dummy
d1 <- data.frame(day = d[, 5], num = 1)

# Aggregate as daily sum
library(dplyr)
d1$day <- as.Date(d1$day) # Put date into Date class
# Aggregate with group-by
d2 <- d1 %>% group_by(day) %>% summarise(sum(num)) %>% as.data.frame()
names(d2)[2] <- 'num'
# Set up a consecutive date vector
dayseq <- seq(from = as.Date(d2$day[1]), to = as.Date(d2$day[nrow(d2)]), by = 'day')
dayseq <- as.data.frame(dayseq)
names(dayseq) <- 'day'
# Join daily sum over the date vector
d3 <- left_join(dayseq, d2, by = 'day')
# Fill NAs by 0
d3[which(is.na(d3$num)), 2] <- 0

# Add the latest value MANUALLY
d4 <- d3
d4[(nrow(d3) + 1), ] <- c('2020-04-28', 112) # Here please write down

# Model trend and seasonality using stl (loess)
dts <- stl(ts(as.numeric(d3$num), frequency = 7), s.window = 'per')
dts2 <- stl(ts(as.numeric(d4$num), frequency = 7), s.window = 'per')

# Create a title with start and end dates
mtitle <- paste0('Tokyo, daily from ', d4$day[1], ' to ', d4$day[nrow(d4)])
xrange <- c(d4$day[1], d4$day[nrow(d4)])

# Plot raw, trend and trend + seasonality time series
plot(d3$day, d3$num, main = mtitle,
     xlab = 'Date', ylab = 'Positive reported', type = 'l',
     xlim = xrange, ylim = c(-10, 230), col = 'black', lwd = 1, lty = 3)
par(new = T)
plot(d3$day, dts$time.series[, 2], main = mtitle,
     xlab = 'Date', ylab = 'Positive reported', type = 'l',
     xlim = xrange, ylim = c(-10, 230), col = 'blue', lwd = 3, lty = 3)
par(new = T)
plot(d3$day, dts$time.series[, 2] + dts$time.series[, 1],
     main = mtitle, xlab = 'Date', ylab = 'Positive reported',
     type = 'l', col = 'red', xlim = xrange, ylim = c(-10, 230), lty = 3)

par(new = T)

plot(d4$day, d4$num, main = mtitle,
     xlab = 'Date', ylab = 'Positive reported', type = 'l',
     xlim = xrange, ylim = c(-10, 230), col = 'black', lwd = 1)
par(new = T)
plot(d4$day, dts2$time.series[, 2], main = mtitle,
     xlab = 'Date', ylab = 'Positive reported', type = 'l',
     xlim = xrange, ylim = c(-10, 230), col = 'blue', lwd = 3)
par(new = T)
plot(d4$day, dts2$time.series[, 2] + dts2$time.series[, 1],
     main = mtitle, xlab = 'Date', ylab = 'Positive reported',
     type = 'l', col = 'red', xlim = xrange, ylim = c(-10, 230))

legend('topleft',
       legend = c('Reported (prev)', 'Trend (prev)', 'Trend + Seasonality (prev)',
                  'Reported (now)', 'Trend (now)', 'Trend + Seasonality (now)'),
       col = c('black', 'blue', 'red', 'black', 'blue', 'red'),
       lty = c(3, 3, 3, 1, 1, 1),
       lwd = c(1, 3, 2, 1, 3, 2), ncol = 1)