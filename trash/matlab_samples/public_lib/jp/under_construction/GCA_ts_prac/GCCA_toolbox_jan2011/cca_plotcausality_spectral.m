function cca_plotcausality_spectral(M,freqs,c1,c2)
%-----------------------------------------------------------------------
% FUNCTION: cca_plotcausality_spectral.m
% PURPOSE:  plot causal connectivity given a matrix of Granger causalities
%           modified to plot spectral GC in various freq bands
%
% INPUTS:   M               -   log ratio Granger causalities
%                               (nvar * nvar * freq)
%           freqs           -   vector of frequencies in M (3rd dimension)
%           c1,c2           -   (optional) matrices of significance
%                               thresholds: c1 only for permutation,
%                               c1 and c2 for bootstrap
%
% OUTPUT:   Graphical.  Spectral causality is shown in blue.  If confidence
%           intervals they are shown in red(low) and green(high) for
%           boostrap, or red for permutation.  Statistically significant
%           regions have a yellow shading behind the blue line.
%
%           AKS April 2009
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

% check inputs
if nargin<2,
    error('at least 2 inputs needed to cca_plotcausality_spectral.m');
elseif nargin == 2,
    STFLAG = 0;
elseif nargin == 3,
    STFLAG = 1; % permutation
elseif nargin == 4,
    STFLAG = 2; % bstrap
end

% replace -999 with 0
M(M==-999) = 0;
nvar = size(M,1);

% set up graphics
clf reset;
ct = 1;
for ii=1:nvar,
    for jj=1:nvar,
        inx(ii,jj) = ct;
        ct = ct+1;
    end
end

% plot out causality
for ii=1:nvar,
    for jj=1:nvar,
        if ii ~= jj,
            pinx = inx(ii,jj);
            subplot(nvar,nvar,pinx);
            hold on;

            % find limits and collate data
            vec = squeeze(M(ii,jj,:));
            if STFLAG==0, % no statistics
                ymax = max(vec);
                ymin = min(vec);
            elseif STFLAG==1, % permutation
                ymax = max(vec);
                ymin = min([min(vec) c1(ii,jj)]);
                statinx = find(vec>c1(ii,jj));
            elseif STFLAG==2, % bstrap
                c1vec = squeeze(c1(ii,jj,:));
                c2vec = squeeze(c2(ii,jj,:));
                ymax = max([max(c1vec) max(c2vec)]);
                ymin = min([min(c1vec) min(c2vec)]);
                if mean(c1vec)>mean(c2vec),
                    statinx = find(c2vec>0);
                else
                    statinx = find(c1vec>0);
                end
            end
            ymax = ymax+0.1;
            ymin = ymin-0.1;
            ylim([ymin ymax]);
            ylim([0 1]);

            % plot data
            if STFLAG==0, % no statistics
                h=plot(freqs,vec,'b');
                set(h,'LineWidth',2);
            elseif STFLAG==1, % permutation
                h=plot(freqs(statinx),vec(statinx));
                set(h,'LineWidth',8);
                set(h,'Color',[1 1 0]);
                h=plot(freqs,vec,'b');
                set(h,'LineWidth',2);
                h=line([0 length(freqs)],[c1(ii,jj) c1(ii,jj)]);
                set(h,'Color','r');
            elseif STFLAG==2, % bstrap
                h=plot(freqs(statinx),vec(statinx));
                set(h,'LineWidth',8);
                 set(h,'Color',[1 1 0]);
                h=plot(freqs,vec,'b');
                set(h,'LineWidth',2);
                plot(freqs,squeeze(c1(ii,jj,:)),'r');
                plot(freqs,squeeze(c2(ii,jj,:)),'g');
            end

            % label and finalize
            set(gca,'Box','off');
            set(gca,'FontSize',8);
            if (ii==nvar),
                xlabel(['from=',num2str(jj)]);
            end
            if (jj==1),
                ylabel(['to=',num2str(ii)]);
            end
        end
    end
end

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
