function [X2,m,e] = cca_rm_temporalmean(X,FLAG)
%-----------------------------------------------------------------------
% FUNCTION: cca_rm_temporalmean.m
% PURPOSE:  remove temporal mean from a data matrix
% 
% INPUTS:   X:      nvar x nobs data matrix
%           FLAG:   if 1 divide by temporal standard deviation 
%           (default = 0)
%               
% OUTPUT:   X2:     processed data matrix (nvar x nobs)  
%           m:      vector of temporal means (nvar)
%           e:      (optional) vector of temporal standard deviations
%     
%           Written by Anil Seth, July 2009
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

[nvar nobs] = size(X);
if(nobs < nvar) 
    error('error in cca_rm_temporalmean: nobs < nvar, check data matrix');
end
if  nargin < 2,
    FLAG = 0;
end
clear m;
e = [];
for ii=1:nvar,
    vec = X(ii,:);
    m(ii) = mean(vec);
    vec = vec-m(ii);
    X(ii,:) = vec;
    if FLAG == 1,   % divide by temporal std if required
        e(ii) = std(vec);
        X(ii,:) = X(ii,:)./e(ii);
    end
end
X2 = X;

% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2009) 
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






