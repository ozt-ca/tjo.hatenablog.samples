function out=tjo_bp_predict(xvec,wvec,hvec)
% 単なるテスト用関数です。
% tjo_1st_stepで入力層～中間層間の値を出し、
% tjo_2nd_stepで出力層の最終的な出力を出しています。

gvec=tjo_1st_step(xvec,wvec);
out=tjo_2nd_step(gvec,hvec);

end