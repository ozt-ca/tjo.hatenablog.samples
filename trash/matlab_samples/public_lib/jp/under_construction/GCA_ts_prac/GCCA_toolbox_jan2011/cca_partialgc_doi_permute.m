function ret = cca_partialgc_doi_permute(X,Nr,Nl,nlags,nPerm,nBwin,pval,CORRTYPE,DOIFLAG)
% -----------------------------------------------------------------------
%   FUNCTION: cca_partialgc_doi_permute
%   PURPOSE:  partial granger causality with multitrial analysis, DOI,
%             AND random permutation statistical analysis
%             (for single trial use Nr=1, Nl=N)
%
%   INPUT:  X           -   nvar (rows) by nobs (cols) observation matrix
%           Nr          -   # realizations
%           Nl          -   length of each realization
%           nlags       -   number of lags to include in model
%           nPerm       -   # permutation resamples 
%           nBwin       -   # observations in each window 
%           pval        -   desired probability threshold
%           CORRTYPE    -   0=none, 1=Bonferroni, 2=approx FDR
%           DOIFLAG     -   1=DOI terms for standard, 2=DOI for partial,
%                           0=neither (default)
%
%   OUTPUT: fg - partial Granger causality 
%           gc - conditional Granger using cov error ratio
%           pr - significance of fg interactions
%           ll - limit of permuted series (>0)
%           md - median value of permuted series
%           ci - post-correction confidence interval (>0)
%
%           doi - difference of influence terms
%           lld - limit of permuted series (for DOI)
%           mdd - median value of permuted series (for DOI)
%           prd - significance of DOIs

%           waut - Durbin Watson residual autocorrelation sig value
%           cons - MVAR model consistency (Ding et al 2000)
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
%   Updated AKS Aug 2009 to implement whiteness & consistency tests
% COPYRIGHT NOTICE AT BOTTOM
% -----------------------------------------------------------------------

% check inputs
if nargin<8,
     error('error in cca_partialgc_permute: insufficient inputs');
end
if nBwin == Nl & Nr<10,
    disp('Warning in cca_partialgc_permute: perhaps too few trials for effective permuting, reduce nBwin');
end
if mod(Nl,nBwin) ~= 0,
    error('error in cca_partialgc_permute: trial length must be an integer multiple of permute win length');
end
nwin = (Nl*Nr)/nBwin;   % figure number of permutation windows
if ~isint(nwin),
    error('error in cca_partialgc_permute: data length must be an integer multiple of permute win length');
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
CI = 1-pval;

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

% generate permutation resamples
R_perm = zeros(nvar,nvar,nPerm);                % permutation matrix
if DOIFLAG, R_permd = zeros(nvar,nvar,nPerm); end
for ii=1:nPerm,
    XX = genPerm(X,nBwin,nwin,nvar,nobs);
    r2 = cca_partialgc_mtrial(XX,nwin,nBwin,nlags);
    R_perm(:,:,ii) = r2.fg;
    if DOIFLAG==1, 
        R_permd(:,:,ii) = r2.doi; 
    elseif DOIFLAG==2,
        R_permd(:,:,ii) = r2.doifg;
    end
    disp(['done partialgc/doi permutation trial ',num2str(ii),'/',num2str(nPerm)]);
end

% construct confidence intervals
ll = zeros(nvar);
md = zeros(nvar);   % median value for permuted series
if DOIFLAG,
    lld = zeros(nvar);
    mdd = zeros(nvar);  
end
for ii=1:nvar-1,
    for jj=ii+1:nvar,
        if ii~=jj,       
            ll(ii,jj) = quantile(squeeze(R_perm(ii,jj,:)),CI);       
            ll(jj,ii) = quantile(squeeze(R_perm(jj,ii,:)),CI);
            md(ii,jj) = quantile(squeeze(R_perm(ii,jj,:)),0.5);
            md(jj,ii) = quantile(squeeze(R_perm(jj,ii,:)),0.5);
            if DOIFLAG,
                lld(ii,jj) = quantile(squeeze(R_permd(ii,jj,:)),CI);
                lld(jj,ii) = quantile(squeeze(R_permd(jj,ii,:)),CI);
                mdd(ii,jj) = quantile(squeeze(R_permd(ii,jj,:)),0.5);
                mdd(jj,ii) = quantile(squeeze(R_permd(jj,ii,:)),0.5);
            end
        end
    end
end
PR = R_original>ll;              % find significant interactions
if DOIFLAG, 
    PRD = R_origd>lld; 
end

% format output
ret.fg = R_original;
ret.PR = PR;
ret.ll = ll;
ret.md = md;
ret.ci = CI;
ret.waut = r1.waut;
ret.cons = r1.cons;
if DOIFLAG,
    ret.doi = R_origd;
    ret.lld = lld;
    ret.mdd = mdd;
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








     
  
