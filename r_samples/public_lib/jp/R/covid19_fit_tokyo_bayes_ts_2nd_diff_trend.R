# Input today's date and reported number
nday <- '2020-12-19'
nval <- 736

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
d3[(nrow(d3) + 1), ] <- c(nday, nval) # Here please write down
d3$num <- as.numeric(d3$num)

# Remove duplicates
d4 <- d3 %>% distinct(day, .keep_all = T)


# Set up Stan env
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

# Data as a list
N <- nrow(d4)
y <- d4$num
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
mtitle <- paste0('Tokyo, daily from ', d4$day[1], ' to ', d4$day[nrow(d4)])

# Plot
matplot(cbind(y, pred, cumsum(trend)),
        type = 'l', lty = c(1, 3, 1), lwd = c(1, 2, 3), col = c(1, 2, 4),
        ylab = '', main = mtitle)
legend('topleft',
       legend = c('Reported', '2nd-diff Trend + Seasonality', '2nd-diff Trend'),
       lty = c(1, 3, 1), lwd = c(1, 2, 3), col = c(1, 2, 4))
plot(trend, type = 'l', lwd = 2)
plot(season, type = 'l', lwd = 2)


# Plot for JPG files
jpeg(filename = 'covid19_fit_summary.jpg', width = 720, height = 540)
matplot(cbind(y, pred, cumsum(trend)),
        type = 'l', lty = c(1, 3, 1), lwd = c(1, 2, 3), col = c(1, 2, 4),
        ylab = '', main = mtitle)
legend('topleft',
       legend = c('Reported', '2nd-diff Trend + Seasonality', '2nd-diff Trend'),
       lty = c(1, 3, 1), lwd = c(1, 2, 3), col = c(1, 2, 4), cex = 1.5)
dev.off()

jpeg(filename = 'covid19_fit_trend.jpg', width = 720, height = 540)
plot(trend, type = 'l', lwd = 2)
dev.off()

jpeg(filename = 'covid19_fit_season.jpg', width = 720, height = 540)
plot(season, type = 'l', lwd = 2)
dev.off()

# Set up a description for reporting on Twitter
ctrend <- cumsum(trend)
paste0("本日の東京都の報告数は", nval, "名、",
       "二階差分トレンドの直近7日間の推定値は",
       signif(rev(ctrend)[7], 3), ", ",
       signif(rev(ctrend)[6], 3), ", ",
       signif(rev(ctrend)[5], 3), ", ",
       signif(rev(ctrend)[4], 3), ", ",
       signif(rev(ctrend)[3], 3), ", ",
       signif(rev(ctrend)[2], 3), ", ",
       signif(rev(ctrend)[1], 3),
       "、",
       "7日周期成分の推定値は",
       signif(rev(season)[7], 3), ", ",
       signif(rev(season)[6], 3), ", ",
       signif(rev(season)[5], 3), ", ",
       signif(rev(season)[4], 3), ", ",
       signif(rev(season)[3], 3), ", ",
       signif(rev(season)[2], 3), ", ",
       signif(rev(season)[1], 3),
       "、",
       "トレンドの直近3日間の差分値は",
       signif(rev(trend)[3], 3), ", ",
       signif(rev(trend)[2], 3), ", ",
       signif(rev(trend)[1], 3), "。"
)
paste0("東京都の医療リソースの残り容量に関する各指標は画像の通り")
paste0("使用したRコード・Stanコードは以下の通り https://github.com/ozt-ca/tjo.hatenablog.samples/blob/master/r_samples/public_lib/jp/R/covid19_fit_tokyo_bayes_ts_2nd_diff_trend.R https://github.com/ozt-ca/tjo.hatenablog.samples/blob/master/r_samples/public_lib/jp/R/covid19_tokyo_2nd_trend.stan")

# Trace each generation

da1 <- data.frame(day = d[, 5], age = d[, 9], num = 1)
da1$day <- as.Date((da1$day))
da2 <- da1 %>% group_by(day, age) %>% summarise(sum(num)) %>% as.data.frame()
da3 <- left_join(dayseq, da2, by = 'day')
names(da3)[3] <- 'num'
da3[which(is.na(da3$num)), 3] <- 0
da4 <- da3[2045:(nrow(da3)), ]
gtitle <- paste0('Tokyo, daily from ',
                 da4$day[1], ' to ', da4$day[nrow(da4)], ' by generations')
matplot(cbind(da4[da4$age == '20代', 3],
              da4[da4$age == '30代', 3],
              da4[da4$age == '40代', 3],
              da4[da4$age == '50代', 3],
              da4[da4$age == '60代', 3],
              da4[da4$age == '70代', 3],
              da4[da4$age == '80代', 3],
              da4[da4$age == '90代', 3]),
        type = 'l', lty = 1, xlab = '', ylab = '',
        main = gtitle)
legend('topleft',
       legend = c('20s', '30s', '40s', '50s', '60s', '70s', '80s', '90s'),
       lty = 1, col = c(1, 2, 3, 4, 5, 6, 'orange', 8), ncol = 2)
jpeg(filename = 'covid19_fit_generation.jpg', width = 720, height = 540)
matplot(cbind(da4[da4$age == '20代', 3],
              da4[da4$age == '30代', 3],
              da4[da4$age == '40代', 3],
              da4[da4$age == '50代', 3],
              da4[da4$age == '60代', 3],
              da4[da4$age == '70代', 3],
              da4[da4$age == '80代', 3],
              da4[da4$age == '90代', 3]),
        type = 'l', lty = 1, xlab = '', ylab = '',
        main = gtitle)
legend('topleft',
       legend = c('20s', '30s', '40s', '50s', '60s', '70s', '80s', '90s'),
       lty = 1, col = c(1, 2, 3, 4, 5, 6, 'orange', 8), ncol = 2)
dev.off()