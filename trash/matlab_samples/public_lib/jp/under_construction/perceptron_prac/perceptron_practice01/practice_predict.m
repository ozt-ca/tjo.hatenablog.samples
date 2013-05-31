function [out,yvec]=practice_predict(wvec,xvec)

[rlength,clength]=size(xvec);
yvec=0;

for i=1:clength
    yvec=yvec+dot(wvec(1:3,i),xvec(1:3,i));
end;

if(yvec>=0)
    out=1;
else
    out=-1;
end;


end