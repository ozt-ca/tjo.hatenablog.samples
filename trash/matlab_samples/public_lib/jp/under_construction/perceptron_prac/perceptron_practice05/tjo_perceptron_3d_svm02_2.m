function [new_m,alpha,bias]=tjo_perceptron_3d_svm02_2(xvec,delta,Cmax,loop)
%%
% SMO‚È‚µBƒSƒŠƒSƒŠŒnB

% delta, Cmax‚ðleave-one-out cross-validation‚ÅÅ“K‰»‚·‚éƒ‹[ƒ`ƒ“‚ð‰Á‚¦‚éI

%%
% xyÀ•WŒn‚Ì’l‚ð‘f«‚Æ‚µ‚½ŒP—ûƒf[ƒ^
% “K“–‚ÉŒˆ‚ß‚Ä‘æ1W’c‚È‚ç1
% ‘æ2W’c‚È‚ç-1‚ð³‰ðƒ‰ƒxƒ‹‚Æ‚·‚é

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
% ŒP—ûƒp[ƒg
alpha=zeros(c1+c2,1);
% loop=1000; % ŒP—û‚ÌŒJ‚è•Ô‚µ‰ñ”
learn_stlength=1.5;

%%
% alpha‚ð„’è‚·‚éB‚±‚±‚ªSVM‚Ìtraining‚ÌŠÌ

alpha=tjo_svm_train(x_list,y_list,alpha,delta,Cmax,loop,clength,learn_stlength);

%%
% bias‚ð„’è‚·‚é

bias=tjo_svm_bias_estimate(x_list,y_list,alpha,delta,clength);

% bias=0;

%%
% •ª—Þ‚µ‚Ä‚Ý‚é(Trial / Testing)

new_m=tjo_svm_trial(xvec,x_list,y_list,alpha,delta,bias);


%%
% ‚¨‚Ü‚¯‚Å‰ÂŽ‹‰»

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