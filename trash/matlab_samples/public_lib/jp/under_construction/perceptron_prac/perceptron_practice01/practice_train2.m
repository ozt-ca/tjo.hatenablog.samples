function wvec=practice_train2(wvec,xvec,t_label)

[out,yvec]=practice_predict2(wvec,xvec);

if (yvec*t_label<0)
    wvec=wvec+t_label*xvec;
end;

end