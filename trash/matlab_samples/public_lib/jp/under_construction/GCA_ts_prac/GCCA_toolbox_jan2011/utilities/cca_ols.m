%-----------------------------------------------------------------------
% FUNCTION: cca_ols.m
% PURPOSE:  ordinary least squares regression, utility function

%  A=cca_ols(y,x), where y is a vector, x is a matrix, performs ols
%  estimates of the regression of y on the columns of x.
%  A is a 2 x (k+1) matrix, where k is the number of
%  columns of x, having the parameter estimates on the first
%  line and the standard errors on the second.
%  In the last column, the first element is the estimated variance of
%  residuals and the second is the corrected R^2.
%  [A,u]=cca_ols(y,x) produces the vector u of the residuals as a further
%  output. [A,u,fit]=cca_ols(y,x) produces the fitted values.
%  [A,u,fit,v]=cca_ols(y,x) produces the varcov matrix of the estimates.
%
%-----------------------------------------------------------------------%
function [ols,u,fit,v]=cca_ols(y,x)
par=inv(x'*x)*x'*y;           %%% ols coeff
fit=x*par;                   %%% fit
u=y-fit;                    %%% residuals
m=size(x); T=m(1); k=m(2);
esu=u'*u/(T-k);
r2=1-(u'*u)/(cca_center(y)'*cca_center(y));              %%% R2
r2c=1-(1-r2)*(T-1)/(T-k);        %%% adjusted R2
v=esu*inv(x'*x);        %%% varcov matrix of the estimates
espar=sqrt(diag(v));    %%% standard errors
ols=[par' esu; espar' r2c];

