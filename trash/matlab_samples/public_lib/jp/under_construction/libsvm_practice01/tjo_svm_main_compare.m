function [new_m1,new_m2,alpha,bias,linear_index]=tjo_svm_main_compare(xvec,delta,Cmax,loop,kernel_choice)
%%
%%%%%%%%%%%%%%%%%
% 教師信号の設定 %
%%%%%%%%%%%%%%%%%

t=6;
c=7;
d=50;

% XOR非線型パターン：ちょっと密集させてみた
x1_list=[[(-t*ones(1,d)+c*rand(1,d));(t*ones(1,d)-c*rand(1,d))] ...
    [(t*ones(1,d)-c*rand(1,d));(-t*ones(1,d)+c*rand(1,d))]];
x2_list=[[(t*ones(1,d)-c*rand(1,d));(t*ones(1,d)-c*rand(1,d))] ...
    [-t*ones(1,d)+c*rand(1,d);-t*ones(1,d)+c*rand(1,d)]];

c1=size(x1_list,2); % x1_listの要素数
c2=size(x2_list,2); % x2_listの要素数
clength=c1+c2; % 全要素数：この後毎回参照することになります。

% 正解信号：x1とx2とで分離したいので、対応するインデックスに1と-1を割り振ります。
x_list=[x1_list x2_list]; % x1_listとx2_listを行方向に並べてまとめます。
y_list=[ones(c1,1);-1*ones(c2,1)]; % 正解信号をx1:1, x2:-1として列ベクトルにまとめます。

pause on;

figure(1); % プロットウィンドウを1つ作る
scatter(x1_list(1,:),x1_list(2,:),100,'ko');hold on;
scatter(x2_list(1,:),x2_list(2,:),100,'k+');
% プロット範囲をx,yともに[-10 10]の正方形領域内に設定
xlim([-10 10]);
ylim([-10 10]);

pause(2);

%%
%%%%%%%%%%%%%%%%%
% 各変数の初期化 %
%%%%%%%%%%%%%%%%%
% zeros関数で全要素0のベクトルを作る。

% ラグランジュ乗数α（詳細は赤本参照のこと）
alpha=zeros(clength,1);
% 学習係数（これまた詳細は赤本参照のこと：通常0-2ぐらいに収める）
learn_stlength=0.5;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ラグランジュ乗数αの推定＆SMO %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ここではαを推定する＝学習ルーチン。
% SMOを用いて、Σalpha*y_list = 0なる線型制約を満たしながら、
% なおかつKKT条件を満足するαを推定するという凸2次最適化問題を解く。
% （わからなければ赤本を読みましょう！）

% KKT条件に基づいてラグランジュ未定乗数法を解くためには、
% 教師信号x_list、正解信号y_list、初期化しただけのラグランジュ乗数alpha、
% カーネルの形状定数delta（本当はσですごめんなさい）、
% 全要素数の値clength、学習係数learn_stlength、SMO打ち切り上限回数loop、
% が必要になる。詳細はtjo_smoの記述を参照のこと。

[alpha,bias]=tjo_smo(x_list,y_list,alpha,delta,Cmax,clength,learn_stlength,loop,kernel_choice);

% ラグランジュ乗数alphaとバイアスbiasの両方が同時に求まる。
% これで分離関数に必要な定数が全て得られたことになる。

%%
%%%%%%%%%%%%%%%%%%%%%%%
% 分離関数を完成させる %
%%%%%%%%%%%%%%%%%%%%%%%
% 分離関数の算出に必要なwベクトル(wvec)を求める。
% wvecは正解信号y_listと推定済みラグランジュ乗数alphaの2つから求まる。

wvec=tjo_svm_classifier(y_list,alpha,clength);

% wvecとbiasを分離関数tjo_svm_trialに入力すれば、テスト実行が可能。


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 分類してみる(Trial / Testing) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 実際に推定済みのwvecとbiasの2定数から分離関数を構成し、
% テスト信号xvecに対する決定関数値new_mを求める。
% new_m > 0ならx1側(Group 1)、new_m < 0ならx2側(Group 2)と判定される。
% 関数tjo_svm_trialはコマンドラインに判定結果の表示も行う。

new_m1=tjo_svm_trial(xvec,wvec,x_list,delta,bias,clength,kernel_choice);

% SMOが途中打ち切りになった場合に備えて、線型制約Σalpha*y_list = 0を
% 満たしているかどうかを計算する。
linear_index=y_list'*alpha;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LIBSVMで学習と分類をいっぺんにやってしまう %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% param_str = sprintf('-s %d -t %d -g %d -c %d',0,2,1/delta,Cmax);
param_str = sprintf('-s %d -t %d',0,2);

