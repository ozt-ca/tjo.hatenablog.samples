function [M2] = cca_diff_mtrial(M,Nr,Nl)
%-----------------------------------------------------------------------
% FUNCTION: cca_diff_mtrial.m
% PURPOSE:  apply differencing to a data matrix of multiple trials
%
% INPUTS:   M:      nvar x nobs data matrix
%           Nr:     number of trials (realizations)
%           Nl:     length of each trial
%
% OUTPUT:   M2:     differenced data matrix (nvar,nobs-Nr)
%
%
%           Written by Anil Seth, December 2005
%           Updated A K Seth December 2009 for multiple trial data
%           Ref: Seth, A.K. (2005) Network: Comp. Neural. Sys. 16(1):35-55
%-----------------------------------------------------------------------

[nvar nobs] = size(M);
if(nobs < Nl)
    error('error in cca_diff: nobs < Nl, check data matrix');
end

off1 = 1;
off2 = 1;
M2 = zeros(nvar,nobs-Nr);
for ii=1:Nr,
    X = M(:,off1:off1+Nl-1);
    Xd = diff(X')';
    M2(:,off2:off2+Nl-2) = Xd;
    off1 = off1+Nl;
    off2 = off2+Nl-1;
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
% along with GCCAtoolbox.  If not, see <http://www.gnu.org/licenses/>.






