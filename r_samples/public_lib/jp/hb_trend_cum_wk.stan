data {
	int<lower=0> N;
	real<lower=0> x1[N];
	real<lower=0> x2[N];
	real<lower=0> x3[N];
	real<lower=0> y[N];
}

parameters {
	real wk[N];
	real trend[N];
	real s_trend;
	real s_q;
	real s_wk;
	real<lower=0> a;
	real<lower=0> b;
	real<lower=0> c;
	real d;
}

model {
	real q[N];
	real cum_trend[N];
	trend~normal(30,10);
	wk~normal(500,400);
	for (i in 8:N)
		wk[i]~normal(wk[i-7],s_wk); // ここは微妙に謎。状態空間のテキスト読むと違うので
	
	for (i in 3:N)
		trend[i]~normal(2*trend[i-1]-trend[i-2],s_trend);

	cum_trend[1]<-trend[1];
	for (i in 2:N)
		cum_trend[i]<-cum_trend[i-1]+trend[i];

	for (i in 1:N)
		q[i]<-y[i]-wk[i]-cum_trend[i];
	for (i in 1:N)
		q[i]~normal(a*x1[i]+b*x2[i]+c*x3[i]+d,s_q);
}