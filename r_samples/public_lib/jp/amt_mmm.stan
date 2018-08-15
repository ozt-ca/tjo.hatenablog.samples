functions {
  // the Hill function
  real Hill(real t, real ec, real slope) {
    return 1 / (1 + (t / ec)^(-slope));
  }
  // the adstock transformation with a vector of weights
  real Adstock(row_vector t, row_vector weights) {
    return dot_product(t, weights) / sum(weights);
  }
}

data {
  // the total number of observations
  int<lower=1> N;
  // the vector of sales
  real<lower=0> Y[N];
  // the maximum duration of lag effect, in weeks
  int<lower=1> max_lag;
  // the number of media channels
  int<lower=1> num_media;
  // a vector of 0 to max_lag - 1
  row_vector[max_lag] lag_vec;
  // 3D array of media variables
  row_vector[max_lag] X_media[N, num_media];
  // the number of other control variables
  int<lower=1> num_ctrl;
  // a matrix of control variables
  row_vector[num_ctrl] X_ctrl[N];
}
  
parameters {
  // residual variance
  real<lower=0> noise_var;
  // the intercept
  real tau;
  // the coefficients for media variables
  vector<lower=0>[num_media] beta_medias;
  // coefficients for other control variables
  vector[num_ctrl] gamma_ctrl;
  // the retention rate and delay parameter for the adstock transformation of
  // each media
  vector<lower=0,upper=1>[num_media] retain_rate;
  vector<lower=0,upper=max_lag-1>[num_media] delay;
  // ec50 and slope for Hill function of each media
  vector<lower=0,upper=1>[num_media] ec;
  vector<lower=0>[num_media] slope;
}

transformed parameters {
  // a vector of the mean response
  real mu[N];
  // the cumulative media effect after adstock
  real cum_effect;
  // the cumulative media effect after adstock, and then Hill transformation
  row_vector[num_media] cum_effects_hill[N];
  row_vector[max_lag] lag_weights;
  for (nn in 1:N) {
    for (media in 1 : num_media) {
      for (lag in 1 : max_lag) {
        lag_weights[lag] = pow(retain_rate[media], (lag - 1 - delay[media]) ^ 2);
      }
      cum_effect = Adstock(X_media[nn, media], lag_weights);
      cum_effects_hill[nn, media] = Hill(cum_effect, ec[media], slope[media]);
    }
    mu[nn] = tau +
      dot_product(cum_effects_hill[nn], beta_medias) +
      dot_product(X_ctrl[nn], gamma_ctrl);
  }
}

model {
  retain_rate ~ beta(3,3);
  delay ~ uniform(0, max_lag - 1);
  slope ~ gamma(3, 1);
  ec ~ beta(2,2);
  tau ~ normal(0, 5);
    for (media_index in 1 : num_media) {
      beta_medias[media_index] ~ normal(0, 1);
    }
    for (ctrl_index in 1 : num_ctrl) {
      gamma_ctrl[ctrl_index] ~ normal(0,1);
    }
    noise_var ~ inv_gamma(0.05, 0.05 * 0.01);
    Y ~ normal(mu, sqrt(noise_var));
}
