function wvec=practice_train(wvec,xvec,t_label)

[out,yvec]=practice_predict(wvec,xvec);

if (yvec*t_label<0)
    wvec=wvec+t_label*xvec;
end;

end