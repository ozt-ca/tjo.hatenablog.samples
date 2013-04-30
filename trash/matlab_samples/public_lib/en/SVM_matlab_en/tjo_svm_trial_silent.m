function new_m=tjo_svm_trial_silent(xvec,wvec,x_list,delta,bias,clength)
% Almost the same as "tjo_svm_trial" function
% This omits outputs on the command line.

wbyx=0;

for i=1:clength
    wbyx = wbyx+wvec(i)*tjo_kernel(xvec,x_list(:,i),delta);
end;

new_m=wbyx+bias;

end