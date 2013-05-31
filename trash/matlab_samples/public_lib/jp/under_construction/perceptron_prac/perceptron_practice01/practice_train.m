function wvec=practice_train(wvec,xvec,t_label)

[rlength,clength]=size(xvec);
[out,yvec]=practice_predict(wvec,xvec);

if (yvec*t_label<0)
    for i=1:clength
        wvec(1:3,i)=wvec(1:3,i)+t_label*xvec(1:3,i);
    end;
end;

end