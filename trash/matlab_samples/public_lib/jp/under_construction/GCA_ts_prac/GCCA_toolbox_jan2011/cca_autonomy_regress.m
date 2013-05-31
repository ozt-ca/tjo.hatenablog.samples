function [ret] = cca_autonomy_regress(X,nlags)
% -----------------------------------------------------------------------
%   FUNCTION: cca_autonomy_regress.m
%   PURPOSE:  perform multivariate regression with granger causality statistics
%
%   INPUT:  X           -   nvar (rows) by nobs (cols) observation matrix
%           NLAGS       -   number of lags to include in model
%
%   OUTPUT: ret.prb     -   probability with which variable i is autonomous
%                           w.r.t. the other variables in the set
%           ret.fs      -   F-statistics for the same
%           ret.gaut    -   log ratio based magnitude of autonomy
%
%   Modified AKS February 2007 to implement the autonomy test
%   Modified AKS December 2008 to reorganize output and do ratio test
%   Modified AKS August 2009 to check residual autocorrelation &
%       consistency
%
%   Ref:  Seth, A.K. (in press). Measuring autonomy and emergence via
%       Granger causality. Artificial Lie
%   Ref:  Seth, A.K., Measuring autonomy via multivariate autoregressive
%           modelling, in Proceedings of the 9th European Conference on Artificial Life,
%           2007, p. 475-484.
%   COPYRIGHT NOTICE AT BOTTOM
% -----------------------------------------------------------------------

% figure regression parameters
nobs = size(X,2);
nvar = size(X,1);
if(nvar>nobs) error('error in cca_autonomy_regress: nvar>nobs, check input matrix'); end

% remove sample means if present (no constant terms in this regression)
X = cca_rm_temporalmean(X);

disp('computing G-autonomies');
% construct lag matrices
lags = -999*ones(nvar,nobs-nlags,nlags);
for jj=1:nvar
    for ii=1:nlags
        lags(jj,:,nlags-ii+1) = X(jj,ii:nobs-nlags+ii-1);
    end
end

%  unrestricted regression (no constant term)
regressors = zeros(nobs-nlags,nvar*nlags);
for ii=1:nvar
    s1 = (ii-1)*nlags+1;
    regressors(:,s1:s1+nlags-1) = squeeze(lags(ii,:,:));
end
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
    eq_inx = setdiff(1:nvar,ii);       % vars to include in restricted regression
    regressors = zeros(nobs-nlags,length(eq_inx)*nlags);
    for kk=1:length(eq_inx)
        s1 = (kk-1)*nlags+1;
        regressors(:,s1:s1+nlags-1) = squeeze(lags(eq_inx(kk),:,:));
    end
    beta_r = regressors\xdep;
    u_r(:,ii) = xdep-regressors*beta_r;
    S(ii) = covariance(u_r(:,ii),u_r(:,ii),nobs-nlags); % dec 08
    RSS0(ii) = sum(u_r(:,ii).^2);
end
covr = cov(u_r);

%   do Granger f-tests
prb = ones(nvar,1).*NaN;
ftest = zeros(nvar,1).*NaN;
gaut = ones(nvar,1).*NaN;
n2 = (nobs-nlags)-(nvar*nlags);
for ii=1:nvar
    ftest(ii) = ((RSS0(ii)-RSS1(ii))/nlags)/(RSS1(ii)/n2);
    prb(ii) = 1 - cca_cdff(ftest(ii),nlags,n2);
    gaut(ii) = log(S(ii)/C(ii));
end

%   do r-squared and check whiteness 
df_error = (nobs-nlags)-(nvar*nlags);
df_total = (nobs-nlags);
for ii = 1:nvar
    xvec = X(ii,nlags+1:end);
    rss2 = xvec*xvec';
    rss(ii) = 1 - (RSS1(ii) ./ rss2);
    rss_adj(ii) = 1 - ((RSS1(ii)/df_error) / (rss2/df_total) );
    waut(ii) = cca_whiteness(X,u(:,ii));
end

% check consistency
cons = cca_consistency(X,xpred,nvar);

%   organize output structure
ret.gaut = single(gaut');
ret.fs = single(ftest');
ret.prb = single(prb');
ret.covu = covu;
ret.covr = covr;
ret.rss = rss;
ret.rss_adj = rss_adj;
ret.waut = waut;
ret.cons = cons;

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



