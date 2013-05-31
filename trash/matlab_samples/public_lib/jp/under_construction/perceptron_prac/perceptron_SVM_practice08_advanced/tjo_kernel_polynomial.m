function k=tjo_kernel_polynomial(x1,x2,delta)

[rlength,clength]=size(x1);
length=max([rlength,clength]);

kt=0;

for i=1:length
  kt=kt+x1(i)*x2(i);  
end;

k=(1+kt)^delta;

end