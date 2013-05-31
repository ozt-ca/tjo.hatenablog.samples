function [H,ks] = cca_kpss(X,nlags,pval)
%-----------------------------------------------------------------------
% FUNCTION: cca_kpss.m
% PURPOSE:  stationarity test, to complement the ADF test
%           (cca_check_cov_stat).  Null hypothesis is that the variable
%           is stationary.

% INPUTS:   X: matrix of nvar variables by nobs observations of each variable
%           nlags: number of covariance lags over which to include in the Newey-West
%           estimator of long run variance.  Typically of order sqrt(T) for
%           T observations (default floor(sqrt(T)))
%           pval: critical level, choose from 0.10, 0.05, 0.01
%           (default 0.01)

% OUTPUT:   H: for each variable: 1 indicates nullH cannot be rejected,
%           i.e. variable is likely stationary.  0 indicates nullH should
%           be rejected, i.e. unit root likely present
%           ks: corresponding value of the kpss statistic
%
%           Written by Anil K Seth, December 2009
%           Based on code provided by Mario Forni
%           (http://www.economia.unimore.it/forni_mario/)

%           REF: D. Kwiatkowski, P. C. B. Phillips, P. Schmidt, and Y. Shin
%           (1992): Testing the Null Hypothesis of Stationarity against the
%           Alternative of a Unit Root. Journal of Econometrics 54, 159–178.
%
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------%
%
% level          opt=0      opt=1
%
%   .10:         .347        .119
%   .05:         .463        .146
%   .01          .739        .216

% initial business
ctable = [0.119 0.146 0.216]; % critical values for 0.1,0.05,0.01 respectively
[nvar,T] = size(X);
if(T<nvar) error('cca_kpss: Fewer observations than variables, exiting'); end

% check inputs
if nargin == 3,
    if ~ismember(pval,[0.01 0.05 0.1]),
        error(['error in cca_kpss: please choose 0.01, 0.05, or 0.10 for pval']);
    end
elseif nargin == 2
    pval = 0.01; % default
else
    pval = 0.01;
    nlags = floor(sqrt(T)); % default
    disp(['cca_kpss: using default covariance lags = ',num2str(nlags)]);
end
if pval == 0.01,
    ct = ctable(3);
elseif pval == 0.05,
    ct = ctable(2);
else 
    ct = ctable(1);
end

% calculate KPSS statistic and test against critical values
for ii=1:nvar,
    x = X(ii,:);
    x = x(:);
    [par, e] = cca_ols(x,[ones(T,1) (1:T)']);
    prod = zeros(nlags,1);
    for j = 1:nlags
        prod(j) = e(j+1:T)'*e(1:T-j);
    end
    s2 = e'*e + 2*(1-(1:nlags)/(nlags+1))*prod;
    S = cumsum(e);
    ks(ii) = T^(-1)*(S'*S)/s2;
    if ks(ii)>ct,
        H(ii) = 0;  % reject nullH
    else
        H(ii) = 1;
    end
end

% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2005-2010) 
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
% along with GCCAtoolbox.  If not, see <http://www.gnu.org/licenses/>.
