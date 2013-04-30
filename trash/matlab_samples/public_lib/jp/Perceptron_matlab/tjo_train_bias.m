function wvec=tjo_train_bias(wvec,xvec,t_label)

% tjo_predict関数を用いて学習を行っています。
% y*tの値(= tw'x)が負の時に重みベクトルw(wvec)を更新します。

[out,yvec]=tjo_predict_bias(wvec,xvec);

if (yvec*t_label<=0)
    wvec=wvec+t_label*xvec;
end;

end