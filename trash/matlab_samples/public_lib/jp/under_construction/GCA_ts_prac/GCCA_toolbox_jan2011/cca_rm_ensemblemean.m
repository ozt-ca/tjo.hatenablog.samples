function [X2,M,E] = cca_rm_ensemblemean(X,Nr,Nl,FLAG)
%-----------------------------------------------------------------------
% FUNCTION: cca_rm_ensemblemean.m
% PURPOSE:  remove ensemble mean from a data matrix
% 
% INPUTS:   X:      nvar x nobs data matrix
%           Nr:     number of realizations
%           Nl:     number of data points in each realization
%           FLAG:   if 1 divide by ensemble standard deviation 
%           (default = 0)
%
%               
% OUTPUT:   X2:     processed data matrix (nvar x nobs) 
%           M:      matrix of ensemble means (nvar * Nl)
%           E:      (optional) matrix of ensemble stds (nvar * Nl)
%     
%           Written by Anil Seth, July 2009
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

[nvar nobs] = size(X);
if(nobs < nvar) 
    error('error in cca_rm_ensemblemean: nobs < nvar, check data matrix');
end
if nargin < 3,
    error('insufficient inputs to cca_rm_ensemblemean');
end
if nargin == 3,
    FLAG = 0;
    E = [];
end
if nobs ~= Nr*Nl,
    error('cca_rm_ensemblemean: inputs do not match data matrix size');
end
    
% reshape matrix
XX = zeros(Nl,nvar,Nr);
for ii=1:nvar,
    inx = 1;
    for jj=1:Nr,
        XX(:,ii,jj) = X(ii,inx:inx+Nl-1);
        inx=inx+Nl;
    end
end

% subtract ensemble mean
M = zeros(nvar,Nl);
if FLAG==1,
    E =zeros(nvar,Nl);
end
for ii = 1:nvar,
    temp = XX(:,ii,:);
    m = mean(temp,3);
    if FLAG==1, e = std(temp,0,3); end
    for jj = 1:Nr,
        XX(:,ii,jj) = XX(:,ii,jj)-m;
        if FLAG==1,
            XX(:,ii,jj) = XX(:,ii,jj)./e;
        end  
    end
    M(ii,:) = m;
    if FLAG==1,
        E(ii,:) = e;
    end
end

% inverse reshape matrix
for ii=1:nvar,
    inx = 1;
    for jj=1:Nr,
        X(ii,inx:inx+Nl-1) = XX(:,ii,jj);
        inx=inx+Nl;
    end
end
clear XX;
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









