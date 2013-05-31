function k=tjo_kernel(x1,x2,delta)

norm_dat=norm(x1-x2);
abs_dat=(norm_dat)^2;
p=(abs_dat)/(2*(delta)^2);

k=exp(-p);

end