function m=tjo_margin(fix_v,x_var,alpha_var,y_var,delta,clength)

% xvec‚¾‚¯‚ª•Ï”

m=0;

for i=1:clength
    m = m + (alpha_var(i)*y_var(i)*tjo_kernel(fix_v,x_var(i),delta));
end;

end