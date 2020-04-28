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

# Set up Stan env
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

# Data as a list
N <- nrow(d3)
y <- d3$num
dat <- list(N = N, y = y)

# Fit by Stan
fit <- stan('covid19_tokyo_2nd_trend.stan', data = dat,
            iter = 1000, chains = 4)

# Extract MCMC samples to obtain MLE parameters
fit.smp<-extract(fit)
trend <- rep(0, N)
for (i in 1:N) {
  tmp <- density(fit.smp$trend[, i])
  trend[i] <- tmp$x[tmp$y == max(tmp$y)]
}
season <- rep(0, N)
for (i in 1:N) {
  tmp <- density(fit.smp$season[, i])
  season[i] <- tmp$x[tmp$y == max(tmp$y)]
}
# Fitted time series
pred <- cumsum(trend) + season

# Create a title with start and end dates
mtitle <- paste0('Tokyo, daily from ', d3$day[1], ' to ', d3$day[nrow(d3)])

# Plot
matplot(cbind(y, pred, cumsum(trend)),
        type = 'l', lty = c(1, 3, 1), lwd = c(1, 2, 3), col = c(1, 2, 4),
        ylab = '', main = mtitle)
legend('topleft',
       legend = c('Reported', '2nd-diff Trend + Seasonality', '2nd-diff Trend'),
       lty = c(1, 3, 1), lwd = c(1, 2, 3), col = c(1, 2, 4))