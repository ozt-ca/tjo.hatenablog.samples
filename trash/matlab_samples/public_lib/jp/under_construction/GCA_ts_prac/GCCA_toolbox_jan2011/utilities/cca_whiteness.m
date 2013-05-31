function [pval,dw] = cca_whiteness(X,r)
%-----------------------------------------------------------------------
% FUNCTION: cca_whiteness.m
% PURPOSE:  check for uncorrelated residuals using Durbin-Watson test
% 
% INPUTS:   X:    nvar (rows) by nobs (cols) observation matrix 
%           r:    vector of residuals
%               
% OUTPUT:   pval:  p-value of significant residual autocorrelation
%           dw:    Durbin-Watson test statistic
%
%           REFS:
%           J. Durbin & G.S. Watson (1950), Testing for Serial Correlation in Least
%           Squares Regression I. Biometrika (37), 409-428.
%     
%           Seth, A.K. (in preparation), A MATLAB Toolbox for Granger
%           causal connectivity analysis
%-----------------------------------------------------------------------

[nvar,nobs] = size(X);
if(nvar>nobs) error('error in cca_whiteness: nvar>nobs, check input matrix'); end
X=X';

% calculate Durbin Watson (DW) statistic
% rule of thumb: if <1 then high chance of residual correlation
dw = sum(diff(r).^2)/sum(r.^2); 

% calculate critical values for the DW statistic using approx method 
% (cited in 1950 paper)
A = (X'*X)\eye(nvar); 
B = filter([-1,2,-1],1,X);
B([1,nobs],:) = X([1,nobs],:)-X([2,nobs-1],:);
C = X'*B*A;
nu1 = 2*(nobs - 1)-trace(C);
nu2 = 2*(3*nobs-4) - 2*trace(B'*B*A)+trace(C^2);
mu = nu1/(nobs-nvar);
sigma = sqrt( 2/((nobs-nvar)*(nobs-nvar+2))*(nu2-nu1*mu));

% evaluate the probability using normcdf
pval = cca_normcdf(dw,mu,sigma);
pval = 2*min(pval, 1-pval);     % two tailed test



