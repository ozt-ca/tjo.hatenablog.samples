function [wvec,bias]=tjo_train(wvec,bias,R,xvec,t_label)

% tjo_predict関数を用いて学習を行っています。
% y*tの値(= tw'x)が負の時に重みベクトルw(wvec)を更新します。

L=0.3; % Learn_stlength: 学習係数η

[out,yvec]=tjo_predict(wvec,bias,xvec);

if (yvec*t_label<=0)
    wvec=wvec+L*t_label*xvec;
    bias=bias+L*t_label*(R*norm(xvec));
end;

end