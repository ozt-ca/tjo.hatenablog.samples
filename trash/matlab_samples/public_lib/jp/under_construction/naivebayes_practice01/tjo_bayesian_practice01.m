s=[3;5];
figure(1);
h=plot(s(1),s(2),'ro');
set(h,'markersize',6,'linewidth',3);
axis([0,10,0,10
])
hold on;
n=2*randn(2,100);
x=zeros(2,100);
for(i=1:100) x(:,i)=s+n(:,i); plot(x(1,i),x(2,i),'k.'); end;
hold off;
sest=mean(x')';
hold on;
plot(sest(1),sest(2),'bs');
hold off;

figure(2);

sest=x(:,1);
subplot(211);plot(1,sest(1));hold on;
line([1,100],[s(1),s(1)]);
subplot(212);plot(1,sest(2));hold on;
line([1,100],[s(2),s(2)]);

sold=sest;

for n=2:100
    sest=((n-1)/n)*sold+(1/n)*x(:,n);
    subplot(211);plot(n,sest(1),'k.');
    subplot(212);plot(n,sest(2),'k.');
    sold=sest;
end;
 subplot(211);hold off;
 subplot(212);hold off;
 
 