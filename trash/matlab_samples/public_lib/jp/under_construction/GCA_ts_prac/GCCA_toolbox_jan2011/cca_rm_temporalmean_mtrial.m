function [X2] = cca_rm_temporalmean_mtrial(X,Nr,Nl,FLAG)
%-----------------------------------------------------------------------
% FUNCTION: cca_rm_temporalmean_mtrial.m
% PURPOSE:  remove temporal mean from a multitrial data matrix
%           for each realization separately
% 
% INPUTS:   X:      nvar x nobs data matrix
%           Nr:     number of realizations
%           Nl:     number of observations per realization
%           FLAG:   if 1 divide by temporal standard deviation 
%           (default = 0)
%               
% OUTPUT:   X2:     processed data matrix (nvar x nobs)  
%     
%           Written by Anil Seth, May 2010
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

[nvar nobs] = size(X);
if(nobs < nvar) 
    error('error in cca_rm_temporalmean: nobs < nvar, check data matrix');
end
if  nargin < 4,
    FLAG = 0;
end

nobs = size(X,2);
nvar = size(X,1);
if(nvar>nobs) error('error in cca_detrend: nvar>nobs, check input matrix'); end

% remove temporal means from each realization separately
startinx = 1;
for i=1:Nr,
    endinx = startinx+Nl-1;
    if endinx>nobs,
        endinx = nobs;
    end
    XX = X(:,startinx:endinx);
    XX = cca_rm_temporalmean(XX,FLAG);
    X(:,startinx:endinx) = XX;
    startinx=startinx+Nl;
end
X2 = X;


% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2010) 
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






