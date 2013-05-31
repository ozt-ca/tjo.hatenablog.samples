function [new_m,alpha,bias]=tjo_perceptron_3d_svm02(xvec,delta,Cmax,loop)
%%
% SMOなし。ゴリゴリ系。

%%
% xy座標系の値を素性とした訓練データ
% 適当に決めて第1集団なら1
% 第2集団なら-1を正解ラベルとする

x1_list=[[1;1] [2;3] [2;1] [2;-1] [3;2] [5;5] [-1;3] [-3;2] ...
    [-2;1] [2;-1] [3;-2] [4;-4] [1;-4] [-8;1] [1;-8] [-6;1] [1;-6] ...
    [3;-5] [2;-2] [1;-2] [-4;4] [1;-5]];
x2_list=[[-1;-1] [0;-1] [0;-2] [-1;-2] [-1;-3] [-3;-3] [-4;0] ...
    [-3;-1] [-5;0] [-8;-2] [-2;-8] [0;-4] [0;-5] [0;-6] [-6;0] [-5;0] ...
    [0;-2] [-3;-4] [-4;-3] [-2;-2]];
x_list=[x1_list x2_list];

[r1,c1]=size(x1_list);
[r2,c2]=size(x2_list);
y_list=[ones(c1,1);-1*ones(c2,1)];

clength=c1+c2;
%%
% 訓練パート
alpha=zeros(c1+c2,1);
loop=1000; % 訓練の繰り返し回数
learn_stlength=1.5;

%%
% alphaを推定する。ここがSVMのtrainingの肝
for j=1:loop
    for i=1:clength
        alpha(i)=alpha(i)+learn_stlength*(1-(y_list(i)*tjo_margin(x_list(i),x_list,alpha,y_list,delta)));
        if(alpha(i)<0)
            alpha(i)=0;
        elseif(alpha(i)>Cmax)
            alpha(i)=Cmax;
        end;
    end;
end;

%%
% biasを推定する

maxb=0;
minb=0;

for i=1:clength
    m = tjo_margin(x_list(i),x_list,alpha,y_list,delta);
    if(y_list(i)==-1&&m>maxb) % echizen_tmさんの例と同じ
        maxb=m;
    end;
    if(y_list(i)==1&&m<minb) % echizen_tmさんの例と同じ
        minb=m;
    end;
end;
bias=(maxb+minb)/2;
% bias=0;

%%
% 分類してみる(Trial / Testing)

new_m = tjo_margin(xvec,x_list,alpha,y_list,delta) + bias;

if(new_m > 0)
    fprintf(1,'Group 1\n\n');
elseif(new_m < 0)
    fprintf(1,'Group 2\n\n');
else
    fprintf(1,'On the border\n\n');
end;

%%
% おまけで可視化

% [xx,yy]=meshgrid(-5:.1:5,-5:.1:5);
% zz=-(a/c)*xx-(b/c)*yy-(d/c);
h=figure;
% mesh(xx,yy,zz);hold on;
scatter(x_list(1,1:c1),x_list(2,1:c1),100,'black');hold on;
scatter(x_list(1,c1+1:c1+c2),x_list(2,c1+1:c1+c2),100,'black','+');hold on;
if(new_m > 0)
    scatter(xvec(1),xvec(2),100,'red');
elseif(new_m < 0)
    scatter(xvec(1),xvec(2),100,'red','+');
else
    scatter(xvec(1),xvec(2),100,'blue');
end;
xlim([-10 10]);
ylim([-10 10]);

end