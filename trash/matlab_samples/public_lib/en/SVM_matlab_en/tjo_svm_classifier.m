function wvec=tjo_svm_classifier(y_list,alpha,clength)
% A function that computes "wvec" for a discriminant function
% Actually that is an inner product of y_list and alpha...

wvec=zeros(clength,1);

for i=1:clength
    wvec(i)=y_list(i)*alpha(i);
end;

end