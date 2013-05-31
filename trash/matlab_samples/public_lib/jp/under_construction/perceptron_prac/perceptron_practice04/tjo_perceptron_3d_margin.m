function [yvec,wvec]=tjo_perceptron_3d_margin(xvec,lamda,alpha)

% xyzÀ•WŒn‚Ì’l‚ð‘f«‚Æ‚µ‚½ŒP—ûƒf[ƒ^
% “K“–‚ÉŒˆ‚ß‚Ä‘æ1W’c‚È‚ç1
% ‘æ2W’c‚È‚ç-1‚ð³‰ðƒ‰ƒxƒ‹‚Æ‚·‚é

x_list=[[1;1;1;1] [2;3;1;1] [2;1;1;1] [2;-1;1;1] [3;2;1;1] [-1;-1;-1;1] [0;-1;0;1] [0;-1;-1;1] [-1;-2;-1;1] [-1;-2;-3;1]];
t_list=[1;1;1;1;1;-1;-1;-1;-1;-1];

% ŒP—ûƒp[ƒg
wvec=[0;0;0;1]; % ‰Šúd‚ÝƒxƒNƒgƒ‹
loop=1000; % ŒP—û‚ÌŒJ‚è•Ô‚µ‰ñ”

% Learning
for j=1:loop
    for i=1:10
        wvec=tjo_train_margin(wvec,x_list(:,i),t_list(i),lamda,alpha);
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

a=wvec(1);
b=wvec(2);
c=wvec(3);
d=wvec(4);

[xx,yy]=meshgrid(-5:.1:5,-5:.1:5);
zz=-(a/c)*xx-(b/c)*yy-(d/c);
figure;
mesh(xx,yy,zz);hold on;
scatter3(x_list(1,1:5),x_list(2,1:5),x_list(3,1:5),500,'black');hold on;
scatter3(x_list(1,6:10),x_list(2,6:10),x_list(3,6:10),500,'black','+');hold on;
scatter3(xvec(1),xvec(2),xvec(3),500,'red');

end