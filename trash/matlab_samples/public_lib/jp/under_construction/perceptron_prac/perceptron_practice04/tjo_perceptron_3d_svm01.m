function [new_m,alpha,bias]=tjo_perceptron_3d_svm01(xvec,delta,Cmax)

% xyz座標系の値を素性とした訓練データ
% 適当に決めて第1集団なら1
% 第2集団なら-1を正解ラベルとする

x_list=[[1;1;1] [2;3;1] [2;1;1] [2;-1;1] [3;2;1] [-1;-1;-1] [0;-1;0] [0;-1;-1] [-1;-2;-1] [-1;-2;-3] [5;5;5] [-5;-5;-5]];
y_list=[1;1;1;1;1;-1;-1;-1;-1;-1;1;-1];

% 訓練パート
alpha=zeros(12,1);
loop=1000; % 訓練の繰り返し回数
learn_stlength=1.5;

% alphaを推定する
for j=1:loop
    for i=1:12
        alpha(i)=alpha(i)+learn_stlength*(1-(y_list(i)*tjo_margin(x_list(i),x_list,alpha,y_list,delta)));
        if(alpha(i)<0)
            alpha(i)=0;
        elseif(alpha(i)>Cmax)
            alpha(i)=Cmax;
        end;
    end;
end;

% biasを推定する

maxb=0;
minb=0;

for i=1:12
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

% 分類してみる

new_m = tjo_margin(xvec,x_list,alpha,y_list,delta) + bias;

if(new_m > 0)
    fprintf(1,'Group 1\n\n');
elseif(new_m < 0)
    fprintf(1,'Group 2\n\n');
end;

% [xx,yy]=meshgrid(-5:.1:5,-5:.1:5);
% zz=-(a/c)*xx-(b/c)*yy-(d/c);
figure;
% mesh(xx,yy,zz);hold on;
scatter3(x_list(1,1:5),x_list(2,1:5),x_list(3,1:5),500,'black');hold on;
scatter3(x_list(1,6:10),x_list(2,6:10),x_list(3,6:10),500,'black','+');hold on;
scatter3(x_list(1,11),x_list(2,11),x_list(3,11),500,'black');hold on;
scatter3(x_list(1,12),x_list(2,12),x_list(3,12),500,'black','+');hold on;
scatter3(xvec(1),xvec(2),xvec(3),500,'red');

end