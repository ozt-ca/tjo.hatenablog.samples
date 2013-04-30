function [alpha1,alpha2,wvec1,wvec2,linear_id1,linear_id2]=tjo_svm_2d_main_procedure_half(xvec,delta,Cmax,loop)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% サポートベクターマシン2次元バージョン by Takashi J. OZAKI %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 物凄くシンプルな実装です。最低限の機能として、
% 1) 3種類（線型・多項式・ガウシアンRBF）のカーネルによる非線型処理
% 2) SMO（Sequential Minimal Optimization: 逐次最小最適化）
% 3) 教師信号x_listをランダムに取得（2次分離もしくはXORパターン）
% 4) 教師信号x_listとテスト信号xvecのプロット、サポートベクターの強調表示
% 5) 分離超平面のコンター（等高線）表示
% を実装してあります。
% 
% 試しに[new_m,alpha,bias,linear_index]=tjo_svm_2d_main_procedure([4;4],4,2,100)と
% コマンドライン上で実行してみて下さい。綺麗なXOR分離パターンが表示されます。
% xvec：テスト信号のxy座標（列ベクトル[x;y]で指定）
% delta：カーネルの変数（本当はσ:sigmaですごめんなさい）
% Cmax：ソフトマージンSVMにおけるKKT条件パラメータC
% loop：SMOが収束しない場合の試行回数の打ち切り上限（これがないと無限ループする）
% 
% Matlabは非常にルーズな言語です。ベースとしてはほぼC言語そのものです。
% Cよりもルーズで、例えば変数宣言は一切要りません（初期化したい時は
% zeros関数で全要素ゼロのベクトルor行列を作る）。
% Javaや他言語に移植する際はその辺を勘案した上で、あくまでもアルゴリズムの
% 雛形としてご利用下さい。
% 
% なお、「2次元バージョン」とタイトルをつけてありますが、
% 行列計算自体に普遍性を持たせてありますので3次元でも4次元でもn次元でも
% 計算負荷さえ無視すればいくらでも拡張できます（ただしプロットは無理ですが）。
% 
% 詳しい原理については『サポートベクターマシン入門』（通称赤本）をご参照下さい。
% 尾崎が私物で持っておりますので、お貸しいたします。

%%
%%%%%%%%%%%%%%%%%
% 教師信号の設定 %
%%%%%%%%%%%%%%%%%

% ones関数で全要素1の行列を適当に作り、そこにrand関数でばらつきを与えています。
% cをrand関数に乗じることで、ばらつきの大きさを変えることができます。
% 各信号のxy座標を列ベクトルで表しています。
% 行方向にそれぞれのxy座標を並べていくイメージです。
% どちらの教師信号を選ぶかを、適宜コメントアウトor解除で決めて下さい。
% 右クリックメニューの中に一括コメントアウトor解除の機能があります。

t=6;
c=5;
d=50;

% 2次分離非線型パターン：第1・2・4象限がx1、第3象限のみx2
% x1_list=[[(ones(1,d)+c*rand(1,d));(ones(1,d)+c*rand(1,d))] ...
%     [(-1*ones(1,d)-c*rand(1,d));(ones(1,d)+c*rand(1,d))] ...
%     [(ones(1,d)+c*rand(1,d));(-1*ones(1,d)-c*rand(1,d))]];
% x2_list=[-1*ones(1,d)-c*rand(1,d);-1*ones(1,d)-c*rand(1,d)];

% XOR非線型パターン：第2・4象限がx1、第1・3象限がx2
% x1_list=[[(-1*ones(1,d)-c*rand(1,d));(ones(1,d)+c*rand(1,d))] ...
%     [(ones(1,d)+c*rand(1,d));(-1*ones(1,d)-c*rand(1,d))]];
% x2_list=[[(ones(1,d)+c*rand(1,d));(ones(1,d)+c*rand(1,d))] ...
%     [-1*ones(1,d)-c*rand(1,d);-1*ones(1,d)-c*rand(1,d)]];

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
xlim([-10 10]);
ylim([-10 10]);

pause(5);

%%
%%%%%%%%%%%%%%%%%
% 各変数の初期化 %
%%%%%%%%%%%%%%%%%
% zeros関数で全要素0のベクトルを作る。

% ラグランジュ乗数α（詳細は赤本参照のこと）
alpha1=zeros(clength,1);
alpha2=zeros(clength,1);
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

[alpha1,bias1]=tjo_smo(x_list,y_list,alpha1,delta,Cmax,clength,learn_stlength,loop);

alpha2=tjo_svm_half_train(x_list,y_list,alpha2,delta,Cmax,loop,clength,learn_stlength);
bias2=0;

