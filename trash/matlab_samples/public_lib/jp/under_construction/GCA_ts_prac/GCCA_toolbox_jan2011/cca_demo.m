function cca_demo(DEMO)
%-----------------------------------------------------------------------
% FUNCTION: cca_demo.m
% PURPOSE:  demonstrate causal connectivity analysis toolbox
%
% INPUTS:   1   -   dataset from Baccala, L. A. & Sameshima, K. 2001
%           2   -   dataset from Schelter et al. 2006
%
% OUTPUT:   graphical output
%           file 'demo[1,2].net' for Pajek program
%           (see vlado.fmf.uni-lj.si/pub/networks/pajek/)
%
%           Written by Anil K Seth, December 2005
%           Updated April 2009 AKS
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

%   demo parameters
N       =   2000;       % number of observations
PVAL    =   0.01;       % probability threshold for Granger causality significance
NLAGS   =   -1;         % if -1, best model order is assessed automatically
Fs      =   500;        % sampling frequency  (for spectral analysis only)
freqs   =   [1:100];    % frequency range to analyze (spectral analysis only)

%   add toolbox filepaths
%ccaStartup;

% acquire demo data
if nargin == 0,
    DEMO = 1;
end
X = cca_testData(N,DEMO);
sfile = ['ccademo.',num2str(DEMO),'.net'];
nvar = size(X,1);

% detrend and demean data
disp('detrending and demeaning data');
X = cca_detrend(X);
X = cca_rm_temporalmean(X);

% check covariance stationarity
disp('checking for covariance stationarity ...');
uroot = cca_check_cov_stat(X,10);
inx = find(uroot);
if sum(uroot) == 0,
    disp('OK, data is covariance stationary by ADF');
else
    disp('WARNING, data is NOT covariance stationary by ADF');
    disp(['unit roots found in variables: ',num2str(inx)]);
end

% check covariance stationarity again using KPSS test
[kh,kpss] = cca_kpss(X);
inx = find(kh==0);
if isempty(inx),
    disp('OK, data is covariance stationary by KPSS');
else
    disp('WARNING, data is NOT covariance stationary by KPSS');
    disp(['unit roots found in variables: ',num2str(inx)]);
end
    
% find best model order
if NLAGS == -1,
    disp('finding best model order ...');
    [bic,aic] = cca_find_model_order(X,2,12);
    disp(['best model order by Bayesian Information Criterion = ',num2str(bic)]);
    disp(['best model order by Aikaike Information Criterion = ',num2str(aic)]);
    NLAGS = aic;
end

%-------------------------------------------------------------------------
% analyze time-domain granger

% find time-domain conditional Granger causalities [THIS IS THE KEY FUNCTION]
disp('finding conditional Granger causalities ...');
ret = cca_granger_regress(X,NLAGS,1);   % STATFLAG = 1 i.e. compute stats

% check that residuals are white
dwthresh = 0.05/nvar;    % critical threshold, Bonferroni corrected
waut = zeros(1,nvar);
for ii=1:nvar,
    if ret.waut<dwthresh,
        waut(ii)=1;
    end
end
inx = find(waut==1);
if isempty(inx),
    disp('All residuals are white by corrected Durbin-Watson test');
else
    disp(['WARNING, autocorrelated residuals in variables: ',num2str(inx)]);
end

% check model consistency, ie. proportion of correlation structure of the
% data accounted for by the MVAR model
if ret.cons>=80,
    disp(['Model consistency is OK (>80%), value=',num2str(ret.cons)]);
else
    disp(['Model consistency is <80%, value=',num2str(ret.cons)]);
end
        
% analyze adjusted r-square to check that model accounts for the data (2nd
% check)
rss = ret.rss_adj;
inx = find(rss<0.3);
if isempty(inx)
    disp(['Adjusted r-square is OK: >0.3 of variance is accounted for by model, val=',num2str(mean(rss))]);
else
    disp(['WARNING, low (<0.3) adjusted r-square values for variables: ',num2str(inx)]);
    disp(['corresponding values are ',num2str(rss(inx))]);
    disp('try a different model order');
end

% find significant Granger causality interactions (Bonferonni correction)
[PR,q] = cca_findsignificance(ret,PVAL,1);
disp(['testing significance at P < ',num2str(PVAL), ', corrected P-val = ',num2str(q)]);

% extract the significant causal interactions only
GC = ret.gc;
GC2 = GC.*PR;

% calculate causal connectivity statistics
disp('calculating causal connectivity statistics');
causd = cca_causaldensity(GC,PR);
causf = cca_causalflow(GC,PR);

disp(['time-domain causal density = ',num2str(causd.cd)]);
disp(['time-domain causal density (weighted) = ',num2str(causd.cdw)]);

