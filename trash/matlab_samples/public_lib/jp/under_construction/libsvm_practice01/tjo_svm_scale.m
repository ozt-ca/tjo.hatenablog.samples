function out=tjo_svm_scale(data)

% 使う場合は[training_vector input_signal]として全体をまとめて正規化してから
% 後でinput_signalを取り出してこないと、正規化誤差が生じるので要注意

out = data - repmat(min(data,[],1),size(data,1),1)*spdiags(1./(max(data,[],1)-min(data,[],1))',0,size(data,2),size(data,2));

end