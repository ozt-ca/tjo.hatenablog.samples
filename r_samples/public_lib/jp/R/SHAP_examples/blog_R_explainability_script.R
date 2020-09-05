## Simple explanation by {randomForest} as a baseline

d <- read.csv('https://raw.githubusercontent.com/ozt-ca/tjo.hatenablog.samples/master/r_samples/public_lib/jp/exp_uci_datasets/wine/wine_red_train.csv')

library(randomForest)
tuneRF(d[, -12], d[, 12], doBest = T)
fit.rf <- randomForest(quality~., d, mtry = 6)

varImpPlot(fit.rf)

par(mfrow = c(3, 4))
for (i in 1:11){
  partialPlot(fit.rf, pred.data = d, x.var = names(d)[i],
              xlab = names(d)[i], ylab = '', main = '')
}


## Try {iml}
# https://cran.r-project.org/web/packages/iml/vignettes/intro.html

library(iml)

X <- d[, -12]
predictor <- Predictor$new(fit.rf, data = X, y = d$quality)

# Feature importance

imp <- FeatureImp$new(predictor, loss = "rmse")
library(ggplot2)
plot(imp)

# Feature effects

ale <- FeatureEffect$new(predictor, feature = "citric_acid")
ale$plot()

ale$set.feature("residual_sugar")
ale$plot()

# Measure interactions

interact <- Interaction$new(predictor)
plot(interact)

interact <- Interaction$new(predictor, feature = "sulphates")
plot(interact)

effs <- FeatureEffects$new(predictor)
plot(effs)

# Surrogate model

tree <- TreeSurrogate$new(predictor, maxdepth = 2)
plot(tree)


# LIME: Explain single predictions with a local model

lime.explain <- LocalModel$new(predictor, x.interest = X[sample(nrow(d), 1, F), ])
lime.explain$results
plot(lime.explain)

lime.explain$explain(X[sample(nrow(d), 1, F), ])
plot(lime.explain)

# Shapley: Explain single predictions with game theory

shapley <- Shapley$new(predictor, x.interest = X[sample(nrow(d), 1, F), ])
shapley$plot()

shapley$explain(x.interest = X[sample(nrow(d), 1, F), ])
shapley$plot()


## SHAP-analysis by pablo14
## https://github.com/pablo14/shap-values

library(tidyverse)
library(xgboost)
library(caret)
source("https://raw.githubusercontent.com/pablo14/shap-values/master/shap.R")

d_mx <- as.matrix(d)

# Create the xgboost model
model_wine <- xgboost(data = d_mx[, -12], 
                      nround = 10, 
                      objective="reg:linear",
                      label= d_mx[, 12])  

# Note: The functions `shap.score.rank, `shap_long_hd` and `plot.shap.summary`
# were originally published at https://github.com/liuyanguu/Blogdown/blob/master/hugo-xmag/content/post/2018-10-05-shap-visualization-for-xgboost.Rmd
# All the credits to the author.

# Calculate shap values
shap_result_wine <- shap.score.rank(xgb_model = model_wine, 
                                    X_train = d_mx[, -12],
                                    shap_approx = F
                                    )

# `shap_approx` comes from `approxcontrib` from xgboost documentation. 
# Faster but less accurate if true. Read more: help(xgboost)

# Plot var importance based on SHAP

var_importance(shap_result_wine, top_n = ncol(d_mx) - 1)

# Prepare data for top N variables

shap_long_wine <- shap.prep(shap = shap_result_wine,
                            X_train = d_mx[, -12], 
                            top_n = ncol(d_mx) - 1
                            )

# Plot shap overall metrics

plot.shap.summary(data_long = shap_long_wine)

xgb.plot.shap(data = d_mx[, -12], # input data
              model = model_wine, # xgboost model
              features = names(shap_result_wine$mean_shap_score[1 : (ncol(d_mx) - 1)]), # only top 10 var
              n_col = 3, # layout option
              plot_loess = T # add red line to plot
              )


## Try some parts of {SHAPforxgboost}
## https://liuyanguu.github.io/post/2019/07/18/visualization-of-shap-for-xgboost/

library(SHAPforxgboost)

# Dependence plot

g1 <- shap.plot.dependence(data_long = shap_long_wine,
                           x = 'alcohol', y = 'alcohol',
                           color_feature = 'sulphates') + ggtitle("(A) SHAP values of alcohol vs. alcohol")
g2 <- shap.plot.dependence(data_long = shap_long_wine,
                           x = 'alcohol', y = 'sulphates',
                           color_feature = 'sulphates') +  ggtitle("(B) SHAP values of sulphates vs. alcohol")

gridExtra::grid.arrange(g1, g2, ncol = 2)

# Interaction effects

shap_int_wine <- shap.prep.interaction(xgb_mod = model_wine,
                                       X_train = d_mx[, -12])
g3 <- shap.plot.dependence(data_long = shap_long_wine,
                           data_int = shap_int_wine,
                           x= "alcohol", y = "sulphates", 
                           color_feature = "sulphates")
g4 <- shap.plot.dependence(data_long = shap_long_wine,
                           data_int = shap_int_wine,
                           x= "sulphates", y = "volatile_acidity",
                           color_feature = "volatile_acidity")
gridExtra::grid.arrange(g3, g4, ncol=2)

# SHAP force plot

shap_values <- shap.values(xgb_model = model_wine, X_train = d_mx[, -12])

plot_data <- shap.prep.stack.data(shap_contrib = shap_values$shap_score,
                                  top_n = 4, n_groups = 6)
shap.plot.force_plot(plot_data, zoom_in_location = 500,
                     y_parent_limit = c(-1.5,1.5))

shap.plot.force_plot_bygroup(plot_data)