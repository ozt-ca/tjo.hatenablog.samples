function out=tjo_1st_step(xvec,wvec)

% xvecは3x1
% wvecは3x2
% out（実際にはgvecになる）は3x1

param=zeros(2,1);
out=zeros(3,1);

param(1)=xvec(1)*wvec(1,1)+xvec(2)*wvec(2,1)+xvec(3)*wvec(3,1);
param(2)=xvec(1)*wvec(1,2)+xvec(2)*wvec(2,2)+xvec(3)*wvec(3,2);

out(1)=tjo_sigmoid(param(1));
out(2)=tjo_sigmoid(param(2));
out(3)=1; % バイアス項

end