% create Pajek readable file
cca_pajek(PR,GC,sfile);

%-------------------------------------------------------------------------
% plot time-domain granger results
figure(1); clf reset;
FSIZE = 8;
colormap(flipud(bone));

% plot raw time series
for i=2:nvar,
    X(i,:) = X(i,:)+(10*(i-1));
end
subplot(231);
set(gca,'FontSize',FSIZE);
plot(X');
axis('square');
set(gca,'Box','off');
xlabel('time');
set(gca,'YTick',[]);
xlim([0 N]);
title('Causal Connectivity Toolbox v2.0');

% plot granger causalities as matrix
subplot(232);
set(gca,'FontSize',FSIZE);
imagesc(GC2);
axis('square');
set(gca,'Box','off');
title(['Granger causality, p<',num2str(PVAL)]);
xlabel('from');
ylabel('to');
set(gca,'XTick',[1:N]);
set(gca,'XTickLabel',1:N);
set(gca,'YTick',[1:N]);
set(gca,'YTickLabel',1:N);

% plot granger causalities as a network
subplot(233);
cca_plotcausality(GC2,[],5);

% plot causal flow  (bar = unweighted, line = weighted)
subplot(234);
set(gca,'FontSize',FSIZE);
set(gca,'Box','off');
mval1 = max(abs(causf.flow));
mval2 = max(abs(causf.wflow));
mval = max([mval1 mval2]);
bar(1:nvar,causf.flow,'m');
ylim([-(mval+1) mval+1]);
xlim([0.5 nvar+0.5]);
set(gca,'XTick',[1:nvar]);
set(gca,'XTickLabel',1:nvar);
title('causal flow');
ylabel('out-in');
hold on;
plot(1:nvar,causf.wflow);
axis('square');

% plot unit causal densities  (bar = unweighted, line = weighted)
subplot(235);
set(gca,'FontSize',FSIZE);
set(gca,'Box','off');
mval1 = max(abs(causd.ucd));
mval2 = max(abs(causd.ucdw));
mval = max([mval1 mval2]);
bar(1:nvar,causd.ucd,'m');
ylim([-0.25 mval+1]);
xlim([0.5 nvar+0.5]);
set(gca,'XTick',[1:nvar]);
set(gca,'XTickLabel',1:nvar);
title('unit causal density');
hold on;
plot(1:nvar,causd.ucdw);
axis('square');

%-------------------------------------------------------------------------
% analyze frequency-domain granger

SPECTHRESH = 0.2.*ones(1,length(freqs));    % bootstrap not used in this demo

% find pairwise frequency-domain Granger causalities [KEY FUNCTION]
disp('finding pairwise frequency-domain Granger causalities ...');
[GW,COH,pp]=cca_pwcausal(X,1,N,NLAGS,Fs,freqs,0);

% calculate freq domain causal connectivity statistics
disp('calculating causal connectivity statistics');
causd = cca_causaldensity_spectral(GW,SPECTHRESH);
causf = cca_causalflow_spectral(GW,SPECTHRESH);

totalcd = sum(causd.scdw);
disp(['freq-domain causal density (weighted) = ',num2str(totalcd)]);

%-------------------------------------------------------------------------
% plot frequency-domain granger results
figure(2); clf reset;
FSIZE = 8;
colormap(flipud(bone));

% plot fft for each variable
ct = 1;
for i=1:nvar,
    subplot(3,nvar,ct);
    cca_spec(X(i,:),Fs,1);
    title(['v',num2str(i)]);
    if i==1,
        ylabel('fft: amplitude');
    end
    ct = ct+1;
    set(gca,'Box','off');
end

% plot causal density spectrum for each variable
for i=1:nvar,
    subplot(3,nvar,ct);
    plot(causd.sucdw(i,:));
    if i==1,
        ylabel('unit cd');
    end
    ct = ct+1;
    set(gca,'Box','off');
end

% plot causal flow spectrum for each variable
for i=1:nvar,
    subplot(3,nvar,ct);
    plot(causf.swflow(i,:));
    if i==1,
        ylabel('unit flow');
    end
    ct = ct+1;
    set(gca,'Box','off');
end

% plot network causal density
figure(3); clf reset;
plot(causd.scdw);
set(gca,'Box','off');
title(['spectral cd, total=',num2str(totalcd),', thresh=',num2str(SPECTHRESH)]);
xlabel('Hz');
ylabel('weighted cd');

% plot causal interactions
figure(4); clf reset;
cca_plotcausality_spectral(GW,freqs);

% plot coherence
figure(5); clf reset;
cca_plotcoherence(COH,freqs);


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


