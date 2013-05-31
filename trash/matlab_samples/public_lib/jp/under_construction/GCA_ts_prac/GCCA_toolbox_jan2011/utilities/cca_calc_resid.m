%   FUNCTION:   cca_calc_resid
%   PURPOSE:    find RSS given coefficients, target values
%
%   INPUTS:     beta - coefficient matrix in cca_regress form
%               X - data matrix
%               nobs, nvar, nlags (standard)
%   OUTPUTS:    u - residuals
%               xpred - predicted values
%
%   AKS Apr 02 2009

function [u,xpred] = cca_calc_resid(X,beta,nobs,nvar,nlags)

% construct lag matrices
lags = -999*ones(nvar,nobs-nlags,nlags);
for jj=1:nvar,
    for ii=1:nlags,
        lags(jj,:,nlags-ii+1) = X(jj,ii:nobs-nlags+ii-1);
    end
end
regressors = zeros(nobs-nlags,nvar*nlags);
for ii=1:nvar,
    s1 = (ii-1)*nlags+1;
    regressors(:,s1:s1+nlags-1) = squeeze(lags(ii,:,:));
end
regressors = squeeze(regressors);
for ii=1:nvar, 
    xvec = X(ii,:)';
    xdep = xvec(nlags+1:end);
    xpred(:,ii) = regressors*beta(:,ii);
    u(:,ii) = xdep-regressors*beta(:,ii);
end

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
