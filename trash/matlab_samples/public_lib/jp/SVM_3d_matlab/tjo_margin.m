function m=tjo_margin(fix_v,x_var,alpha_var,y_var,delta,clength)
%%
% マージン算出関数です。
% fix_vだけが外部入力変数である点に注意。
% 残りは教師信号x_list全体と正解信号y_list全体と、ラグランジュ乗数などなど。

m=0;

for i=1:clength
    m = m + (alpha_var(i)*y_var(i)*tjo_kernel(fix_v,x_var(:,i),delta));
end;

end