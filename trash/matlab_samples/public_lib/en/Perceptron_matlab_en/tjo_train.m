function wvec=tjo_train(wvec,xvec,t_label)

% This codes trains the weight vector wvec using "tjo_predict" function.
% If y*t (= tw'x) < 0, it updates wvec.

[out,yvec]=tjo_predict(wvec,xvec);

if (yvec*t_label<0)
    wvec=wvec+t_label*xvec;
end;

end