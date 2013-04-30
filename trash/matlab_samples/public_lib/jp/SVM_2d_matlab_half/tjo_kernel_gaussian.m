function k=tjo_kernel_gaussian(x1,x2,delta)
%%
% ガウシアンRBFカーネル関数です。

norm_dat=norm(x1-x2); % 2点間のノルムを計算
abs_dat=(norm_dat)^2; % ノルム値の二乗を計算
p=(abs_dat)/(2*(delta)^2); % ガウシアンカーネルのe^xのxの部分を先に計算

k=exp(-p); % ガウシアン（指数関数e^x）を算出。JavaならMath.expとかになるはずです。

end