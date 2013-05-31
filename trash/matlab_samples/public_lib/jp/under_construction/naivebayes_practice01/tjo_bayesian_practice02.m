Sa=[2:0.1:4];
Sb=[4:0.1:6];

L=length(Sa);
Pr=ones(L,L);
Po=ones(L,L);

Pr=Pr/sum(sum(Pr));
Po=Po/sum(sum(Po));

K=[4 0;0 4];

m=0*Pr;

for i=1:length(Pr)
    for j=1:length(Pr)
        me=[Sa(i);Sb(j)];
        m(i,j)=1/sqrt(((2*pi)^2)*det(K))*exp(-(x(:,1)-me)'*inv(K)*(x(:,1)-me)/2);
        m(i,j)=m(i,j)*Pr(i,j);
    end;    
end;

Po=m/sum(sum(m));

figure(3);

[a,b]=find(Po==max(max(Po)));

sest=[Sa(a);Sb(b)];

subplot(211);plot(1,sest(1));hold on;
line([1,100],[s(1),s(1)]);
subplot(212);plot(1,sest(2));hold on;
line([1,100],[s(2),s(2)]);

for n=2:length(x);
    Pr = Po;
    m=0*Pr;
    for i=1:length(Pr)
        for j=1:length(Pr)
            me=[Sa(i);Sb(j)];
            m(i,j)=1/sqrt(((2*pi)^2)*det(K))*exp(-(x(:,n)-me)'*inv(K)*(x(:,n)-me)/2);
            m(i,j)=m(i,j)*Pr(i,j);            
        end;
    end;
    Po=m/sum(sum(m));
    [a,b]=find(Po==max(max(Po)));
    sest=[Sa(a);Sa(b)];
    subplot(211);plot(n,sest(1),'k.');
    subplot(212);plot(n,sest(2),'k.');
end;
subplot(211);hold off;
subplot(212);hold off;