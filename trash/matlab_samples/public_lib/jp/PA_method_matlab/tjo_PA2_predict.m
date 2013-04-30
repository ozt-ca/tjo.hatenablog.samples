function margin = tjo_PA2_predict(xvec,wvec)
% 単なる内積計算（dot関数）です。
% w'*xを計算しているだけです。

margin = dot(wvec,xvec);

end