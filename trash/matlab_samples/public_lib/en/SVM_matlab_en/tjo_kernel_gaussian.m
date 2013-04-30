function k=tjo_kernel_gaussian(x1,x2,delta)
%%
% Gaussian RBF kernel function

norm_dat=norm(x1-x2); % Computing a norm between two vectors
abs_dat=(norm_dat)^2; % Computing a squared norm
p=(abs_dat)/(2*(delta)^2); % Setting a parameter of Gaussian "x" of e^x

k=exp(-p); % Just computing a Gaussian value; maybe Math.exp in Java

end