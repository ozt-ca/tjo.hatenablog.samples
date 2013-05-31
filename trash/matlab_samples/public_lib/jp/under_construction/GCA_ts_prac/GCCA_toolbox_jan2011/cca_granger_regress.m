function [ret] = cca_granger_regress(X,nlags,STATFLAG)
% -----------------------------------------------------------------------
%   FUNCTION: cca_granger_regress.m
%   PURPOSE:  perform multivariate regression with granger causality statistics
%
%   INPUT:  X           -   nvar (rows) by nobs (cols) observation matrix
%           nlags       -   number of lags to include in model
%           STATFLAG    -   if 1 do F-stats
%
%   OUTPUT: ret.covu    -   covariance of residuals for unrestricted model
%           ret.covr    -   covariance of residuals for restricted models
%           ret.prb     -   Granger causality probabilities (column causes
%                           row. NaN for non-calculated entries)
%           ret.fs      -   F-statistics for above
%           ret.gc      -   log ratio causality magnitude
%           ret.doi     -   difference-of-influence (based on ret.gc)
%           ret.rss     -   residual sum-square
%           ret.rss_adj -   adjusted residual sum-square
%           ret.waut    -   autocorrelations in residuals (by Durbin
%           Watson)
%           ret.cons    -   consistency check (see cca_consistency.m)

%   Written by Anil K Seth Sep 13 2004
%   Updated AKS December 2005
%   Updated AKS November 2006
%   Updated AKS December 2007 to do ratio based causality
%   Updated AKS May 2008, fix nlags = 1 bug.
%   Updated AKS Apr 2009, difference-of-influence and optional stats
%   Updated AKS Aug 2009, specify regressor matrix size in advance
%   Updated AKS Aug 2009, implement whiteness + consistency checks
%   Ref: Seth, A.K. (2005) Network: Comp. Neural. Sys. 16(1):35-55
% COPYRIGHT NOTICE AT BOTTOM
% -----------------------------------------------------------------------

% SEE COPYRIGHT/LICENSE NOTICE AT BOTTOM

% figure regression parameters
nobs = size(X,2);
nvar = size(X,1);
if(nvar>nobs) error('error in cca_granger_regress: nvar>nobs, check input matrix'); end
if nargin == 2, STATFLAG = 1; end

