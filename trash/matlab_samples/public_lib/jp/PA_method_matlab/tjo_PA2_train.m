function wvec = tjo_PA2_train(wvec,x_list,y_list,Cmax,loop)
% ヒンジ損失関数に基づいて、重みベクトルwvecの更新則を分岐させています。
% PA法において、ヒンジ損失関数ltは
%
% lt = 0 (y*w'*x >= 1) or 1-(y*w'*x) (else)
%
% と定義されます。このltに対し、重みベクトルw(t)の更新則はPA2法では
%
% w(t+1) = w(t) + tau * y(t) * x(t)
% （ただしx(t)は教師信号、y(t)は正解ラベル信号、
%  tau = lt / (||x(t)||^2 + 1/2C)とする）
%
% と表されます。これを実装したのが下記のコードです。

cl=size(x_list,2);

for i=1:loop
    for j=1:cl
        if(y_list(j)*(dot(wvec,x_list(:,j)))>=1)
            lt=0;
        else
            lt=1-(y_list(j)*(dot(wvec,x_list(:,j))));
        end;
        tau=lt/((norm(x_list(:,j)))^2+(0.5/Cmax));
        wvec = wvec + tau*y_list(j)*x_list(:,j);
    end;
end;

end