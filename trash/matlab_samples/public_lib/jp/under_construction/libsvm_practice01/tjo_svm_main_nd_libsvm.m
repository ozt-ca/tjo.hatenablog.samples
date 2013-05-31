function [new_m,model]=tjo_svm_main_nd_libsvm(xvec,x1_list,x2_list,sigma,Cmax)
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

c1=size(x1_list,2); % x1_listの要素数
c2=size(x2_list,2); % x2_listの要素数
clength=c1+c2; % 全要素数：この後毎回参照することになります。

% 正解信号：x1とx2とで分離したいので、対応するインデックスに1と-1を割り振ります。
x_list=[x1_list x2_list]; % x1_listとx2_listを行方向に並べてまとめます。
y_list=[ones(c1,1);-1*ones(c2,1)]; % 正解信号をx1:1, x2:-1として列ベクトルにまとめます。

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
%%%%%%%%%%%%%%%%%%%%%
% 可視化（プロット） %
%%%%%%%%%%%%%%%%%%%%%
% Matlab最大の武器である可視化パート。
% コメントのないところは適宜Matlabヘルプをご参照下さい。
% 
% figure(1); % プロットウィンドウを1つ作る
% 
% for i=1:c1 % 教師信号x1をそれぞれプロットする
%     if(alpha(i)==0) % 分離関数と関係なければ黒い○でプロット
%         scatter(x_list(1,i),x_list(2,i),100,'black');hold on;
%     elseif(alpha(i)>0) % サポートベクターなら紫色の○でプロット
%         scatter(x_list(1,i),x_list(2,i),100,[127/255 0 127/255]);hold on;
%     end;
% end;
% 
% for i=c1+1:c1+c2 % 教師信号x2をそれぞれプロットする
%     if(alpha(i)==0) % 分離関数と関係なければ黒い＋でプロット
%         scatter(x_list(1,i),x_list(2,i),100,'black','+');hold on;
%     elseif(alpha(i)>0) % サポートベクターなら紫色の＋でプロット
%         scatter(x_list(1,i),x_list(2,i),100,[127/255 0 127/255],'+');hold on;
%     end;
% end;
% 
% if(new_m > 0) % テスト信号xvecがGroup 1なら赤い○でプロット
%     scatter(xvec(1),xvec(2),200,'red');hold on;
% elseif(new_m < 0) % テスト信号xvecがGroup 2なら赤い＋でプロット
%     scatter(xvec(1),xvec(2),200,'red','+');hold on;
% else % テスト信号xvecが万一分離超平面上なら青い○でプロット
%     scatter(xvec(1),xvec(2),200,'blue');hold on;
% end;
% 
% % プロット範囲をx,yともに[-10 10]の正方形領域内に設定
% % xlim([-10 10]);
% % ylim([-10 10]);
% 
% % コンター（等高線）プロット。難しいので詳細はMatlabヘルプをご参照下さい。
% [xx,yy]=meshgrid(-60000:1000:20000,-50000:1000:250000);
% cxx=size(xx,1);
% cyy=size(yy,2);
% zz=zeros(cxx,cyy);
% for p=1:cxx
%     for q=1:cyy
%         zz(p,q)=tjo_svm_trial_silent([xx(p,q);yy(p,q)],wvec,x_list,delta,bias,clength,kernel_choice);
%     end;
% end;
% if(Cmax>=1)
%     thr=1/Cmax;
% else
%     thr=Cmax;
% end;
% contour(xx,yy,zz,[-thr 0 thr]);hold on;

%%
%%%%%%%%%%%%%%%%%%%%%
% 分類結果を表示する %
%%%%%%%%%%%%%%%%%%%%%

fprintf(1,'\n\nClassification result\n');

if(new_m>0)
    fprintf(1,'\n\nGroup 1\n');
elseif(new_m<0)
    fprintf(1,'\n\nGroup 2\n');
end;

end