% ラグランジュ乗数alphaとバイアスbiasの両方が同時に求まる。
% これで分離関数に必要な定数が全て得られたことになる。

% max_m=0;min_m=0;
% 
% for i=1:clength
%     m=tjo_margin(x_list(:,i),x_list,alpha,y_list,delta,clength);
%     if(y_list(:,i)==-1 && m > max_m)
%         max_m=m;
%     end;
%     if(y_list(:,i)==1 && m < min_m)
%         min_m=m;
%     end;
% end;
% 
% bias = (max_m+min_m)/2;

%%
%%%%%%%%%%%%%%%%%%%%%%%
% 分離関数を完成させる %
%%%%%%%%%%%%%%%%%%%%%%%
% 分離関数の算出に必要なwベクトル(wvec)を求める。
% wvecは正解信号y_listと推定済みラグランジュ乗数alphaの2つから求まる。

wvec1=tjo_svm_classifier(y_list,alpha1,clength);
wvec2=tjo_svm_classifier(y_list,alpha2,clength);

% wvecとbiasを分離関数tjo_svm_trialに入力すれば、テスト実行が可能。


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 分類してみる(Trial / Testing) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 実際に推定済みのwvecとbiasの2定数から分離関数を構成し、
% テスト信号xvecに対する決定関数値new_mを求める。
% new_m > 0ならx1側(Group 1)、new_m < 0ならx2側(Group 2)と判定される。
% 関数tjo_svm_trialはコマンドラインに判定結果の表示も行う。

fprintf(1,'\n\nSMO result\n');
new_m1=tjo_svm_trial(xvec,wvec1,x_list,delta,bias1,clength);
fprintf(1,'Half (incomplete procedure) result\n');
new_m2=tjo_svm_trial(xvec,wvec2,x_list,delta,bias2,clength);

linear_id1=alpha1'*y_list;
linear_id2=alpha2'*y_list;

% SMOが途中打ち切りになった場合に備えて、線型制約Σalpha*y_list = 0を
% 満たしているかどうかを計算する。

%%
%%%%%%%%%%%%%%%%%%%%%
% 可視化（プロット） %
%%%%%%%%%%%%%%%%%%%%%
% Matlab最大の武器である可視化パート。
% コメントのないところは適宜Matlabヘルプをご参照下さい。

figure(2); % プロットウィンドウを1つ作る

for i=1:c1 % 教師信号x1をそれぞれプロットする
    if(alpha1(i)==0) % 分離関数と関係なければ黒い○でプロット
        scatter(x_list(1,i),x_list(2,i),100,'black');hold on;
    elseif(alpha1(i)>0) % サポートベクターなら紫色の○でプロット
        scatter(x_list(1,i),x_list(2,i),100,[127/255 0 127/255]);hold on;
    end;
end;

for i=c1+1:c1+c2 % 教師信号x2をそれぞれプロットする
    if(alpha1(i)==0) % 分離関数と関係なければ黒い＋でプロット
        scatter(x_list(1,i),x_list(2,i),100,'black','+');hold on;
    elseif(alpha1(i)>0) % サポートベクターなら紫色の＋でプロット
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
cxx=size(xx,2);
zz=zeros(cxx,cxx);
for p=1:cxx
    for q=1:cxx
        zz(p,q)=tjo_svm_trial_silent([xx(p,q);yy(p,q)],wvec1,x_list,delta,bias1,clength);
    end;
end;
contour(xx,yy,zz,[-1 0 1]);
title('SMO result');

figure(3); % プロットウィンドウを1つ作る

for i=1:c1 % 教師信号x1をそれぞれプロットする
    if(alpha2(i)==0) % 分離関数と関係なければ黒い○でプロット
        scatter(x_list(1,i),x_list(2,i),100,'black');hold on;
    elseif(alpha2(i)>0) % サポートベクターなら紫色の○でプロット
        scatter(x_list(1,i),x_list(2,i),100,[127/255 0 127/255]);hold on;
    end;
end;

for i=c1+1:c1+c2 % 教師信号x2をそれぞれプロットする
    if(alpha2(i)==0) % 分離関数と関係なければ黒い＋でプロット
        scatter(x_list(1,i),x_list(2,i),100,'black','+');hold on;
    elseif(alpha2(i)>0) % サポートベクターなら紫色の＋でプロット
        scatter(x_list(1,i),x_list(2,i),100,[127/255 0 127/255],'+');hold on;
    end;
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
        zz(p,q)=tjo_svm_trial_silent([xx(p,q);yy(p,q)],wvec2,x_list,delta,bias2,clength);
    end;
end;
contour(xx,yy,zz,[-1 0 1]);
title('Half (incomplete) result');

pause off;

figure(4);hist(alpha1);
figure(5);hist(alpha2);

end