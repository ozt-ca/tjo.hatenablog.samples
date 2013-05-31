function [ret] = cca_causalflow_spectral(GW,thresh)
%-----------------------------------------------------------------------
% FUNCTION: cca_causalflow_spectral.m
% PURPOSE:  calculate causal flow given a matrix of Granger causalities,
%           modified for spectral measures
%
% INPUTS:   GW: nvar by nvar by nfreq matrix of Granger magnitudes
%           thresh: EITHER 1*nfreq vector of thresholds for GC
%                   OR nvar*nvar*nfreq binary matrix showing significances
%                   (derived via bootstrap or permutation)
%
% OUTPUT:
%           ret.swindeg:    weighted incoming causal influences
%           ret.swoutdeg:   weighted outgoing causal influences
%           ret.swflow:     weighted out-in flow
%
%           ret.sindeg:    weighted incoming causal influences
%           ret.woutdeg:   weighted outgoing causal influences
%           ret.sflow:     weighted out-in flow
%           (last 3 only if bstrap/permute matrix is provided)
%
%           AKS April 2009,
%           based on aks_causalflow.m
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

% check inputs
nvar = size(GW,1);
nfreq = size(GW,3);
if nargin == 1,
    error('insufficient inputs to aks_causalflow_spectral.m');
end
if min(size(thresh)) == 1,
    METHOD = 1;
    disp('aks_causalflow_spectral: applying vector of thresholds, 1*nfreq');
else
    METHOD = 2;
    disp('aks_causalflow_spectral: applying bootstrap/permutation significance matrix');
end

if METHOD == 1,
    windeg = zeros(nvar,nfreq);
    woutdeg = zeros(nvar,nfreq);
    wflow = zeros(nvar,nfreq);
    for i=1:nfreq,
        X = GW(:,:,i);
        X(X<thresh(i)) = 0;
        windeg(:,i) = sum(X');
        woutdeg(:,i) = sum(X);
        wflow(:,i) = woutdeg(:,i) - windeg(:,i);
    end
    ret.swindeg = windeg;
    ret.swoutdeg = woutdeg;
    ret.swflow = wflow;
else
    windeg = zeros(nvar,nfreq);
    woutdeg = zeros(nvar,nfreq);
    wflow = zeros(nvar,nfreq);
    indeg = zeros(nvar,nfreq);
    outdeg = zeros(nvar,nfreq);
    flow = zeros(nvar,nfreq);
    PR = thresh;
    clear thresh;
    PR(PR~=0) = 1;  % ensure that all sig connections have value = 1
    for i=1:nfreq,
        X = GW(:,:,i);
        P = PR(:,:,i);
        indeg(:,i) = sum(P');
        outdeg(:,i) = sum(P);
        flow(:,i) = outdeg(:,i) - indeg(:,i);
        X(P==0) = 0;
        windeg(:,i) = sum(X');
        woutdeg(:,i) = sum(X);
        wflow(:,i) = woutdeg(:,i) - windeg(:,i);
    end
    ret.swindeg = windeg;
    ret.swoutdeg = woutdeg;
    ret.swflow = wflow;
    ret.sindeg = indeg;
    ret.soutdeg = outdeg;
    ret.sflow = flow;
end


% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2007-2009) 
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














