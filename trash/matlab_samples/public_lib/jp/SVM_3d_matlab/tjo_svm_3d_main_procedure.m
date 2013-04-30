function [new_m,alpha,bias,linear_index]=tjo_svm_3d_main_procedure(xvec,delta,Cmax,loop)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% サポートベクターマシン3次元バージョン by Takashi J. OZAKI %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 物凄くシンプルな実装です。最低限の機能として、
% 1) 3種類（線型・多項式・ガウシアンRBF）のカーネルによる非線型処理
% 2) SMO（Sequential Minimal Optimization: 逐次最小最適化）
% 3) 教師信号x_listをランダムに取得（2次分離もしくはXORパターン）
% 4) 教師信号x_listとテスト信号xvecのプロット、サポートベクターの強調表示
% 5) 分離超平面のコンター（等高線）表示
% を実装してあります。
% 
% 試しに[new_m,alpha,bias,linear_index]=tjo_svm_3d_main_procedure([4;4;4],4,2,100)と
% コマンドライン上で実行してみて下さい。綺麗なXOR分離パターンが表示されます。
% xvec：テスト信号のxyz座標（列ベクトル[x;y;z]で指定）
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
% なお、「3次元バージョン」とタイトルをつけてありますが、
% 行列計算自体に普遍性を持たせてありますので2次元でも4次元でもn次元でも
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
% 各信号のxyz座標を列ベクトルで表しています。
% 行方向にそれぞれのxyz座標を並べていくイメージです。

c=1.5;

% XOR非線型パターン：3次元なので非常に複雑に作ってあります
x1_list=[[ones(1,15)+c*rand(1,15);ones(1,15)+c*rand(1,15);2*ones(1,15)+c*rand(1,15)] ... % 第1象限正
    [-1*ones(1,15)+c*rand(1,15);ones(1,15)+c*rand(1,15);-2*ones(1,15)+c*rand(1,15)] ... % 第2象限負
    [-1*ones(1,15)+c*rand(1,15);-1*ones(1,15)+c*rand(1,15);2*ones(1,15)+c*rand(1,15)] ... % 第3象限正
    [ones(1,15)+c*rand(1,15);-1*ones(1,15)+c*rand(1,15);-2*ones(1,15)+c*rand(1,15)]]; ... % 第4象限負
    
x2_list=[[ones(1,15)+c*rand(1,15);ones(1,15)+c*rand(1,15);-2*ones(1,15)+c*rand(1,15)] ... % 第1象限負
    [-1*ones(1,15)+c*rand(1,15);ones(1,15)+c*rand(1,15);2*ones(1,15)+c*rand(1,15)] ... % 第2象限正
    [-1*ones(1,15)+c*rand(1,15);-1*ones(1,15)+c*rand(1,15);-2*ones(1,15)+c*rand(1,15)] ... % 第3象限負
    [ones(1,15)+c*rand(1,15);-1*ones(1,15)+c*rand(1,15);2*ones(1,15)+c*rand(1,15)]]; ... % 第4象限正

c1=size(x1_list,2); % x1_listの要素数
c2=size(x2_list,2); % x2_listの要素数
clength=c1+c2; % 全要素数：この後毎回参照することになります。

% 正解信号：x1とx2とで分離したいので、対応するインデックスに1と-1を割り振ります。
x_list=[x1_list x2_list]; % x1_listとx2_listを行方向に並べてまとめます。
y_list=[ones(c1,1);-1*ones(c2,1)]; % 正解信号をx1:1, x2:-1として列ベクトルにまとめます。

pause on;

figure(1);
scatter3(x1_list(1,:),x1_list(2,:),x1_list(3,:),200,'ko');hold on;
scatter3(x2_list(1,:),x2_list(2,:),x2_list(3,:),200,'k+');
xlim([-3 3]);
ylim([-3 3]);
zlim([-4 4]);

pause(5);

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

[alpha,bias]=tjo_smo(x_list,y_list,alpha,delta,Cmax,clength,learn_stlength,loop);

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

new_m=tjo_svm_trial(xvec,wvec,x_list,delta,bias,clength);

% SMOが途中打ち切りになった場合に備えて、線型制約Σalpha*y_list = 0を
% 満たしているかどうかを計算する。
linear_index=y_list'*alpha;

%%
%%%%%%%%%%%%%%%%%%%%%
% 可視化（プロット） %
%%%%%%%%%%%%%%%%%%%%%
% Matlab最大の武器である可視化パート。
% コメントのないところは適宜Matlabヘルプをご参照下さい。
% 3次元なのでやや癖のあるコードになっています。

figure(2);

for i=1:c1
    if(alpha(i)==0)
        scatter3(x_list(1,i),x_list(2,i),x_list(3,i),200,'ko');hold on;
    elseif(alpha(i)>0)
        scatter3(x_list(1,i),x_list(2,i),x_list(3,i),200,[127/255 0 127/255]);hold on;
    end;
end;

for i=c1+1:c1+c2
    if(alpha(i)==0)
        scatter3(x_list(1,i),x_list(2,i),x_list(3,i),200,'k+');hold on;
    elseif(alpha(i)>0)
        scatter3(x_list(1,i),x_list(2,i),x_list(3,i),200,[127/255 0 127/255],'+');hold on;
    end;
end;

if(new_m > 0)
    scatter3(xvec(1),xvec(2),xvec(3),600,'ro');hold on;
elseif(new_m < 0)
    scatter3(xvec(1),xvec(2),xvec(3),600,'r+');hold on;
else
    scatter3(xvec(1),xvec(2),xvec(3),600,'bo');hold on;
end;

xlim([-3 3]);
ylim([-3 3]);
zlim([-4 4]);

[xx,yy,zz]=meshgrid(-3:0.1:3,-3:0.1:3,-3:0.1:3);
[cxx,cxx,cxx]=size(xx);
mm=zeros(cxx,cxx,cxx);
V=[];
for p=1:cxx
    for q=1:cxx
        for r=1:cxx
            mm(p,q,r)=tjo_svm_trial_silent([xx(p,q,r);yy(p,q,r);zz(p,q,r)],wvec,x_list,delta,bias,clength);
            if(abs(mm(p,q,r))<0.2)
                V=[V [xx(p,q,r);yy(p,q,r);zz(p,q,r)]];
            end;
        end;
    end;
end;

scatter3(V(1,:),V(2,:),V(3,:),5,'green','+');hold on;

pause off;

end