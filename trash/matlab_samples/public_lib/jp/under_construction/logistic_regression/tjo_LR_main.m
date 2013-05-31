function [yvec,nE,H]=tjo_LR_main(xvec)
%%

c=4;

q1=[(1*ones(1,10)+c*rand(1,10));(1*ones(1,10)+c*rand(1,10));ones(1,10)];
q2=[(-1*ones(1,10)-c*rand(1,10));(1*ones(1,10)+c*rand(1,10));ones(1,10)];
q3=[(-1*ones(1,10)-c*rand(1,10));(-1*ones(1,10)-c*rand(1,10));ones(1,10)];
q4=[(1*ones(1,10)+c*rand(1,10));(-1*ones(1,10)-c*rand(1,10));ones(1,10)];

x1_list=[q1 q2 q4];
x2_list=[q3];

c1=size(x1_list,2); % x1_listの要素数
c2=size(x2_list,2); % x2_listの要素数
clength=c1+c2; % 全要素数：この後毎回参照することになります。

% 正解信号：x1とx2とで分離したいので、対応するインデックスに1と-1を割り振ります。
x_list=[x1_list x2_list]; % x1_listとx2_listを行方向に並べてまとめます。
y_list=[ones(c1,1);zeros(c2,1)]; % 正解信号をx1:1, x2:0として列ベクトルにまとめます。

pause on;

figure(1); % プロットウィンドウを1つ作る
scatter(x1_list(1,:),x1_list(2,:),100,'ko');hold on;
scatter(x2_list(1,:),x2_list(2,:),100,'k+');
xlim([-10 10]);
ylim([-10 10]);

pause(3);

%%
wvec=[0;0;1];

%%
[wvec,nE,H]=tjo_LR_train(wvec,x_list,y_list,clength);

yvec=tjo_LR_predict(wvec,[xvec;1]);

figure(2); % プロットウィンドウを1つ作る
scatter(x1_list(1,:),x1_list(2,:),100,'ko');hold on;
scatter(x2_list(1,:),x2_list(2,:),100,'k+');hold on;
xlim([-10 10]);
ylim([-10 10]);

if(yvec > 0.5) % テスト信号xvecがGroup 1なら赤い○でプロット
    scatter(xvec(1),xvec(2),200,'red');hold on;
elseif(yvec < 0.5) % テスト信号xvecがGroup 2なら赤い＋でプロット
    scatter(xvec(1),xvec(2),200,'red','+');hold on;
else % テスト信号xvecが万一分離超平面上なら青い○でプロット
    scatter(xvec(1),xvec(2),200,'blue');hold on;
end;

% コンター（等高線）プロット。難しいので詳細はMatlabヘルプをご参照下さい。
[xx,yy]=meshgrid(-10:0.1:10,-10:0.1:10);
cxx=size(xx,2);
zz=zeros(cxx,cxx);
for p=1:cxx
    for q=1:cxx
        zz(p,q)=tjo_LR_predict(wvec,[xx(p,q);yy(p,q);1]);
    end;
end;
contour(xx,yy,zz,50);hold on;

pause off;

end