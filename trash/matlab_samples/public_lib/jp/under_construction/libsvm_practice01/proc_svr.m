N = 1000;
M = 1;
t = randn(N,1);

clear r
m = 1:10:100;
for M = m
x = [t];
for ii=1:M-1
    x = [x  t+ii*randn(N,1)/2];
end

x = normalize(x);

% t1 = randn(N,1);
% t2 = randn(N,1);
% x = [t1 t2];
% y = 3*t1 - 5*t2;
y = 2*t + randn(N,1)/2 + 7;

% corrcoef([x y]);
% 
% b= glmfit(x,y);
for ii = 1
    for jj=1
        tic;model = svmtrain(y(1:N/2),x(1:N/2,:),['-s 4 -t 2 -n ' num2str(ii/2) ' -c ' num2str(1)]);toc
        tic;zz=svmpredict(y(N/2+1:end),x(N/2+1:end,:),model);toc
        tmp = corrcoef(zz, y(N/2+1:end));
        r(1+(M-1)/10) = tmp(2);
    end
end

end

w = model.SVs' * model.sv_coef
b = -model.rho

hold on;plot(m, r, 'ro-');xlabel('# of dimension'); ylabel('r')
figure('color','w');plot(m, r, 'ro-');

figure('color','w');plot(x(1:N/2,:), y(1:N/2), 'b.');
hold on;plot(x(N/2+1:end,:), zz, 'r.');
xlabel('x')
ylabel('y')
legend({'training','test'})

figure('color','w'); plot(zz, y(N/2+1:end), '.'); axis equal;axis square;
figure('color','w'); plot(zz - y(N/2+1:end), '.')