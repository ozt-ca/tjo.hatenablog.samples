function yvec=tjo_LR_predict(xvec,wvec)

yvec=tjo_sigmoid(dot(wvec,xvec));

end