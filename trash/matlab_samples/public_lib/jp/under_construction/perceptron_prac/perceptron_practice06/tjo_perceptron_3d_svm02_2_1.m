function [new_m,alpha,bias,y_list]=tjo_perceptron_3d_svm02_2_1(xvec,delta,Cmax,loop)
%%
% SMO‚È‚µBƒSƒŠƒSƒŠŒnB

% delta, Cmax‚ðleave-one-out cross-validation‚ÅÅ“K‰»‚·‚éƒ‹[ƒ`ƒ“‚ð‰Á‚¦‚éI

%%
% xyÀ•WŒn‚Ì’l‚ð‘f«‚Æ‚µ‚½ŒP—ûƒf[ƒ^
% “K“–‚ÉŒˆ‚ß‚Ä‘æ1W’c‚È‚ç1
% ‘æ2W’c‚È‚ç-1‚ð³‰ðƒ‰ƒxƒ‹‚Æ‚·‚é

% x2_list=[[2;-1] [-1;3] [-3;2] [8;-8] [7;-7] [8;-1] [6;-1] ...
%     [-2;1] [2;-1] [3;-2] [4;-4] [1;-4] [-8;1] [1;-8] [-6;1] [1;-6] ...
%     [3;-5] [2;-2] [1;-2] [-4;4] [1;-5]];
% x1_list=[[-1;-1] [0;-1] [0;-2] [-1;-2] [-1;-3] [-3;-3] [-4;0] ...
%     [-3;-1] [-5;0] [-8;-2] [-2;-8] [0;-4] [0;-5] [0;-6] [-6;0] [-5;0] ...
%     [0;-2] [-3;-4] [-4;-3] [-2;-2] [1;1] [2;3] [2;1] [3;2] [5;5] ...
%     [7;1] [6;1] [7;7] [6;6] [1;5] [1;6] [4;1] [3;1] [5;1] [1;3] [1;4] ...
%     [3;6] [6;3]];
x1_list=[[1;1] [2;1] [3;1] [4;1] [1;4] [2;4] [3;4] [4;4] ...
    [-1;1] [-2;1] [-3;1] [-4;1] [-1;4] [-2;4] [-3;4] [-4;4] ...
    [-1;-1] [-2;-1] [-3;-1] [-4;-1] [-1;-4] [-2;-4] [-3;-4] [-4;-4]];
x2_list=[[1;-1] [2;-1] [3;-1] [4;-1] [1;-4] [2;-4] [3;-4] [4;-4]];
x_list=[x1_list x2_list];

[r1,c1]=size(x1_list);
[r2,c2]=size(x2_list);
y_list=[ones(c1,1);-1*ones(c2,1)];

clength=c1+c2;
%%
% ŒP—ûƒp[ƒg
alpha=zeros(c1+c2,1);
% loop=1000; % ŒP—û‚ÌŒJ‚è•Ô‚µ‰ñ”
learn_stlength=1;

%%
% alpha‚ð„’è‚·‚éB‚±‚±‚ªSVM‚Ìtraining‚ÌŠÌ

alpha=tjo_svm_train(x_list,y_list,alpha,delta,Cmax,loop,clength,learn_stlength);

%%
% bias‚ð„’è‚·‚é

bias=tjo_svm_bias_estimate(x_list,y_list,alpha,delta,clength,Cmax);

% bias=0;

%%
% •ª—ÞŠí‚ðŠ®¬‚³‚¹‚é

wvec=tjo_svm_classifier(y_list,alpha,clength);


%%
% •ª—Þ‚µ‚Ä‚Ý‚é(Trial / Testing)

new_m=tjo_svm_trial(xvec,wvec,x_list,delta,bias,clength);


%%
% ‚¨‚Ü‚¯‚Å‰ÂŽ‹‰»

% [xx,yy]=meshgrid(-5:.1:5,-5:.1:5);
% zz=-(a/c)*xx-(b/c)*yy-(d/c);
h=figure;
% mesh(xx,yy,zz);hold on;
for i=1:c1
    if(alpha(i)==0)
        scatter(x_list(1,i),x_list(2,i),100,'black');hold on;
    elseif(alpha(i)>0)
        scatter(x_list(1,i),x_list(2,i),100,[127/255 0 127/255]);hold on;
    end;
end;

for i=c1+1:c1+c2
    if(alpha(i)==0)
        scatter(x_list(1,i),x_list(2,i),100,'black','+');hold on;
    elseif(alpha(i)>0)
        scatter(x_list(1,i),x_list(2,i),100,[127/255 0 127/255],'+');hold on;
    end;
end;

if(new_m > 0)
    scatter(xvec(1),xvec(2),200,'red');hold on;
elseif(new_m < 0)
    scatter(xvec(1),xvec(2),200,'red','+');hold on;
else
    scatter(xvec(1),xvec(2),200,'blue');hold on;
end;

xlim([-10 10]);
ylim([-10 10]);

[xx,yy]=meshgrid(-10:1:10,-10:1:10);
[rxx,cxx]=size(xx);
zz=zeros(cxx,cxx);
for p=1:cxx
    for q=1:cxx
        zz(p,q)=tjo_svm_trial_silent([xx(p,q);yy(p,q)],wvec,x_list,delta,bias,clength);
    end;
end;

contour(xx,yy,zz,[-1:0.2:1]);hold on;

end