function [ret] = cca_causaldensity_spectral(GW,thresh)
%-----------------------------------------------------------------------
% FUNCTION: cca_causaldensity_spectral.m
% PURPOSE:  calculate causal density given a matrix of Granger causalities
%
% INPUTS:   GW:     nvar by nvar by nfreq matrix of Granger magnitudes
%           thresh: EITHER 1*nfreq vector of thresholds for GC
%                   OR nvar*nvar*nfreq binary matrix showing significances
%                   (derived via bootstrap or permutation)
%
% OUTPUT:
%           ret.scdw:    causal density weighted by  magnitude (not
%                        bounded, 1*nfreq)
%           ret.sucdw:   unit causal density, nvar * nfreq
%
%           ret.scd:    1*nfreq vector of causal densities, unweighted
%           ret.sucd:   unit causal density, nvar * nfreq
%           (the latter two only returned for bstrap/permute matrices)
%
%           AKS April 2009 AKS, based on cca_causaldensity.m
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

% check inputs
nvar = size(GW,1);
nfreq = size(GW,3);
if nargin == 1,
    error('insufficient inputs to cca_causaldensity_spectral.m');
end
if min(size(thresh)) == 1,
    METHOD = 1;
    disp('cca_causaldensity_spectral: applying vector of thresholds, 1*nfreq');
else
    METHOD = 2;
    disp('cca_causaldensity_spectral: applying bootstrap/permutation significance matrix');
end

if METHOD == 1,
    scdw = zeros(1,nfreq);
    sucdw = zeros(nvar,nfreq);
    for i=1:nfreq,
        X = GW(:,:,i);
        X(X<thresh(i)) = 0;
        scdw(i) = sum(sum(X))/(nvar*(nvar-1));
        sucdw(:,i) = ((sum(X)/nvar) + ((sum(X'))/nvar))';
    end
    ret.scdw = scdw;
    ret.sucdw = sucdw;
else
    scdw = zeros(1,nfreq);
    sucdw = zeros(nvar,nfreq);
    scd = zeros(1,nfreq);
    sucd = zeros(nvar,nfreq);
    PR = thresh;
    clear thresh;
    PR(PR~=0) = 1;  % ensure that all sig connections have value = 1
    for i=1:nfreq,
        X = GW(:,:,i);
        P = PR(:,:,i);
        scd(i) = sum(sum(P))/(nvar*(nvar-1));
        sucd(:,i) = (sum(P)/nvar) + ((sum(P'))/nvar);
        X(P==0) = 0;
        scdw(i) = sum(sum(X))/(nvar*(nvar-1));
        sucdw(:,i) = ((sum(X)/nvar) + ((sum(X'))/nvar))';
    end
    ret.scdw = scdw;
    ret.sucdw = sucdw;
    ret.scd = scd;
    ret.sucd = sucd;
end


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





