function unit_root = cca_check_cov_stat(X,NLAGS)
%-----------------------------------------------------------------------
% FUNCTION: cca_check_cov_stat.m
% PURPOSE:  verify that all time-series in a multivariate set are
%           covariance-stationary. Uses the Dickey-Fuller test for
%           unit-roots
% 
% INPUTS:   X: matrix of nvar variables by nobs observations of each variable    
%           NLAGS: number of lags over which to make estimations (<<nobs)
%
% OUTPUT:   unit_root: vector of length nvar containing '0' for no unit
%           roots, and 1 for a unit root.  Presence of a unit root
%           indicates the corresponding time-series is not
%           covariance-stationary. 
%
%           Written by Anil K Seth, March 2004
%           Updated August 2004
%           Ref: Seth, A.K. (2005) Network: Comp. Neural. Sys. 16(1):35-55
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

[nvar,nobs] = size(X);
if(nobs<nvar) error('Fewer observations than variables, exiting'); end
if(nobs<NLAGS) error('NLAGS too large, exiting'); end

unit_root = zeros(nvar,1);
for i=1:nvar
    y = X(i,:);
    for nlags = 1:NLAGS
        res = cca_adf(y',0,nlags);        % augmented Dickey-Fuller test
        tstat(i,nlags) = res.adf;
        cval(i,nlags) = res.crit(3);  % use 10% quintile, see cca_adf.m for more info
        if(tstat(i,nlags) > cval(i,nlags)) unit_root(i) = 1; end
    end 
end


% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2004-2009) 
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

