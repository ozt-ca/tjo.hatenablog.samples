function [out,yvec]=tjo_predict(wvec,xvec)

% Merely this code computes the discriminant function (y = w'x).
% "out" is just a sign of the function.

yvec=dot(wvec,xvec); % "dot" function returns inner products (wvec'*xvec).

if(yvec>0)
    out=1;
elseif(yvec<0)
    out=-1;
else
    out=0;
end;


end