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
ts1 <- ts(as.numeric(d3$num), frequency = 7)
ts2 <- ts(as.numeric(d4$num), frequency = 7)

# Create a title with start and end dates
mtitle <- paste0('Tokyo, daily from ', d4$day[1], ' to ', d4$day[nrow(d4)])
xrange <- c(d3$day[1], d3$day[nrow(d3)] + 20)

library(forecast)
fit <- auto.arima(ts1, trace = T, stepwise = T, seasonal = T)

plot(forecast(fit, h = 20, level = c(50, 95)),
     xlim = c(1, (nrow(d3) + 22) / 7), ylim = c(-100, 200),
     main = mtitle)
par(new = T)
plot(c((nrow(d3) / 7 + 6 / 7), (nrow(d3) / 7) + 1),
     c(d3$num[nrow(d3)], d4$num[nrow(d4)]), cex = 0.5, pch = 19,
     col = 'red', type = 'b', lwd = 2, lty = 1, xlab = '', ylab = '',
     xlim = c(1, (nrow(d3) + 22) / 7), ylim = c(-100, 200))
segments((nrow(d3) / 7) + 6 / 7, -100, (nrow(d3) / 7) + 6 / 7, 200,
        col = 'black', lwd = 1, lty = 3,
         xlim = c(1, (nrow(d3) + 22) / 7), ylim = c(-100, 200))
legend('topleft', legend = c('Reported', 'Forecasted', 'Actual'),
       col = c('black', 'blue', 'red'), lty = 1, lwd = c(1, 3, 2))