% model = svmtrain(y_list, x_list', '-s 0 -t 2 -g 0.5 -c 10');
model = svmtrain(y_list, x_list', param_str);
[predicted_label,accuracy,prob_estimates] = svmpredict(1, xvec',model, '');

new_m2=predicted_label;
%%
%%%%%%%%%%%%%%%%%%%%%
% 可視化（プロット） %
%%%%%%%%%%%%%%%%%%%%%
% Matlab最大の武器である可視化パート。
% コメントのないところは適宜Matlabヘルプをご参照下さい。

figure(2); % プロットウィンドウを1つ作る

for i=1:c1 % 教師信号x1をそれぞれプロットする
    if(alpha(i)==0) % 分離関数と関係なければ黒い○でプロット
        scatter(x_list(1,i),x_list(2,i),100,'black');hold on;
    elseif(alpha(i)>0) % サポートベクターなら紫色の○でプロット
        scatter(x_list(1,i),x_list(2,i),100,[127/255 0 127/255]);hold on;
    end;
end;

for i=c1+1:c1+c2 % 教師信号x2をそれぞれプロットする
    if(alpha(i)==0) % 分離関数と関係なければ黒い＋でプロット
        scatter(x_list(1,i),x_list(2,i),100,'black','+');hold on;
    elseif(alpha(i)>0) % サポートベクターなら紫色の＋でプロット
        scatter(x_list(1,i),x_list(2,i),100,[127/255 0 127/255],'+');hold on;
    end;
end;

if(new_m1 > 0) % テスト信号xvecがGroup 1なら赤い○でプロット
    scatter(xvec(1),xvec(2),200,'red');hold on;
elseif(new_m1 < 0) % テスト信号xvecがGroup 2なら赤い＋でプロット
    scatter(xvec(1),xvec(2),200,'red','+');hold on;
else % テスト信号xvecが万一分離超平面上なら青い○でプロット
    scatter(xvec(1),xvec(2),200,'blue');hold on;
end;

% プロット範囲をx,yともに[-10 10]の正方形領域内に設定
xlim([-10 10]);
ylim([-10 10]);

% コンター（等高線）プロット。難しいので詳細はMatlabヘルプをご参照下さい。
[xx,yy]=meshgrid(-10:0.1:10,-10:0.1:10);
cxx=size(xx,1);
cyy=size(yy,2);
zz=zeros(cxx,cyy);
for p=1:cxx
    for q=1:cyy
        out=tjo_svm_trial_silent([xx(p,q);yy(p,q)],wvec,x_list,delta,bias,clength,kernel_choice);
        zz(p,q)=sign(out);
    end;
end;
contour(xx,yy,zz,[-1 0 1]);
title('My own code result');

%%
figure(3); % プロットウィンドウを1つ作る

for i=1:c1 % 教師信号x1をそれぞれプロットする
    scatter(x_list(1,i),x_list(2,i),100,'black');hold on;
end;

for i=c1+1:c1+c2 % 教師信号x2をそれぞれプロットする
    scatter(x_list(1,i),x_list(2,i),100,'black','+');hold on;
end;

if(new_m2 > 0) % テスト信号xvecがGroup 1なら赤い○でプロット
    scatter(xvec(1),xvec(2),200,'red');hold on;
elseif(new_m2 < 0) % テスト信号xvecがGroup 2なら赤い＋でプロット
    scatter(xvec(1),xvec(2),200,'red','+');hold on;
else % テスト信号xvecが万一分離超平面上なら青い○でプロット
    scatter(xvec(1),xvec(2),200,'blue');hold on;
end;

% プロット範囲をx,yともに[-10 10]の正方形領域内に設定
xlim([-10 10]);
ylim([-10 10]);

% コンター（等高線）プロット。難しいので詳細はMatlabヘルプをご参照下さい。
[xx,yy]=meshgrid(-10:0.1:10,-10:0.1:10);
cxx=size(xx,2);
zz=zeros(cxx,cxx);
for p=1:cxx
    for q=1:cxx
        [zz(p,q),ac,prob]=svmpredict(1,[xx(p,q);yy(p,q)]',model,'');
    end;
end;
contour(xx,yy,zz,[-1 0 1]);
title('LIBSVM result');

pause off;

%%
%%%%%%%%%%%%%%%%%%%%%
% 分類結果を表示する %
%%%%%%%%%%%%%%%%%%%%%

fprintf(1,'\n\nClassification result\n');

fprintf(1,'\n\nMy own code result\n');
if(new_m1>0)
    fprintf(1,'\n\nGroup 1\n\n');
elseif(new_m1<0)
    fprintf(1,'\n\nGroup 2\n\n');
end;

fprintf(1,'\n\nLIBSVM result\n');
if(new_m2>0)
    fprintf(1,'\n\nGroup 1\n\n');
elseif(new_m2<0)
    fprintf(1,'\n\nGroup 2\n\n');
end;


end