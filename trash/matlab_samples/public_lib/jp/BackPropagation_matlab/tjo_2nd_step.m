function out=tjo_2nd_step(gvec,hvec)

% gvecは3次元ベクトル
% hvecは3次元ベクトル
% outはスカラー

param=gvec(1)*hvec(1)+gvec(2)*hvec(2)+gvec(3)*hvec(3);

out=tjo_sigmoid(param);

end