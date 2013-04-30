function [wvec,hvec]=tjo_bp_train(wvec,hvec,x_list,y_list,clength,k,loop)
% 入力層と中間層の両方を学習する関数です。
% 引数は初期化された2つの重みベクトル、教師信号、正解ラベル信号、
% 教師信号の個数、学習係数、ループ上限です。

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 各種一時使用されるパラメータの初期化 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
err=zeros(3,1); % 中間層に逆伝播させる誤差
ek=zeros(3,1); % 入力層に逆伝播させる誤差
hvec_n=zeros(3,1); % hvecの更新後の値
wvec_n=zeros(3,1); % wvecの更新後の値

%%
for i=1:loop
    for j=1:clength
        gvec=tjo_1st_step(x_list(:,j),wvec); % 入力層→中間層
        u=tjo_2nd_step(gvec,hvec); % 中間層→入力層

        %%%%%%%%%%%%%%%%%
        % ここから学習部 %
        %%%%%%%%%%%%%%%%%
        
        p=(y_list(j)-u)*u*(1-u); % 定義式に従って誤差係数を算出
        
        % 中間層に逆伝播させる誤差
        err(1)=p*gvec(1);
        err(2)=p*gvec(2);
        err(3)=p*gvec(3);

        % 中間層の重みベクトルを更新
        hvec_n(1)=hvec(1)+err(1)*k;
        hvec_n(2)=hvec(2)+err(2)*k;
        hvec_n(3)=hvec(3)+err(3)*k;
        
        % さらに入力層に逆伝播させる誤差
        ek(1)=err(1)*hvec_n(1)*gvec(1)*(1-gvec(1));
        ek(2)=err(2)*hvec_n(2)*gvec(2)*(1-gvec(2));
        ek(3)=err(3)*hvec_n(3)*gvec(3)*(1-gvec(3));
        
        % 入力層の重みベクトルを更新
        wvec_n(1,1)=wvec(1,1)+x_list(1,j)*err(1)*k;
        wvec_n(2,1)=wvec(2,1)+x_list(2,j)*err(2)*k;
        wvec_n(3,1)=wvec(3,1)+x_list(3,j)*err(3)*k;
        wvec_n(1,2)=wvec(1,2)+x_list(1,j)*err(1)*k;
        wvec_n(2,2)=wvec(2,2)+x_list(2,j)*err(2)*k;
        wvec_n(3,2)=wvec(3,2)+x_list(3,j)*err(3)*k;
        
        wvec=wvec_n;
        hvec=hvec_n;
    end;
end;

end