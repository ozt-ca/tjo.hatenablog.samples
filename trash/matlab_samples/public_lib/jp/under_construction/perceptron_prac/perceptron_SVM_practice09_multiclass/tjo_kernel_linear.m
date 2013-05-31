function k=tjo_kernel_linear(x1,x2,delta)

[rl,cl]=size(x1);
length=max([rl,cl]);
k=0;
for i=1:length
    k = k + x1(i)*x2(i);
end;

end