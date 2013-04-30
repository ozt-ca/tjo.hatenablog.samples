function out=tjo_part_prob(xvec_id,data_row)
% ごくごく単純にp(xi|E)を計算する関数。
% Matlabのfind関数を利用しているので要注意。

% 教師信号の行の長さを求めます。
cl=size(data_row,2);

% find(statement)関数はstatementを満たすベクトルのインデックスを
% 全て列挙して、改めてベクトルとして返します。
% なので、ここでは教師信号の特定の行の中においてテスト信号の値と
% 合致するものがいくつあるかをnumとして返すようにしています。
num=size(find(data_row==xvec_id),2);

% numを行のサイズで割れば、確率（割合）が得られます。
out=num/cl;

end