function wvec=tjo_svm_classifier(y_list,alpha,clength)

wvec=zeros(clength,1);

for i=1:clength
    wvec(i)=y_list(i)*alpha(i);
end;

end