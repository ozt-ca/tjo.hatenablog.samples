function ret = cca_partialgc_doi_bstrap(X,Nr,Nl,nlags,nBoot,nBwin,pval,CORRTYPE,DOIFLAG)
% -----------------------------------------------------------------------
%   FUNCTION: cca_partialgc_doi_bstrap
%   PURPOSE:  partial granger causality with multitrial analysis, DOI,
%             AND bootstrap confidence interval construction
%             (for single trial use Nr=1, Nl=N)
%
%   INPUT:  X           -   nvar (rows) by nobs (cols) observation matrix
%           Nr          -   # realizations
%           Nl          -   length of each realization
%           nlags       -   number of lags to include in model
%           nBoot       -   # bootstrap resamples 
%           nBwin       -   # observations in each window 
%           pval        -   desired probability threshold
%           CORRTYPE    -   0=none, 1=Bonferroni, 2=approx FDR
%           DOIFLAG     -   1=DOI terms for standard, 2=DOI for partial,
%                           0=neither (default)
%
%   OUTPUT: fg - partial Granger causality 
%           gc - conditional Granger using cov error ratio
%           pr - significance of fg interactions
%           ll - lower limit on fg
%           ul - upper limit on fg
%           ci - post-correction confidence intervals  (upper/lower)
%
%           doi - difference of influence terms
%           waut - Durbin Watson residual autocorrelation sig value
%           cons - MVAR model consistency (Ding et al 2000)
%           lld - lower limit (for DOI)
%           uld - upper limit (for DOI)
%           prd - significance of DOIs
%
%           NOTE: 'windows' here refer to how the data is divided up prior
%           to resampling/permuting.  If the data is naturally multitrial,
%           with many trials, then set nBwin = Nl.  Otherwise, set nBwin to
%           a smaller value which is an integer fraction of Nl.  At
%           minimum, nBwin = nlags.  (If data is not multitrial, then set
%           nBwin to a reasonable value - e.g., 2*nlags).
%
%   `       HINT: use 'permute' to establish if a value is significantly 
%           different from zero, use 'bstrap' to estimate CIs around the
%           true value of, useful for comparing >1 value.
%
%   AKS Apr 2009
%   Updated AKS Aug 2009 to implement whiteness & consistency test
% COPYRIGHT NOTICE AT BOTTOM
% -----------------------------------------------------------------------

% check inputs
if nargin<8,
     error('error in cca_partialgc_bstrap: insufficient inputs');
end
if nBwin == Nl & Nr<10,
    disp('Warning in cca_partialgc_bstrap: perhaps too few trials for effective bootstrapping, reduce nBwin');
end
if mod(Nl,nBwin) ~= 0,
    error('error in cca_partialgc_bstrap: trial length must be an integer multiple of boot win length');
end
nwin = (Nl*Nr)/nBwin;   % figure number of bootstrap windows
if ~isint(nwin),
    error('error in cca_partialgc_bstrap: data length must be an integer multiple of boot win length');
end
if nargin==8,
    DOIFLAG = 0;    % default, do not compute DOI values
end

% figure data parameters
nobs = size(X,2);
nvar = size(X,1);

% figure confidence intervals
if CORRTYPE == 1,
    pval = pval/nvar;
elseif CORRTYPE == 2, 
     m = nvar*(nvar-1);
     pval = ((m+1)/(2*m))*pval; 
end
CI_upper = pval/2;       % upper percentile of confidence interval
CI_lower = 1-CI_upper;   % lower percentile of confidence interval
disp(['setting confidence intervals to ',num2str(CI_upper),' & ',num2str(CI_lower)]);

% remove ensemble mean
m = mean(X');
mall = repmat(m',1,nobs);
X = X-mall;

% calculate partial GC from original data
r1 = cca_partialgc_mtrial(X,Nr,Nl,nlags,1);
R_original = r1.fg;       % partial granger causality
ret.gc = r1.gc;           % standard conditional granger causality
if DOIFLAG==1, 
    R_origd = r1.doi;
    disp('computing standard difference-of-influence terms');
elseif DOIFLAG==2,
    R_origd = r1.doifg;
    disp('computing partial difference-of-influence terms');
end

% generate bootstrap resamples
R_bstrp = zeros(nvar,nvar,nBoot);       % bootstrap matrix
if DOIFLAG, R_bootd = zeros(nvar,nvar,nBoot); end
for ii=1:nBoot,
    XX = genBoot(X,nBwin,nwin,nvar,nobs);
    r2 = cca_partialgc_mtrial(XX,nwin,nBwin,nlags);
    R_bstrp(:,:,ii) = r2.fg;
    if DOIFLAG==1, 
        R_bootd(:,:,ii) = r2.doi; 
    elseif DOIFLAG==2,
        R_bootd(:,:,ii) = r2.doifg;
    end
    disp(['done partialgc/doi bootstrap trial ',num2str(ii),'/',num2str(nBoot)]);
end

% Find the x% and y% empirical quantile of R(1)-R_original,....,R(Nboot)-R_original, 
% Q_5 and Q_95, and obtain the 90% bootstrap confidence interval for the true R as:
% (R_original - Q_95, R_original - Q_5).
R_diff = zeros(nvar,nvar,nBoot);
for ii=1:nBoot,
    R_diff(:,:,ii) = R_bstrp(:,:,ii)-R_original;
end
if DOIFLAG,
    R_diffdoi = zeros(nvar,nvar,nBoot);
    for ii=1:nBoot,
        R_diffdoi(:,:,ii) = R_bootd(:,:,ii)-R_origd;
    end
end

% construct confidence intervals
ll = zeros(nvar);
ul = zeros(nvar);
if DOIFLAG,
    uld = zeros(nvar);
    lld = zeros(nvar);  
end
for ii=1:nvar-1,
    for jj=ii+1:nvar,
        if ii~=jj,
            ul(ii,jj) = quantile(squeeze(R_diff(ii,jj,:)),CI_upper);    
            ll(ii,jj) = quantile(squeeze(R_diff(ii,jj,:)),CI_lower);   
            ul(jj,ii) = quantile(squeeze(R_diff(jj,ii,:)),CI_upper);
            ll(jj,ii) = quantile(squeeze(R_diff(jj,ii,:)),CI_lower);
             if DOIFLAG,
                uld(ii,jj) = quantile(squeeze(R_diffdoi(ii,jj,:)),CI_upper);
                lld(ii,jj) = quantile(squeeze(R_diffdoi(ii,jj,:)),CI_lower);
                uld(jj,ii) = quantile(squeeze(R_diffdoi(jj,ii,:)),CI_upper);
                lld(jj,ii) = quantile(squeeze(R_diffdoi(jj,ii,:)),CI_lower);
            end
        end
    end
end
ul = R_original-ul;
ll = R_original-ll;
PR = ll>0;              % find significant interactions
if DOIFLAG,
    uld = R_origd-uld;
    lld = R_origd-lld;
    PRD = lld>0;
end

% format output
ret.fg = R_original;
ret.PR = PR;
ret.ll = ll;
ret.ul = ul;
ret.ci = [CI_lower CI_upper];
ret.waut = r1.waut;
ret.cons = r1.cons;
if DOIFLAG,
    ret.doi = R_origd;
    ret.uld = uld;
    ret.lld = lld;
    ret.PRD = PRD;
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







     
  
