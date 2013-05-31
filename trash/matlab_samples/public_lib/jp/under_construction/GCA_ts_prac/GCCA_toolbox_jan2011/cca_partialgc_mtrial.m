function ret = cca_partialgc_mtrial(X,Nr,Nl,nlags,STATFLAG)
% -----------------------------------------------------------------------
%   FUNCTION: cca_partialgc_mtrial
%   PURPOSE:  partial granger causality with multitrial analysis
%
%   INPUT:  X           -   nvar (rows) by nobs (cols) observation matrix
%           Nr          -   # realizations
%           Nl          -   length of each realization
%           nlags       -   number of lags to include in model
%           STATFLAG    -   calc Durbin Watson & consistency (1) or not (0)
%
%           (for single stationary trial, Nr=1, Nl=nobs)
%           (no significance tests available for partial GC)
%
%   OUTPUT: fg - partial Granger causality 
%           gc - conditional Granger using cov error ratio
%           doifg - difference-of-influence for partial GC
%           waut - Durbin Watson residual autocorrelation sig value
%           cons - MVAR model consistency (Ding et al 2000)
%
%   Based on cca_granger_regress_mtrial.m
%   AKS adapted for partial GC Apr 02 2009 
%   AKS include difference-of-influence (DOI) terms Apr 16 2009
%   Modified Aug 2009 to implement whiteness & consistency check
% COPYRIGHT NOTICE AT BOTTOM
% -----------------------------------------------------------------------
if nargin<5,
    STATFLAG = 1;
end

% figure regression parameters
nobs = size(X,2);
nvar = size(X,1);
if(nvar>nobs) error('error in cca_granger_regress_mtrial: nvar>nobs, check input matrix'); end

% remove ensemble mean
m = mean(X');
mall = repmat(m',1,nobs);
X = X-mall;

% remove sample means from each realization separately
startinx = 1;
for i=1:Nr,
    endinx = startinx+Nl-1;
    if endinx>nobs,
        endinx = nobs;
    end
    XX = X(:,startinx:endinx);
    m = mean(XX');
    if(abs(sum(m)) > 0.00001)
        mall = repmat(m',1,length(XX));
        XX = XX-mall;
    end
    X(:,startinx:endinx) = XX;
    startinx=startinx+Nl;
end

% loop through variables
gc = ones(nvar);
gc = gc.*NaN;
fg = ones(nvar);
fg = fg.*NaN;
doi = ones(nvar).*NaN;
doifg = ones(nvar).*NaN;
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
        
        % call regression routines
        [gc(i,j) fg(i,j)] = cond_gc(Z1,Z1_delete,nobs,nvar,Nr,Nl,nlags);
        [gc(j,i) fg(j,i)] = cond_gc(Z2,Z2_delete,nobs,nvar,Nr,Nl,nlags); 
        
        % difference-of-influence terms (partial)
        doifg(i,j) = fg(i,j)-fg(j,i);
        doifg(j,i) = fg(j,i)-fg(i,j);
        
        % difference-of-influence terms (standard)
        doi(i,j) = gc(i,j)-gc(j,i);
        doi(j,i) = gc(j,i)-gc(i,j);
          
    end
end
ret.fg = fg;       % partial granger causality
ret.gc = gc;       % standard conditional granger causality
ret.doifg = doi;
ret.doi = doi;

% check residual autocorrelation via Durbin-Watson statistic% & consistency
if STATFLAG,
    [waut,cons] = cca_mtrial_whitecon(X,Nr,Nl,nlags);
else
    waut = -1;
    cons = -1;
end
ret.waut = waut;
ret.cons = cons;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [gc,fg] = cond_gc(X,Xr,nobs,nvar,Nr,Nl,nlags)

% perform regressions
[Au,Su] = armorf(X,Nr,Nl,nlags);
[Ar,Sr] = armorf(Xr,Nr,Nl,nlags);

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




     
  
