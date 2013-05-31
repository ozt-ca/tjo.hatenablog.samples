function wvec=tjo_train_margin(wvec,xvec,t_label,lamda,alpha)

[out,yval]=tjo_predict(wvec,xvec);

if (yval*t_label<lamda)
    wt=wvec;
    wvec=wvec+t_label*xvec;
    wvec=wvec-alpha*wt;
end;

end