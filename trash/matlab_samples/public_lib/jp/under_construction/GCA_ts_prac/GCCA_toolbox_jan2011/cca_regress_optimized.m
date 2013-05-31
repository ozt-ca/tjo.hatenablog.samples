% -----------------------------------------------------------------------
%   FUNCTION: cca_regress.m
%   PURPOSE:  perform multivariate regression
%
%   INPUT:  X           -   nvar (rows) by nobs (cols) observation matrix
%           NLAGS       -   number of lags to include in model
%           STATFLAG    -   perform Whiteness/Consistency checks or not
%
%   OUTPUT: ret.beta    -   coefficients
%           ret.u       -   residuals
%           ret.rss     -   sum-square-error of residuals
%           ret.Z       -   covariance matrix of residuals
%           ret.waut    -   Durbin Watson autocorrelated residual sig val
%           ret.cons    -   model consistency (Ding et al 2000)
%
%   Written AKS Sep 13 2004
%   Updated AKS December 2005
%   Updated AKS Aug 2009 to implement whiteness & consistency check
%   Ref: Seth, A.K. (2005) Network: Comp. Neural. Sys. 16(1):35-55
% COPYRIGHT NOTICE AT BOTTOM
% -----------------------------------------------------------------------
function [ret] = cca_regress_optimized(X,nlags,STATFLAG)

if nargin<3,
    STATFLAG = 1;
end

% figure regression parameters
[nvar,nobs] = size(X);
if(nvar>nobs) error('nvar>nobs, check input matrix'); end

% remove sample means if present (no constant terms in this regression)
m = mean(X');
if(abs(sum(m)) > 0.0001)
    mall = repmat(m',1,nobs);
    X = X-mall;
end

% construct lag matrices
lags = -999*ones(nvar,nobs-nlags,nlags);
for jj=1:nvar
    for ii=1:nlags
        lags(jj,:,nlags-ii+1) = X(jj,ii:nobs-nlags+ii-1);
    end
end

%  regression (no constant term)
regressors = zeros(nobs-nlags,nvar*nlags);
for ii=1:nvar,
    s1 = (ii-1)*nlags+1;
    regressors(:,s1:s1+nlags-1) = squeeze(lags(ii,:,:));
end


xdep=X(:,nlags+1:end)';
beta=regressors\xdep;
xpred=regressors*beta;
u=xdep-xpred;
RSS=sum(u.^2);


% check whiteness & consistency if required
if STATFLAG,
    for ii=1:nvar,
        waut(ii) = cca_whiteness(X,u(:,ii));
    end
    cons = cca_consistency(X,xpred);
else
    waut = -1;
    cons = -1;
end

%   organize output structure
ret.beta = beta;
ret.u = u;
ret.rss = RSS;
ret.cons = cons;
ret.waut = waut;
ret.Z = cov(u);

% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2005-2009) 
% 
% GCCAtoolbox is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% GCCAtoolbox is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with GCCAtoolbox. If not, see <http://www.gnu.org/licenses/>.


