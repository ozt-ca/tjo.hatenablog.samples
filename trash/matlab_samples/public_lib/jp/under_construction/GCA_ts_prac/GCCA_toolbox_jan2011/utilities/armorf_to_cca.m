% FUNCTION: beta2 = armorf_to_aks
%
% PURPOSE:  rearrange coefficient output of ARMORF.m into the same
%           format as aks_regress.m
%
% AKS Apr 02 2009

function beta2 = armorf_to_aks(beta,nvar,nlags)

ct = 1; 
for i=1:nvar,
    for j=1:nlags,
        beta2(:,ct) = beta(:,i+(j-1)*nvar);
        ct = ct+1;
    end
end
beta2 = -beta2';

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
