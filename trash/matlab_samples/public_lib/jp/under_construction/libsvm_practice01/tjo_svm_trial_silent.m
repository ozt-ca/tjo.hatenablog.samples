function new_m=tjo_svm_trial_silent(xvec,wvec,x_list,delta,bias,clength,kernel_choice)
% tjo_svm_trial関数と中身は全く同じ。
% 分離超平面のコンター（等高線）表示のためにコマンドライン出力をカットしただけ。

wbyx=0;

for i=1:clength
    wbyx = wbyx+wvec(i)*tjo_kernel(xvec,x_list(:,i),delta,kernel_choice);
end;

new_m=wbyx+bias;

% if(new_m > 0)
%     fprintf(1,'Group 1\n\n');
% elseif(new_m < 0)
%     fprintf(1,'Group 2\n\n');
% else
%     fprintf(1,'On the border\n\n');
% end;

end