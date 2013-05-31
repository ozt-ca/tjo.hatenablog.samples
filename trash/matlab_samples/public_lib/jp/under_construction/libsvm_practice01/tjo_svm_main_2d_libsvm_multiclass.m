function [new_m,model]=tjo_svm_main_2d_libsvm_multiclass(xvec,sigma,Cmax)
%%
% SMO実装済み

% 挙動が怪しいのでバグ取り決行
% 狙い目としては、
% 1. カーネルを多項式に変えられるようにする
% 2. マージン計算に何がしかの不備があるかもなのでチェックする
% 3. 単に最後のcontour描画に不備があるかもなので確認する

%%
% xy座標系の値を素性とした訓練データ
% 適当に決めて第1集団なら1
% 第2集団なら-1を正解ラベルとする

a=2;
c=4;
num=30;

% XOR
x1_list=[(a*ones(1,num)+c*rand(1,num));(a*ones(1,num)+c*rand(1,num))];
x2_list=[(-a*ones(1,num)-c*rand(1,num));(a*ones(1,num)+c*rand(1,num))];
x3_list=[(-a*ones(1,num)-c*rand(1,num));(-a*ones(1,num)-c*rand(1,num))];
x4_list=[(a*ones(1,num)+c*rand(1,num));(-a*ones(1,num)-c*rand(1,num))];

x_list=[x1_list x2_list x3_list x4_list];

c1=size(x1_list,2);
c2=size(x2_list,2);
c3=size(x3_list,2);
c4=size(x4_list,2);
y_list=[1*ones(c1,1);2*ones(c2,1);3*ones(c3,1);4*ones(c4,1)];

clength=c1+c2+c3+c4;

pause on;

figure(1);
scatter(x1_list(1,:),x1_list(2,:),100,'ko');hold on;
scatter(x2_list(1,:),x2_list(2,:),100,'k+');hold on;
scatter(x3_list(1,:),x3_list(2,:),100,'bo');hold on;
scatter(x4_list(1,:),x4_list(2,:),100,'b+');
xlim([-10 10]);
ylim([-10 10]);

pause(3);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LIBSVMで学習と分類をいっぺんにやってしまう %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
param_str = sprintf('-s %d -t %d -g %d -c %d',0,2,sigma,Cmax);

% model = svmtrain(y_list, x_list', '-s 0 -t 2 -g 0.5 -c 10');
model = svmtrain(y_list, x_list', param_str);
[predicted_label,accuracy,prob_estimates] = svmpredict(1, xvec',model, '');

new_m=predicted_label;

%%
% おまけで可視化
figure(2);

for i=1:c1
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
        [zz(p,q),ac,prob]=svmpredict(1,[xx(p,q);yy(p,q)]',model,'');
    end;
end;

contour(xx,yy,zz,[1 2 3 4]);hold on;

pause off;

%%
%%%%%%%%%%%%%%%%%%%%%
% 分類結果を表示する %
%%%%%%%%%%%%%%%%%%%%%

fprintf(1,'\n\nClassification result\n');

fprintf(1,'\n\nGroup %d\n\n',new_m);

end