% remove sample means if present (no constant terms in this regression)
m = mean(X');
if(abs(sum(m)) > 0.0001)
    mall = repmat(m',1,nobs);
    X = X-mall;
end

% construct lag matrices
lags = -999*ones(nvar,nobs-nlags,nlags);
for jj=1:nvar
    for ii=1:nlags
        lags(jj,:,nlags-ii+1) = X(jj,ii:nobs-nlags+ii-1);
    end
end

%  unrestricted regression (no constant term)
regressors = zeros(nobs-nlags,nvar*nlags);
for ii=1:nvar,
    s1 = (ii-1)*nlags+1;
    regressors(:,s1:s1+nlags-1) = squeeze(lags(ii,:,:));
end

%xdep=X(:,nlags+1:end)';
%beta=regressors\xdep; 
for ii=1:nvar
    xvec = X(ii,:)';
    xdep = xvec(nlags+1:end);   
    beta(:,ii) = regressors\xdep;   
    xpred(:,ii) = regressors*beta(:,ii);  % keep hold of predicted values
    u(:,ii) = xdep-xpred(:,ii);
    RSS1(ii) = sum(u(:,ii).^2);
    C(ii) = covariance(u(:,ii),u(:,ii),nobs-nlags);   
end
covu = cov(u);

%   A rectangular matrix A is rank deficient if it does not have linearly independent columns.
%   If A is rank deficient, the least squares solution to AX = B is not unique.
%   The backslash operator, A\B, issues a warning if A is rank deficient and
%   produces a least squares solution that has at most rank(A) nonzeros.

%   restricted regressions (no constant terms)
for ii=1:nvar
    xvec = X(ii,:)';
    xdep = xvec(nlags+1:end);          % dependent variable
    caus_inx = setdiff(1:nvar,ii);     % possible causal influences on xvec
    u_r = zeros(nobs-nlags,nvar,'single');
    for jj=1:length(caus_inx)
        eq_inx = setdiff(1:nvar,caus_inx(jj));  % vars to include in restricted regression (jj on ii)
        regressors = zeros(nobs-nlags,length(eq_inx)*nlags);
        for kk=1:length(eq_inx)
            s1 = (kk-1)*nlags+1;
            regressors(:,s1:s1+nlags-1) = squeeze(lags(eq_inx(kk),:,:));
        end
        beta_r = regressors\xdep;
        temp_r = xdep-regressors*beta_r;
        RSS0(ii,caus_inx(jj)) = sum(temp_r.^2);
        S(ii,caus_inx(jj)) = covariance(temp_r,temp_r,nobs-nlags); % dec 08
        u_r(:,caus_inx(jj)) = temp_r;
    end
    covr{ii} = cov(u_r);
end

% calc Granger values
gc = ones(nvar).*NaN;
doi = ones(nvar).*NaN;
%   do Granger f-tests if required
if STATFLAG == 1,
    prb = ones(nvar).*NaN;
    ftest = zeros(nvar);
    n2 = (nobs-nlags)-(nvar*nlags);
    for ii=1:nvar-1
        for jj=ii+1:nvar
            ftest(ii,jj) = ((RSS0(ii,jj)-RSS1(ii))/nlags)/(RSS1(ii)/n2);    % causality jj->ii
            prb(ii,jj) = 1 - cca_cdff(ftest(ii,jj),nlags,n2);
            ftest(jj,ii) = ((RSS0(jj,ii)-RSS1(jj))/nlags)/(RSS1(jj)/n2);    % causality ii->jj
            prb(jj,ii) = 1 - cca_cdff(ftest(jj,ii),nlags,n2);
            gc(ii,jj) = log(S(ii,jj)/C(ii));
            gc(jj,ii) = log(S(jj,ii)/C(jj));
            doi(ii,jj) = gc(ii,jj) - gc(jj,ii);
            doi(jj,ii) = gc(jj,ii) - gc(ii,jj);
        end
    end
else
    ftest = -1;
    prb = -1;
    for ii=1:nvar-1,
        for jj=ii+1:nvar,
            gc(ii,jj) = log(S(ii,jj)/C(ii));
            gc(jj,ii) = log(S(jj,ii)/C(jj));
            doi(ii,jj) = gc(ii,jj) - gc(jj,ii);
            doi(jj,ii) = gc(jj,ii) - gc(ii,jj);
        end
    end
end

%   do r-squared and check whiteness, consistency
if STATFLAG == 1,
    df_error = (nobs-nlags)-(nvar*nlags);
    df_total = (nobs-nlags);
    for ii = 1:nvar
        xvec = X(ii,nlags+1:end);
        rss2 = xvec*xvec';
        rss(ii) = 1 - (RSS1(ii) ./ rss2);
        rss_adj(ii) = 1 - ((RSS1(ii)/df_error) / (rss2/df_total) );
        %waut(ii) = cca_whiteness(X,u(:,ii));
        waut(ii) = -1;  % TEMP APR 19 COMPILER ERROR
    end
    cons = cca_consistency(X,xpred);
else
    rss = -1;
    rss_adj = -1;
    waut = -1;
    cons = -1;
end

%   organize output structure
ret.gc = gc;
ret.fs = ftest;
ret.prb = prb;
ret.covu = covu;
ret.covr = covr;
ret.rss = rss;
ret.rss_adj = rss_adj;
ret.waut = waut;
ret.cons = cons;
ret.doi = doi;
ret.type = 'td_normal';

% This file is part of GCCAtoolbox.  It is Copyright (C) Anil Seth, 2004-09
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

