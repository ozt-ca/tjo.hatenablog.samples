data {
  int<lower=0> N;
  real<lower=0> y[N];
}

parameters {
  real season[N];
  real trend[N];
  real s_trend;
  real s_season;
  real s_q;
}

model {
  real q[N];
  for (i in 7:N)
    season[i] ~ normal(-season[i - 1] - season[i - 2] - season[i - 3] - season[i - 4] - season[i - 5] - season[i - 6], s_season);	
  for (i in 2:N)
    trend[i] ~ normal(trend[i - 1], s_trend);
  for (i in 1:N)
    q[i] = y[i] - season[i] - trend[i];
  for (i in 1:N)
    q[i] ~ normal(0, s_q);
}
