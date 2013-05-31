function ret = cca_partialgc(X,nlags,STATFLAG)
% -----------------------------------------------------------------------
%   FUNCTION: cca_partialgc.m
%   PURPOSE:  perform multivariate regression with partial granger
%             causality 
%
%   INPUT:  X           -   nvar (rows) by nobs (cols) observation matrix
%           NLAGS       -   number of lags to include in model
%           STATFLAG    -   do whiteness test (1) or not (0)
%
%   OUTPUT: ret.gc      - standard conditional Granger causality  
%           ret.fg      - Partial Granger causality
%           ret.doifg   - difference of influence (for partial)
%           ret.waut    - Durbin-Watson residual autocorrelation sig value
%           ret.cons    - model consistency (Ding et al 2000 method)
%
%   This function is based on original code provided by S. Guo, first
%   author of the below paper
%
%   REF: Guo, S., Seth, A.K., Kendrick, K., Zhou, C., and Feng, J. (2008).
%   Partial Granger causality: Eliminating exogenous inputs and latent variables. 
%   Journal of Neuroscience Methods. 172(1):79-93.
%
%   NOTE:  statistical distribution for partial granger is not known,
%   bootstrapping/surrogate methods must be used to assess significance.
%
%   AKS Apr 01 2009
%   Updated AKS Aug 2009 to implement whiteness/consistency test
% COPYRIGHT NOTICE AT BOTTOM
% -----------------------------------------------------------------------

% figure regression parameters
nobs = size(X,2);
nvar = size(X,1);
if(nvar>nobs) error('error in cca_partialgc: nvar>nobs, check input matrix'); end

% remove sample means if present (no constant terms in this regression)
m = mean(X');
if(abs(sum(m)) > 0.0001)
    mall = repmat(m',1,nobs);
    X = X-mall;
end

% loop through variables
GC = ones(nvar);
GC = GC.*NaN;
FG = ones(nvar);
FG = FG.*NaN;
doi = ones(nvar).*NaN;
for i=1:nvar-1
    for j=i+1:nvar
        B=X;
        B(i,:)=0;
        B(j,:)=0;
        L=B~=0;
        Z_remain=reshape(B(L),(nvar-2),nobs);
        Z1=[X(i,:);X(j,:);Z_remain];
        Z2=[X(j,:);X(i,:);Z_remain];
        Z1_delete=[Z1(1,:);Z1((3:nvar),:)];
        Z2_delete=[Z2(1,:);Z2((3:nvar),:)];
        [GC(i,j) FG(i,j)] = cond_gc(Z1,Z1_delete,nobs,nvar,nlags);
        [GC(j,i) FG(j,i)] = cond_gc(Z2,Z2_delete,nobs,nvar,nlags);   
        doi(i,j) = FG(i,j)-FG(j,i);
        doi(j,i) = FG(j,i)-FG(i,j);
    end
end
ret.gc = GC;
ret.fg = FG;
ret.doifg = doi;

if STATFLAG,
    T = cca_regress(X,nlags,1);
    ret.waut = T.waut;
    ret.cons = T.cons;
else
    ret.waut = -1;
    ret.cons = -1;
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [gc,fg] = cond_gc(X,Xr,nobs,nvar,nlags)

ret1 = cca_regress(X,nlags);
ret2 = cca_regress(Xr,nlags);
Su = ret1.Z;    % unrestricted, sigma 
Sr = ret2.Z;    % restricted, S 

% coefficients of noise covariance matrix for restricted regression
S_11 = [Sr(1,1)];
S_12 = [Sr(1,2:(nvar-1))];
S_21 = [Sr(2:(nvar-1),1)];
S_22 = [Sr(2:(nvar-1),2:(nvar-1))];

% coefficients of noise covariance matrix for unrestricted regression
sigma_11 = [Su(1,1)];
sigma_12 = [Su(1,3:nvar)];
sigma_21 = [Su(3:nvar,1)];
sigma_22 = [Su(3:nvar,3:nvar)];

% standard conditional GC
gc = log(S_11/sigma_11);  

% partial GC
fg = log(det(S_11-S_12*inv(S_22)*S_21)/det(sigma_11-sigma_12*inv(sigma_22)*sigma_21));


% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2007-2009) and S. Guo 
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





     
  

