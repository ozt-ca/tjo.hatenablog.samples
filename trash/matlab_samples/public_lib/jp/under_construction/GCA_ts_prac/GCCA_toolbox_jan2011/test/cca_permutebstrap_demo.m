function cca_permutebstrap_demo(GENFLAG)
%-----------------------------------------------------------------------
% FUNCTION: cca_permutebstrap_demo.m
% PURPOSE:  demonstrate bootstrapping and permutation functions
%
% INPUTS:   GENFLAG=0: use preexisiting data to plot (default)
%           GENFLAG=1: generate new data from Baccala & Sameshima (2001)
%           GENFLAG=2: generate new data from double bivariate model
%
% OUTPUT:   graphical output
%           datafile permutebstrapdemo.mat
%    
%           Written by Anil K Seth, April 2009
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

% check input
if nargin<1,
    GENFLAG = 0;
end

% set parameters
N = 2000;
Nr = 2;
Nl = N/2;
nBoot = 500;
nBwin = 50;
nlags = 5;
freq = 1:100;
Fs = 500;
pval = 0.05;
CORRTYPE = 1;   % Bonferroni

if GENFLAG == 0,
    load('permutebstrapdemo.mat');
else,
    % generate data
    if GENFLAG == 1,
        X = cca_testData(N,1);
    elseif GENFLAG == 2,
        X = cca_testData(N,4);
    else
        error('cca_permutebstrap_demo: specify data to use');
    end

    % perform time-domain analyses
    % (here we use permutation and bootstrap to compute partial Granger)
    ret1 = cca_partialgc_doi_permute(X,Nr,Nl,nlags,nBoot,nBwin,pval,CORRTYPE,1);
    ret2 = cca_partialgc_doi_bstrap(X,Nr,Nl,nlags,nBoot,nBwin,pval,CORRTYPE,1);
    
    % perform frequency domain analyses
    ret3 = cca_pwcausal_permute(X,Nr,Nl,nlags,nBoot,nBwin,Fs,freq,pval,CORRTYPE);
    ret4 = cca_pwcausal_bstrap(X,Nr,Nl,nlags,nBoot,nBwin,Fs,freq,pval,CORRTYPE);

    save permutebstrapdemo3.mat X ret1 ret2 ret3 ret4;
end

nvar = size(X,1);

% plot time domain analyses
figure(1); clf reset;   % permutation
set(gca,'FontSize',10);
colormap(flipud(bone));
vec1 = reshape(ret1.fg,1,nvar*nvar);
vec2 = reshape(ret1.ll,1,nvar*nvar);
subplot(221);
hold on;
plot(vec1);
plot(vec2,'r');
title('Permutation demo');
xlabel('interaction');
ylabel('value with threshold');
subplot(222);
sfg = ret1.fg;
sfg(ret1.PR==0) = 0;
cca_plotcausality(sfg,[]);
subplot(223);
imagesc(ret1.fg);
title('partial Granger');
axis('square');
jicolorbar;
subplot(224)
imagesc(ret1.PR);
title('Significance matrix');
axis('square');
jicolorbar;
set(gca,'FontSize',10);

figure(2); clf reset;   % bootstrap
set(gca,'FontSize',10);
colormap(flipud(bone));
vec1 = reshape(ret2.fg,1,nvar*nvar);
vec2 = reshape(ret2.ll,1,nvar*nvar);
vec3 = reshape(ret2.ul,1,nvar*nvar);
subplot(221);
hold on;
plot(vec1);
plot(vec2,'g');
plot(vec3,'r');
title('Boostrap demo');
xlabel('interaction');
ylabel('value with CIs');
subplot(222);
sfg = ret1.fg;
sfg(ret1.PR==0) = 0;
cca_plotcausality(sfg,[]);
subplot(223);
imagesc(ret1.fg);
title('partial Granger');
axis('square');
jicolorbar;
subplot(224)
imagesc(ret1.PR);
title('Significance matrix');
axis('square');
set(gca,'FontSize',10);

% plot frequency domain analyses
figure(3); clf reset; % permutation
cca_plotcausality_spectral(ret3.GW,1:100,ret3.st);

figure(4); clf reset; % bootstrap
cca_plotcausality_spectral(ret4.GW,freq,ret4.ll,ret4.ul);

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

