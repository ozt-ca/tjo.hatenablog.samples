function k=tjo_kernel(x1,x2,delta,kernel_choice)
%%
% 単に3種類のカーネルの中から選んでくるだけの関数です。
% 上からガウシアンRBF、線型、多項式です。

if(kernel_choice==0)
    k=tjo_kernel_gaussian(x1,x2,delta);
elseif(kernel_choice==1)
    k=tjo_kernel_linear(x1,x2);
elseif(kernel_choice==2)
    k=tjo_kernel_polynomial(x1,x2,delta);
end;

end