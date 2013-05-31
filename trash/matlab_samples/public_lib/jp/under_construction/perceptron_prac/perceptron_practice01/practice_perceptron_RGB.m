function [yvec,wvec]=practice_perceptron_RGB(xvec)

% RGB値を素性とした訓練データ
% 暖色系カラーなら1
% 寒色系カラーなら-1を正解ラベルとする

x_list=[[255;0;0;1] [0;255;255;1] [0;255;0;1] [255;0;255;1] [0;0;255;1] [255;255;0;1]];
t_list=[1;-1;-1;1;-1;1];

% 訓練パート
wvec=[0;0;0;1]; % 初期重みベクトル
loop=1000; % 訓練の繰り返し回数

% Learning
for j=1:loop
    for i=1:6
        wvec=practice_train2(wvec,x_list(:,i),t_list(i));
    end;
    j=j+1;
end;

% xvecは[R;G;B;bias]とする

% Trial
[t_label,yvec]=practice_predict2(wvec,xvec);
if(t_label>0)
    fprintf(1,'Warm color\n\n');
else
    fprintf(1,'Cool color\n\n');
end;


end