function wvec=tjo_svm_classifier(y_list,alpha,clength)
% 分離関数を定義するベクトルw(wvec)を算出する関数。
% 実はただの正解信号y_listとラグランジュ乗数alphaの内積。

wvec=zeros(clength,1);

for i=1:clength
    wvec(i)=y_list(i)*alpha(i);
end;

end