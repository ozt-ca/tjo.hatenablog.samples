function [wvec,margin]=tjo_PA2_practice02(xvec,Cmax)
%%
% xvec: テスト信号
% Cmax: 

%%
c=4;

x11_list=[(ones(1,15)+c*rand(1,15));(ones(1,15)+c*rand(1,15))]; % 第1象限
x22_list=[(-1*ones(1,15)-c*rand(1,15));(ones(1,15)+c*rand(1,15))]; % 第2象限
x33_list=[-1*ones(1,15)-c*rand(1,15);-1*ones(1,15)-c*rand(1,15)]; % 第3象限
x44_list=[(ones(1,15)+c*rand(1,15));(-1*ones(1,15)-c*rand(1,15))]; % 第4象限

x1_list=[x11_list x22_list x44_list];
x2_list=x33_list;

c1=size(x1_list,2); % x1_listの要素数
c2=size(x2_list,2); % x2_listの要素数
clength=c1+c2; % 全要素数：この後毎回参照することになります。

% 正解信号：x1とx2とで分離したいので、対応するインデックスに1と-1を割り振ります。
x_list=[2*x1_list x1_list x2_list 2*x2_list]; % x1_listとx2_listを行方向に並べてまとめます。
y_list=[2*ones(c1,1);ones(c1,1);-1*ones(c2,1);-2*ones(c2,1)]; % 正解信号をx1:1, x2:-1として列ベクトルにまとめます。

wvec=zeros(2,1);
loop=1000;

%%

wvec = tjo_PA2_train(wvec,x_list,y_list,Cmax,loop);

%%

margin = tjo_PA2_predict(wvec,xvec);

if(sign(margin)==1)
    fprintf(1,'Group 1\n\n');
elseif(sign(margin)==-1)
    fprintf(1,'Group 2\n\n');
else
    fprintf(1,'On the border\n\n');
end;

%%
% 可視化
figure(1);

for i=1:c1
    scatter(x1_list(1,i),x1_list(2,i),100,'ko');hold on;
end;
for i=1:c2
    scatter(x2_list(1,i),x2_list(2,i),100,'k+');hold on;
end;

scatter(xvec(1),xvec(2),300,'rs');hold on;

xlim([-10 10]);
ylim([-10 10]);

[xx,yy]=meshgrid(-10:0.1:10,-10:0.1:10);
cxx=size(xx,2);
zz=zeros(cxx,cxx);
for p=1:cxx
    for q=1:cxx
        for i=1:4
            zz(p,q)=tjo_PA2_predict(wvec,[xx(p,q);yy(p,q)]);
        end;
    end;
end;

contour(xx,yy,zz,[-1 0 1]);hold on;

end