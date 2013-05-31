function k=tjo_kernel(x1,x2,delta)

normx1x2=norm(x1-x2);
absx1x2=normx1x2*normx1x2;

k=exp(-(absx1x2)/(2*delta^2));

end