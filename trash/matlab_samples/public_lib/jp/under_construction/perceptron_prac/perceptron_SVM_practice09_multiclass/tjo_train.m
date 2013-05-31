function wvec=tjo_train(wvec,xvec,t_label)

[out,yvec]=tjo_predict(wvec,xvec);

if (yvec*t_label<0)
    wvec=wvec+t_label*xvec;
end;

end