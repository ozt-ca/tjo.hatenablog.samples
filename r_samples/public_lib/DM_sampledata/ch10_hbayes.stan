data {
	int<lower=0> N; // サンプルサイズ
	int<lower=0> y[N]; // 種子8個当たりの生存数（目的変数）
}
parameters {
	real beta; // 全個体共通のロジスティック偏回帰係数
	real r[N]; // 個体差
	real<lower=0> s; // 個体差のばらつき
}
transformed parameters {
	real q[N];
	for (i in 1:N)
		q[i] <- inv_logit(beta+r[i]); // 生存確率を個体差でロジット変換
}
model {
	for (i in 1:N)
		y[i] ~ binomial(8,q[i]); // 二項分布で生存確率をモデリング
	beta~normal(0,1.0e+2); // ロジスティック偏回帰係数の無情報事前分布
	for (i in 1:N)
		r[i]~normal(0,s); // 個体差の階層事前分布
	s~uniform(0,1.0e+4); // r[i]を表現するための無情報事前分布
}