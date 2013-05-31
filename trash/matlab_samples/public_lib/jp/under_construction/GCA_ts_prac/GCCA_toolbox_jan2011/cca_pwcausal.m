function [GW,COH,pp,waut,cons]=cca_pwcausal(X,Nr,Nl,nlags,Fs,freq, STATFLAG)
% -----------------------------------------------------------------------
%   FUNCTION: cca_pwcausal.m
%   PURPOSE:  perform spectral Granger causality following
%             the method of Geweke - this function implements pairwise
%             only!
%             THIS FUNCTION NOW SERVES AS A WRAPPER TO THE BSMART PWCAUSAL
%
%   INPUT:  X           -   nvar (rows) by nobs (cols) observation matrix
%           nlags       -   number of lags to include in model
%           Nr          -   # of realizations
%           Nl          -   length of each realization
%           Fs          -   sampling rate (Hz)
%           freq        -   vector of frequencies to analyze
%           STATFLAG    -   comput Durbin Watson / consistency (1) or not (0)
%
%   OUTPUT: GW          -   nvar * nvar * length(freq) spectral granger
%           COH         -   nvar * nvar * length(freq) coherence
%                           (power spectrum is along diagonal)
%           pp          -   power spectrum (as above, provided separately)
%           waut        -   Durbin Watson residual autocorrelation sig
%                           value
%           cons        -   MVAR model consistency (Ding et al 2000)
%
%   This function is due to Yonghong Chen (2003), modified by AKS
%
%   NOTE:  statistical distribution for spectral granger is not known,
%   use surrogate data methods
%   NOTE:  this function is suitable for multitrial data
%
%   REF: Geweke, J. 1982 Measurement of linear dependence and feedback between 
%   multiple time series. Journal of the American Statistical Association 77, 304-313.  
%   REF: Ding, M., Chen, Y. & Bressler, S. L. 2006 Granger causality: Basic
%   theory and application to neuroscience. In Handbook of Time Series Analysis 
%   (ed. S. Schelter, M. Winterhalder & J. Timmer), pp. 438-460. Wienheim: Wiley.
%
%   AKS Apr 02 2009
%   Updated AKS Aug 2009 to implement whiteness & consistency tests
%   Updated AKS Dec 07 2009 minor bug fix in function call to armorf_to_cca
% COPYRIGHT NOTICE AT BOTTOM
% -----------------------------------------------------------------------
if nargin<7,
    STATFLAG = 1;
end

[L,N]=size(X); %L is the number of channels, N is the total points in every channel
[pp,cohe,Fx2y,Fy2x]=pwcausal(X,Nr,Nl,nlags,Fs,freq); %this function available from www.brain-smart.org

% put into square matrix format 
GW = single(ones(L,L,length(freq)).*-999);  % causality
COH = single(ones(L,L,length(freq)).*-999); % coherence
ct = 1;
for i=1:L-1,
    for j=i+1:L,
        GW(i,j,:) = single(Fy2x(ct,:));
        GW(j,i,:) = single(Fx2y(ct,:));
        ct = ct +1;
    end
end
COH = cohe;
for i=1:L,
    COH(i,i,:) = pp(i,:);    % set diagonal to power spectrum
end
COH = single(COH);
pp = single(pp);

% check residual autocorrelation and consistency
% if needed (see cca_mtrial_whitecon.m - part of function repeated here to 
% save an additional ARMORF regression step)
if STATFLAG,
    nvar = L; nobs = N;
    A = armorf_to_cca(X,nvar,nlags);
    startinx = 1;
    uu = []; xp = [];
    for i=1:Nr,
        endinx = startinx+Nl-1;
        if endinx>nobs,
            endinx = nobs;
        end
        XX = X(:,startinx:endinx);
        [u1,xp1] = cca_calc_resid(XX,A,Nl,nvar,nlags);
        uu = [uu ; u1];
        xp = [xp ; xp1];
        startinx=startinx+Nl;
    end
    for ii=1:nvar,
        waut(ii) = cca_whiteness(X,uu(:,ii));
    end
    cons = cca_consistency(X,xp);   % consistency check
else
    waut = -1;
    cons = -1;
end

% This file is copyright (C) Anil Seth (2009)
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


