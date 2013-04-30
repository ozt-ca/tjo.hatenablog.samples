function m=tjo_margin(fix_v,x_var,alpha_var,y_var,delta,clength)
%%
% A function computing "margin".
% Only a fix_v is an external input (that varies in FOR loop)

m=0;

for i=1:clength
    m = m + (alpha_var(i)*y_var(i)*tjo_kernel(fix_v,x_var(:,i),delta));
end;

end