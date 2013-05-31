function ret = cca_pwcausal_permute(X,Nr,Nl,nlags,nPerm,nBwin,Fs,freq,pval,CORRTYPE)
% -----------------------------------------------------------------------
%   FUNCTION: cca_pwcausal_permute
%   PURPOSE:  spectral granger causality with
%             permutation confidence interval construction
%             (for single trial use Nr=1, Nl = N)
%
%   INPUT:  X           -   nvar (rows) by nobs (cols) observation matrix
%           Nr          -   # realizations
%           Nl          -   length of each realization
%           nlags       -   number of lags to include in model
%           nPerm       -   # permutation resamples
%           nBwin       -   # observations in each window (if Nr>>1, set
%                           nBwin=Nl, then each trial is a separate permute
%                           sample)
%           Fs          -   sampling rate (Hz)
%           freq        -   vector of frequencies to analyze
%           pval        -   desired significance threshold
%           CORRTYPE    -   (0=none,1=Bonferroni,2=approx FDR)
%
%   OUTPUT: GW          -   nvar * nvar * length(freq) spectral granger
%           COH         -   nvar * nvar * length(freq) coherence
%                           (power spectrum is along diagonal)
%           pp          -   power spectrum (as above, provided separately)
%           waut        -   Durbin Watson residual autocorrelation sig value
%           cons        -   MVAR model consistency (Ding et al 2000)
%           ll          -   limit of permuted series
%           ci          -   post-correction confidence interval  (>0)
%           st          -   nvar * nvar significance thresholds 
%           PR          -   nvar*nvar*nfreq binary matrix of significant
%                           interactions
%
%   Based on pwcausal.m 
%
%   AKS Apr 2009
% COPYRIGHT NOTICE AT BOTTOM
% -----------------------------------------------------------------------

% check inputs
if nargin<10,
    error('error in cca_pwcausal_permute: insufficient inputs');
end
if nBwin == Nl & Nr<10,
    disp('warning in cca_pwcausal_permute: perhaps too few trials for effective bootstrapping, reduce nBwin');
end
if mod(Nl,nBwin) ~= 0,
    error('error in cca_pwcausal_permute: trial length must be an integer multiple of permute win length');
end
nwin = (Nl*Nr)/nBwin;   % figure number of bootstrap windows
if ~isint(nwin),
    error('error in pwcausal_permute: data length must be an integer multiple of permute win length');
end

% figure data parameters
nobs = size(X,2);
nvar = size(X,1);

% figure confidence intervals
if CORRTYPE == 1,
    pval = pval/(nvar*(nvar-1));
elseif CORRTYPE == 2, 
     m = nvar*(nvar-1);
     pval = ((m+1)/(2*m))*pval; 
end
CI = 1-pval;

% remove ensemble mean
m = mean(X');
mall = repmat(m',1,nobs);
X = X-mall;

% calculate spectral GC from original data
[GW,COH,pp,waut,cons] = cca_pwcausal(X,Nr,Nl,nlags,Fs,freq,1);
R_original = GW;

% generate permutation resamples
R_perm = zeros(nvar,nvar,length(freq),nPerm);       % permutation matrix (4D)
for ii=1:nPerm,
    XX = genPerm(X,nBwin,nwin,nvar,nobs);
    [gw2,dummy,dummy] = cca_pwcausal(XX,nwin,nBwin,nlags,Fs,freq);
    R_perm(:,:,:,ii) = gw2;    % need a 4D structure here
    disp(['done pwcausal permutation trial ',num2str(ii),'/',num2str(nPerm)]);
end

% identify significance thresholds using method of Blair and Karniski
% (Psychophysiology, 30, 518-524, 1993)
maxgc = zeros(nvar,nvar,nPerm);
st = zeros(nvar,nvar);
for ii=1:nvar-1,
    for jj=ii+1:nvar,
        for kk=1:nPerm,
            vec = squeeze(R_perm(ii,jj,:,kk));
            maxgc(ii,jj,kk) = max(vec);    
            vec = squeeze(R_perm(jj,ii,:,kk));
            maxgc(jj,ii,kk) = max(vec);
        end
        st(ii,jj) = quantile(squeeze(maxgc(ii,jj,:)),CI);
        st(jj,ii) = quantile(squeeze(maxgc(jj,ii,:)),CI);
    end
end

% apply significance thresholds
PR = zeros(nvar,nvar,length(freq));
for ii=1:length(freq)
    X = R_original(:,:,ii);
    Y = X>st;
    PR(:,:,ii) = Y;
end
PR = logical(PR);

% format output
ret.GW = GW;
ret.COH = COH;
ret.pp = pp;
ret.st = st;
ret.ci = CI;
ret.PR = PR;
ret.waut = waut;
ret.cons = cons;



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








