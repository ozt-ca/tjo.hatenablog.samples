function new_m=tjo_svm_trial(xvec,wvec,x_list,delta,bias,clength)
% A function that classifies an input vector (test signal) xvec using the
% SVM discriminant function already estimated.
% Actually it computes only a margin from inputs as "wvec" and "bias".

wbyx=0;

for i=1:clength
    wbyx = wbyx+wvec(i)*tjo_kernel(xvec,x_list(:,i),delta);
end;

new_m=wbyx+bias;

% Showing the result on the command line
if(new_m > 0)
    fprintf(1,'Group 1\n\n');
elseif(new_m < 0)
    fprintf(1,'Group 2\n\n');
else
    fprintf(1,'On the border\n\n');
end;

end