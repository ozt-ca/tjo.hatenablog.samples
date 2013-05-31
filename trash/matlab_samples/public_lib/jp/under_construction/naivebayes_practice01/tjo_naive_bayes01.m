function out=tjo_naive_bayes01(xvec)

% x1_list=[ones(1,30)+2*rand(1,30);ones(1,30)+2*rand(1,30)];
% x2_list=[-1*ones(1,15)-2*rand(1,15);-1*ones(1,15)-2*rand(1,15)];

c=3;

x1_list=[[(ones(1,10)+c*rand(1,10));(ones(1,10)+c*rand(1,10))] ...
    [(-1*ones(1,10)-c*rand(1,10));(ones(1,10)+c*rand(1,10))] ...
    [(ones(1,10)+c*rand(1,10));(-1*ones(1,10)-c*rand(1,10))]];
x2_list=[-1*ones(1,15)-c*rand(1,15);-1*ones(1,15)-c*rand(1,15)];

% p1=size(x1_list,2)/(size(x1_list,2)+size(x2_list,2));
% p2=1-p1;
% 
% m1=mean(x1_list,2);
% m2=mean(x2_list,2);
% 
% np1=p1*prod(m1.^xvec.*(1-m1).^(1-xvec));
% np2=p2*prod(m2.^xvec.*(1-m2).^(1-xvec));
% 
% px=np1/(np1+np2);
% 
% out=px;
%%
out=tjo_naive_classifier(xvec,x1_list,x2_list);

%%
figure(1);

scatter(x1_list(1,:),x1_list(2,:),200,'ko');hold on;
scatter(x2_list(1,:),x2_list(2,:),200,'k+');hold on;

xlim([-5 5]);
ylim([-5 5]);

if(out>0.5)
    scatter(xvec(1),xvec(2),400,'ro');hold on;
elseif(out<0.5)
    scatter(xvec(1),xvec(2),400,'r+');hold on;
else
    scatter(xvec(1),xvec(2),400,'bs');hold on;
end;

[xx,yy]=meshgrid(-5:0.1:5,-5:0.1:5);
cxx=size(xx,2);
zz=zeros(cxx,cxx);

for p=1:cxx
    for q=1:cxx
        zz(p,q)=tjo_naive_classifier([xx(p,q);yy(p,q)],x1_list,x2_list);
        zz(p,q)=abs(zz(p,q));
    end;
end;

contour(xx,yy,zz,50);

xlim([-5 5]);
ylim([-5 5]);

end