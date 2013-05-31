function [H,ks] = cca_kpss_mtrial(X,Nr,Nl,nlags,pval)
%-----------------------------------------------------------------------
% FUNCTION: cca_kpss_mtrial.m
% PURPOSE:  stationarity test, to complement the ADF test
%           (cca_check_cov_stat).  Null hypothesis is that the variable
%           is stationary.  Adapted for multiple trials

% INPUTS:   X: matrix of nvar variables by nobs observations of each variable
%           Nr: number of realizations
%           Nl: number of data points in each realization
%           nlags: number of covariance lags over which to include in the Newey-West
%           estimator of long run variance.  Typically of order sqrt(T) for
%           T observations (default floor(sqrt(T)))
%           pval:  critical level, choose from 0.10, 0.05, 0.01
%           (default 0.01)

% OUTPUT:   H: for each variable by trial (ie a matrix): 1 indicates nullH cannot be rejected,
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

% check inputs
[nvar,T] = size(X);
if(Nl<nvar) error('cca_kpss_mtrial: Fewer observations than variables, exiting'); end
if nargin == 5,
    if ~ismember(pval,[0.01 0.05 0.1]),
        error(['error in cca_kpss_mtrial: please choose 0.01, 0.05, or 0.10 for pval']);
    end
elseif nargin == 4,
    pval = 0.01; % default
elseif nargin == 3,
    pval = 0.01;
    nlags = floor(sqrt(Nl)); % default
    disp(['cca_kpss_mtrial: using default covariance lags = ',num2str(nlags)]);
else
    error('cca_kpss_mtrial: insufficient inputs');
end

% extract each trial and test sequentially
ks = ones(nvar,Nr).*-999;
H = ks;
offset = 1;
for j=1:Nr,
    for i=1:nvar
        y = X(i,offset:offset+Nl-1);
        [H(i,j),ks(i,j)] = cca_kpss(y,nlags,pval);        % call kpss test
    end
    offset=offset+Nl;
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
