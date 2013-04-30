function k=tjo_kernel(x1,x2,delta)
%%
% A function just choosing one from three kernel functions.
% i.e. Gaussian RBF, linear, polynomial

k=tjo_kernel_gaussian(x1,x2,delta);
% k=tjo_kernel_linear(x1,x2);
% k=tjo_kernel_polynomial(x1,x2,delta);

end