function [Y]=cca_detrend_mtrial(X,Nr,Nl)
%-----------------------------------------------------------------------
% FUNCTION: cca_detrend_mtrial.m
% PURPOSE:  remove deterministic linear trends from multitrial data
% 
% INPUTS:   X:      nvar (rows) by nobs (cols) observation matrix
%           Nr:     number of realizations
%           Nl:     lenght of each realization
%         
% OUTPUT:   Y:      detrended matrix of same dimensions as X
%     
%           Written by Anil Seth, May 2010
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

nobs = size(X,2);
nvar = size(X,1);
if(nvar>nobs) error('error in cca_detrend: nvar>nobs, check input matrix'); end

% detrend each realization separately
startinx = 1;
for i=1:Nr,
    endinx = startinx+Nl-1;
    if endinx>nobs,
        endinx = nobs;
    end
    XX = X(:,startinx:endinx);
    XX = cca_detrend(XX);
    X(:,startinx:endinx) = XX;
    startinx=startinx+Nl;
end
Y = X;


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
% along with GCCAtoolbox.  If not, see <http://www.gnu.org/licenses/>.