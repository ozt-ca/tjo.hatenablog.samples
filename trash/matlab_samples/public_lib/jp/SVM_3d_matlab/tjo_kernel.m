function k=tjo_kernel(x1,x2,delta)
%%
% 単に3種類のカーネルの中から選んでくるだけの関数です。
% 上からガウシアンRBF、線型、多項式です。

k=tjo_kernel_gaussian(x1,x2,delta);
% k=tjo_kernel_linear(x1,x2);
% k=tjo_kernel_polynomial(x1,x2,delta);

end