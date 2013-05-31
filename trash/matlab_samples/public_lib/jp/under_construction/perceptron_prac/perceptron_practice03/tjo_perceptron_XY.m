function [yvec,wvec]=tjo_perceptron_XY(xvec)

% xyÀ•WŒn‚Ì’l‚ð‘f«‚Æ‚µ‚½ŒP—ûƒf[ƒ^
% “K“–‚ÉŒˆ‚ß‚Ä‘æ1W’c‚È‚ç1
% ‘æ2W’c‚È‚ç-1‚ð³‰ðƒ‰ƒxƒ‹‚Æ‚·‚é

x_list=[[1;1;1] [2;3;1] [2;1;1] [2;-1;1] [3;2;1] [1;-1;1] [0;1;1] [0;-1;1] [-1;2;1] [-1;-2;1]];
t_list=[1;1;1;-1;1;-1;-1;-1;-1;-1];

% ŒP—ûƒp[ƒg
wvec=[0;0;1]; % ‰Šúd‚ÝƒxƒNƒgƒ‹
loop=1000; % ŒP—û‚ÌŒJ‚è•Ô‚µ‰ñ”

% Learning
for j=1:loop
    for i=1:10
        wvec=tjo_train(wvec,x_list(:,i),t_list(i));
    end;
    j=j+1;
end;

% xvec‚Í[x;y;bias]‚Æ‚·‚é

% Trial
[t_label,yvec]=tjo_predict(wvec,xvec);
if(t_label>0)
    fprintf(1,'Group 1\n\n');
else
    fprintf(1,'Group 2\n\n');
end;

figure;
x_fig=-6:0.1:6;
y_fig=-(wvec(2)/wvec(1))*x_fig-(wvec(3)/wvec(2));

plot(x_fig,y_fig);hold on;
scatter(x_list(1,:),x_list(2,:),50,'black');hold on;
scatter(xvec(1),xvec(2),50,'red');

end