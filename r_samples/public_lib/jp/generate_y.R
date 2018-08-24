Generate_y <- function(X_media, X_ctrl, N, num_media, max_lag, retain_rate, delay, ec, slope, beta_medias, gamma_ctrl, tau, noise_sd){
  # X_media: N * num_media * (max_lag)
  # X_ctrl: N * num_ctrl
  # N: nrow(X)
  # num_media: ncol(X)
  # max_lag: just specify
  # retain_rate: 0 ~ 1, vector[num_media]
  # delay: 0 ~ (max_lag-1), vector[num_media]
  # ec: 0 ~ 1, vector[num_media]
  # slope: 0~, vector[num_media]
  # beta_medias: usually 0 ~ 0.1 (too much if exceeds 0.1)
  # gamma_ctrl: as you like it (just dummy variables)
  # tau: intercept, as you like it
  # noise_sd: SD of normal distribution noise for Y, as you like it
  mu <- rep(0, N)
  lag_weights <- rep(0, max_lag)
  cum_effects_hill <- matrix(0, nrow = N, ncol = num_media)
  for (nn in 1:N){
    for (media in 1:num_media){
      for (lag in 1:max_lag){
        lag_weights[lag] <- retain_rate[media]^((lag - 1 - delay[media])^2)
      }
      cum_effect <- Adstock(X_media[nn, media, ], lag_weights)
      cum_effects_hill[nn, media] <- Hill(as.numeric(cum_effect), ec[media], slope[media])
    }
    mu[nn] <- tau + cum_effects_hill[nn, ] %*% beta_medias + X_ctrl[nn, ] %*% gamma_ctrl
    + rnorm(1, 0, noise_sd)
  }
  return(mu)
}