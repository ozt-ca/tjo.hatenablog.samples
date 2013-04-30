function [wvec_new,nE,H]=tjo_LR_train(wvec,x_list,y_list,clength)
% 学習部です。
% ∇E(w)とH = ∇∇E(w)を求めて、そこからwを更新します。
% それぞれ、
% 
% ∇E(w) = Σ(y_n-t_n)*x_n
% H = Σy_n*(1-y_n)*x_n*x_n'
% 
% と求まります。一方重みベクトルwの更新式は
% 
% w_new = w_old - inverse(H)*∇E(w)
% （inverse()は逆行列演算）
% 
% なるIRLS法に従う最急降下法チックな形で表されます。
% なお、上式の通り逆行列の演算が必要となるため、
% Javaなどでは線形代数演算のライブラリを用意する必要があります。
% ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

nE=[0;0;0]; % ∇E(w)の初期化
H=[0 0 0;0 0 0;0 0 0]; % H = ∇∇E(w)の初期化
wvec_new=[1;1;1]; % wの初期化（バイアス計算を自動化するので次数が1つ多い）
wvec_old=wvec; % w_oldの初期化

while (norm(wvec_new-wvec_old)/norm(wvec_old) > 0.01)   % 打ち切り基準は重みベクトルwの変化量が10%以下になった時です。
    for j=1:clength
        nE=nE+(tjo_sigmoid(wvec_old'*x_list(:,j))-y_list(j))*x_list(:,j);
        H=H+y_func(wvec_old,x_list(:,j))*(1-y_func(wvec_old,x_list(:,j)))*x_list(:,j)*(x_list(:,j))';
    end;
    wvec_new=wvec_old-(inv(H))*nE;  % ここに逆行列演算のための線形代数ライブラリが必要となります。
    wvec_old=wvec_new; % 打ち切り基準計算のためにwの値を演算の前後で保持しておきます。
end

end