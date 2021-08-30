d <- read.csv('https://stopcovid19.metro.tokyo.lg.jp/data/130001_tokyo_covid19_details_testing_positive_cases.csv')

d1 <- d[248:nrow(d), c(4, 5, 7, 8, 12)]
d2 <- d[247:nrow(d), c(4, 5, 7, 8, 12)]
tmp1 <- diff(d2[, 2])
tmp2 <- diff(d2[, 5])
d1[, 2] <- tmp1
d1[, 5] <- tmp2
names(d1) <- c('day', 'positive', 'medium', 'severe', 'dead')

dn <- d1
dn[, -1] <- apply(dn[, -1], 2, scale)
dn2 <- dn
dn2$positive <- stl(ts(dn2$positive, frequency = 7),
                    s.window = 'per')$time.series[, 2]
dn2$medium <- stl(ts(dn2$medium, frequency = 7),
                  s.window = 'per')$time.series[, 2]
dn2$severe <- stl(ts(dn2$severe, frequency = 7),
                  s.window = 'per')$time.series[, 2]
dn2$dead <- stl(ts(dn2$dead, frequency = 7),
                s.window = 'per')$time.series[, 2]
dayseq <- dn2[, 1]
dayseq <- as.data.frame(dayseq)

bin <- floor(nrow(dayseq) / 9)
xval <- seq(1, bin * 9 + 1, by = bin)
xstr <- as.character(dayseq$day[xval])

matplot(dn2[, -1], type = 'l', lty = 1, ylab = '', xaxt = 'n', lwd = 2,
        main = 'Normalized values of 4 COVID metrics in Tokyo')
axis(side = 1, at = xval, labels = xstr)
legend('topleft', legend = c('Positive', 'Mild & Medium', 'Critical', 'Dead'),
       lty = 1, lwd = 3, col = 1:4, ncol = 2)
