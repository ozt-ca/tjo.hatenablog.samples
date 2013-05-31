function [M2] = cca_diff(M)
%-----------------------------------------------------------------------
% FUNCTION: cca_diff.m
% PURPOSE:  apply differencing to a data matrix
% 
% INPUTS:   M:      nvar x nobs data matrix
%               
% OUTPUT:   M2:     differenced data matrix (nvar x nobs-1)   
%     
%           Written by Anil Seth, December 2005
%           Ref: Seth, A.K. (2005) Network: Comp. Neural. Sys. 16(1):35-55
%-----------------------------------------------------------------------

[nvar nobs] = size(M);
if(nobs < nvar) 
    error('error in cca_diff: nobs < nvar, check data matrix');
end
M2 = diff(M');
M2 = M2';

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
% along with GCCAtoolbox.  If not, see <http://www.gnu.org/licenses/>.
        





