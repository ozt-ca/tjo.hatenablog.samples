function tjo_NN_procedure(xvec)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nearest Neighbor法分類器 by Takashi J. OZAKI %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 非常に単純なNN法の実装コードです。
% 全ての教師信号とテスト信号との間のノルムを計算し、
% 最も短いノルムを返した教師信号が属するグループに
% テスト信号も属する、と分類しているだけです。

%%
%%%%%%%%%%%%%%%%%%%%%%%%%
% 教師信号のセッティング %
%%%%%%%%%%%%%%%%%%%%%%%%%
% xy座標系の4つの象限に各々教師信号をばら撒いています。
% ones関数でxy座標の中心値を、rand関数でばらつきを与えて、
% 3行目に4象限のいずれに属するかのクラス値を与えています。
% 即ち3 x nのマトリクスが教師信号のデータです。

% ばらつきの大きさ
c=4;

% 4象限に分けています
x1_list=[(ones(1,15)+c*rand(1,15));(ones(1,15)+c*rand(1,15));1*ones(1,15)];
x2_list=[(-1*ones(1,15)-c*rand(1,15));(ones(1,15)+c*rand(1,15));2*ones(1,15)];
x3_list=[-1*ones(1,15)-c*rand(1,15);-1*ones(1,15)-c*rand(1,15);3*ones(1,15)];
x4_list=[(ones(1,15)+c*rand(1,15));(-1*ones(1,15)-c*rand(1,15));4*ones(1,15)];

% 1つに教師信号をまとめる
x_list=[x1_list x2_list x3_list x4_list];
% 教師信号の数（列数）
cl=size(x_list,2);

%%
%%%%%%%%%%
% 判定部 %
%%%%%%%%%%
% 実際に教師信号x_listとテスト信号xvecとの間のノルムを逐次全て計算し、
% 最小ノルムを返した教師信号列ベクトルの3列目（クラス値）を返す。
gid=tjo_NN_classify(xvec,x_list,cl);
fprintf(1,'\n\nGroup %d\n\n',gid);

%%
%%%%%%%%%%%%%%%
% 可視化パート %
%%%%%%%%%%%%%%%
% Matlab関数に依存するので、ここの説明は割愛。
figure(1);

for i=1:cl/4
    scatter(x1_list(1,i),x1_list(2,i),100,'ko');hold on;
    scatter(x2_list(1,i),x2_list(2,i),100,'k+');hold on;
    scatter(x3_list(1,i),x3_list(2,i),100,'bo');hold on;
    scatter(x4_list(1,i),x4_list(2,i),100,'b+');hold on;
end;

scatter(xvec(1),xvec(2),300,'rs');hold on;

xlim([-10 10]);
ylim([-10 10]);

[xx,yy]=meshgrid(-10:0.1:10,-10:0.1:10);
cxx=size(xx,2);
zz=zeros(cxx,cxx);
for p=1:cxx
    for q=1:cxx
        for i=1:4
            zz(p,q)=tjo_NN_classify([xx(p,q);yy(p,q)],x_list,cl);
        end;
    end;
end;

contour(xx,yy,zz,[1 2 3 4]);hold on;

end