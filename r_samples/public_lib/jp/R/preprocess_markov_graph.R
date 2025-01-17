dg <- c()

for (i in 1:nrow(d)){
  # Top has only 1 touch point
  if (i == 1 && d$id[i] == d$id[i + 1] && d$id[i] != d$id[i + 1]){
    dg <- c(d$id[i], 'start', d$touch[i])
    dg <- rbind(dg, c(d$id[i], d$touch[i], 'end'))
  }
  # Top has more than 1 touch point
  if (i == 1 && d$id[i] == d$id[i + 1] && d$id[i] == d$id[i + 1]){
    dg <- c(d$id[i], 'start', d$touch[i])
  }
  # Not last, only 1 touch point
  if (i > 1 && i != nrow(d) && d$id[i] != d$id[i - 1] && d$id[i] != d$id[i + 1]){
    dg <- rbind(dg, c(d$id[i], 'start', d$touch[i]))
    dg <- rbind(dg, c(d$id[i], d$touch[i], 'end'))
  }
  # Not last, More than 1 touch point
  # Top
  if (i > 1 && i != nrow(d) && d$id[i] != d$id[i - 1] && d$id[i] == d$id[i + 1]){
    dg <- rbind(dg, c(d$id[i], 'start', d$touch[i]))
  }
  # Middle
  if (i > 1 && i != nrow(d) && d$id[i] == d$id[i - 1] && d$id[i] == d$id[i + 1]){
    dg <- rbind(dg, c(d$id[i], d$touch[i - 1], d$touch[i]))
  }
  # Last
  if (i > 1 && i != nrow(d) && d$id[i] == d$id[i - 1] && d$id[i] != d$id[i + 1]){
    dg <- rbind(dg, c(d$id[i], d$touch[i - 1], d$touch[i]))
    dg <- rbind(dg, c(d$id[i], d$touch[i], 'end'))
  }
  # Last
  if (i == nrow(d) && d$id[i] == d$id[i - 1]){
    dg <- rbind(dg, c(d$id[i], d$touch[i - 1], d$touch[i]))
    dg <- rbind(dg, c(d$id[i], d$touch[i], 'end'))
  }
  if (i == nrow(d) && d$id[i] != d$id[i - 1]){
    dg <- rbind(dg, c(d$id[i], 'start', d$touch[i]))
    dg <- rbind(dg, c(d$id[i], d$touch[i], 'end'))
  }
}

dg1 <- data.frame(id = dg[, 1], before = dg[, 2], after = dg[, 3])