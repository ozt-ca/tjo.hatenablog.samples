function yvec=tjo_LR_predict(xvec,wvec)
% 識別関数です。
% でも単なるシグモイド関数演算をしているだけです。
% 詳細はtjo_sigmoid関数を参照のこと。

yvec=tjo_sigmoid(dot(wvec,xvec));

end