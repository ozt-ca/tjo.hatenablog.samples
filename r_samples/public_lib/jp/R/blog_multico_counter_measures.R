# --------------------------------------------------------------------------
# 1. ベースとなるデータの生成
# --------------------------------------------------------------------------
# 再現性のための乱数シード設定
set.seed(123)

# サンプルサイズ
n <- 100

# 説明変数の数
p <- 5

# 真の回帰係数
beta <- c(1.0, 2.0, -2.0, 5.0, -3.5)

# 説明変数の生成 (行列として)
X <- matrix(rnorm(n * p), nrow = n, ncol = p)

# 誤差項の生成
epsilon <- rnorm(n, mean = 0, sd = 2)

# 目的変数の生成
y <- X %*% beta + epsilon

# データをデータフレームにまとめる
sim_data <- as.data.frame(X)
colnames(sim_data) <- paste0("x", 1:p)
sim_data$y <- y

# 線形回帰分析を行い、結果を出力する
summary(lm(y ~., sim_data))

# --------------------------------------------------------------------------
# 2. 多重共線性を持つ変数 (x6, x7) の生成
# --------------------------------------------------------------------------

# x6 の生成 (x2 に基づく)
# シードを設定し、標準偏差の小さい正規乱数を加える
set.seed(456)
noise1 <- rnorm(n, mean = 0, sd = 0.1) # sd=0.1 の小さいノイズ
x6 <- sim_data$x2 + noise1

# x7 の生成 (x5 に基づく)
# 異なるシードを設定し、標準偏差の小さい正規乱数を加える
set.seed(789)
noise2 <- rnorm(n, mean = 0, sd = 0.1) # sd=0.1 の小さいノイズ
x7 <- sim_data$x5 + noise2

# 元のデータに新しい変数を追加
multicol_data <- sim_data
multicol_data$x6 <- x6
multicol_data$x7 <- x7

# 生成されたデータの最初の6行を表示
print(head(multicol_data))

# --------------------------------------------------------------------------
# 3. 多重共線性の影響を確認
# --------------------------------------------------------------------------

# 新しいデータで回帰モデルを構築
model_multicol <- lm(y ~ x1 + x2 + x3 + x4 + x5 + x6 + x7, data = multicol_data)

# 結果の要約を表示
print(summary(model_multicol))

# VIF (分散拡大要因) を計算
print(car::vif(model_multicol))


merged_data <- data.frame(y = multicol_data$y,
                          x1 = multicol_data$x1,
                          x2 = multicol_data$x2 + multicol_data$x6,
                          x3 = multicol_data$x3,
                          x4 = multicol_data$x4,
                          x5 = multicol_data$x5 + multicol_data$x7)
summary(lm(y ~., merged_data))
car::vif(lm(y ~., merged_data))


biplot(princomp(multicol_data[, -6]))


multicol_data.cv.glmnet1 <- glmnet::cv.glmnet(as.matrix(multicol_data[, -6]),
                                             as.matrix(multicol_data[, 6]),
                                             family = "gaussian",
                                             alpha = 1)
coef(multicol_data.cv.glmnet1, s = multicol_data.cv.glmnet1$lambda.min)


multicol_data.cv.glmnet2 <- glmnet::cv.glmnet(as.matrix(multicol_data[, -6]),
                                              as.matrix(multicol_data[, 6]),
                                              family = "gaussian",
                                              alpha = 0)
coef(multicol_data.cv.glmnet2, s = multicol_data.cv.glmnet2$lambda.min)



# --------------------------------------------------------------------------
# ベイズ回帰：事前分布のパラメータを設定
# --------------------------------------------------------------------------
# モデル式: y ~ x1 + x2 + x3 + x4 + x5 + x6 + x7
# 係数の順序: (Intercept), x1, x2, x3, x4, x5, x6, x7

# 事前分布の平均ベクトル (b0)
# x2の係数(3番目)に 2.0, x5の係数(6番目)に -3.5 を設定
b0 <- c(0, 0, 2.0, 0, 0, -3.5, 0, 0) 

# 事前分布の精度行列 (B0)
# 8x8の対角行列を作成し、対角成分を0.5とする（分散2に相当）
# これにより、やや強い事前分布を与える
B0 <- diag(8) * 0.5


# --------------------------------------------------------------------------
# MCMCregressによるベイズ線形回帰分析の実行
# --------------------------------------------------------------------------
# 再現性のためのシード設定
set.seed(111) 

# MCMCの実行
# burnin: 初期サンプルのうち、捨てる数
# mcmc: 最終的に保持するサンプルの数
model_bayes <- MCMCpack::MCMCregress(
  formula = y ~ x1 + x2 + x3 + x4 + x5 + x6 + x7,
  data = multicol_data,
  b0 = b0,      # 事前分布の平均
  B0 = B0,      # 事前分布の精度
  burnin = 2000,
  mcmc = 20000,
  verbose = 1000 # 1000回ごとに進捗を表示
)

# --------------------------------------------------------------------------
# 結果の確認
# --------------------------------------------------------------------------
# 結果の要約を表示
print(summary(model_bayes))

# 結果をプロットして確認
# 左側: 各係数の事後分布の密度プロット
# 右側: MCMCサンプルのトレースプロット（サンプリングがうまく収束しているかを確認）
plot(model_bayes)
