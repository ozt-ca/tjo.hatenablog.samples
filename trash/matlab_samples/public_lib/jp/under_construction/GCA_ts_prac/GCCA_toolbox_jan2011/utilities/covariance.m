function  cov_value=covariance(X,Y,n)
x_bar=mean(X);
y_bar=mean(Y);
cov_value=0;
for i=1:n
    cov_value=cov_value+X(i)*Y(i);
end
cov_value=cov_value/n-x_bar*y_bar;

% seems to give the same as the MATLAB function cov, which is good.