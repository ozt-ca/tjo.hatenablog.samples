function new_m=tjo_svm_trial(xvec,wvec,x_list,delta,bias,clength,kernel_choice)
% 実際に作成されたSVM分離関数からテスト信号xvecの判別を行う関数。
% 結局マージン計算しているだけ。ただしその入力定数は推定済みのwvecとbias。

wbyx=0;

for i=1:clength
    wbyx = wbyx+wvec(i)*tjo_kernel(xvec,x_list(:,i),delta,kernel_choice);
end;

new_m=wbyx+bias;

% ついでに決定関数値からGroup 1 or 2のどちらであるかをコマンドライン上に表示。
if(new_m > 0)
    fprintf(1,'Group 1\n\n');
elseif(new_m < 0)
    fprintf(1,'Group 2\n\n');
else
    fprintf(1,'On the border\n\n');
end;

end