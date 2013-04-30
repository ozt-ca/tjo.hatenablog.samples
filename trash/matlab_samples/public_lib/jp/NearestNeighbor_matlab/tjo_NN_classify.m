function gid=tjo_NN_classify(xvec,x_list,cl)
% NN法の分類部。
% 極めてシンプルに、教師信号x_listとテスト信号xvecとの
% ユークリッド距離（ノルム）を計算して、その最小値を与えた
% 教師信号要素の3列目（クラス値）を参照し、それをテスト信号の
% 所属する（と判定される）クラスとして返すようにしてあります。

% ノルム値を格納する空ベクトル。
dist=zeros(cl,1);

% 教師信号一つ一つに対してノルムを計算。
for i=1:cl
    dist(i)=norm(xvec-x_list(1:2,i));
end;

% find(statement)関数はstatementを満たすベクトルのインデックスを
% ベクトルとして返す（複数の場合：1つしかなければ数字1つ）。
% これで最小ノルムを返す教師信号x_listのインデックスが得られる。
nn_id=find(dist==min(dist));
% x_listの当該インデックス列の3列目がクラス値なので、それを返す。
gid=x_list(3,nn_id);

end