function [out,yvec]=tjo_predict(wvec,xvec)

yvec=dot(wvec,xvec);

if(yvec>=0)
    out=1;
else
    out=-1;
end;


end