function bias=tjo_svm_bias_estimate(x_list,y_list,alpha,delta,clength,Cmax)

bt=zeros(clength,1);

for i=1:clength
    m = tjo_margin(x_list(i),x_list,alpha,y_list,delta,clength);
    if(alpha(i)>0&&alpha(i)<Cmax) % echizen_tm‚³‚ñ‚Ì—á‚Æ“¯‚¶
        bt(i)=(1/y_list(i))-m;
    end;
end;
bias=(max(bt)+min(bt))/2;

end