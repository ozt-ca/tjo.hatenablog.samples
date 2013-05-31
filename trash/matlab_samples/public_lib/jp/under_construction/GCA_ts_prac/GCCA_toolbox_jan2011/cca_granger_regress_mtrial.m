function ret = cca_granger_regress_mtrial(X,Nr,Nl,nlags,STATFLAG)
% -----------------------------------------------------------------------
%   FUNCTION: cca_granger_regress_mtrial
%   PURPOSE:  perform multivariate regression with granger causality statistics
%             code modified to deal with multitrial data, though less
%             efficient
%
%   INPUT:  X           -   nvar (rows) by nobs (cols) observation matrix
%           Nr          -   # realizations
%           Nl          -   length of each realization
%           nlags       -   number of lags to include in model
%           STATFLAG    -   (1=calculate Fstat/prb/dw/cons, 0 = don't)
%
%           (for single stationary trial, Nr=1, Nl=nobs)
%
%   OUTPUT: prb - conditional Granger causality
%           fs - F-statistic
%           gc - conditional Granger using cov error ratio
%           doi - difference-of-influence terms
%           waut - Durbin Watson whiteness check
%           cons - MVAR consistency check
%
%   Based on cca_granger_regress.m
%   Modified Apr 01 2009 to implement multitrial structure & doi output
%   Modified Aug 2009 to implement whiteness/consistency checks
% COPYRIGHT NOTICE AT BOTTOM
% -----------------------------------------------------------------------

if nargin<5,
    STATFLAG = 1;   % default is to compute F-stats and significances
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
fs = ones(nvar);
fs = fs.*NaN;
prb = ones(nvar);
prb = prb.*NaN;
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

        % call regression routines
        [prb(i,j) fs(i,j) gc(i,j)] = cond_gc(Z1,Z1_delete,nobs,nvar,Nr,Nl,nlags,STATFLAG);
        [prb(j,i) fs(j,i) gc(j,i)] = cond_gc(Z2,Z2_delete,nobs,nvar,Nr,Nl,nlags,STATFLAG);
        
        % difference of influence terms
        doi(i,j) = gc(i,j)-gc(j,i);
        doi(j,i) = gc(j,i)-gc(i,j);
    end
end

% check residual autocorrelation via Durbin-Watson statistic, and model
% consistency via Ding et al 2000 method
if STATFLAG,
    [waut,cons] = cca_mtrial_whitecon(X,Nr,Nl,nlags);
else
    waut = -1;
    cons = -1;
end

ret.prb = prb;          % prob
ret.fs = fs;            % fstat
ret.gc = gc;            % cov ratio
ret.doi = doi;          % difference-of-influence
ret.waut = waut;        % Durbin-Watson sig value for correlated residuals
ret.cons = cons;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [prb,fs,gc] = cond_gc(X,Xr,nobs,nvar,Nr,Nl,nlags,STATFLAG)

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

% compute F-stat, significance, if required
if STATFLAG,

    % convert coefficients to cca_regress format
    Au = armorf_to_cca(Au,nvar,nlags);
    Ar = armorf_to_cca(Ar,nvar-1,nlags);

    % compute residuals for each realization separately
    startinx = 1;
    uu = []; ur = [];
    for i=1:Nr,
        endinx = startinx+Nl-1;
        if endinx>nobs,
            endinx = nobs;
        end
        XX = X(:,startinx:endinx);
        XXr = Xr(:,startinx:endinx);
        uu = [uu ; cca_calc_resid(XX,Au,Nl,nvar,nlags)];      % unrestricted
        ur = [ur ; cca_calc_resid(XXr,Ar,Nl,nvar-1,nlags)];   % restricted
        startinx=startinx+Nl;
    end

    % compute RSSs
    for ii=1:nvar,
        RSSu(ii) = sum(uu(:,ii).^2);
    end
    for ii=1:nvar-1,
        RSSr(ii) = sum(ur(:,ii).^2);
    end
    
    % compute Granger stats
    n2 = (nobs-nlags)-(nvar*nlags);
    fs = ((RSSr(1)-RSSu(1))/nlags)/(RSSu(1)/n2);
    prb = 1 - cca_cdff(fs,nlags,n2);
else
    fs = -999;
    prb = -999;
end


% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2007-2009) and Yonghong Chen (2002) 
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









