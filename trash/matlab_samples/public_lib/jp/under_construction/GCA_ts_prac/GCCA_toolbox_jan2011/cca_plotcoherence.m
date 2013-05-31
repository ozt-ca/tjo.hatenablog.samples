function cca_plotcoherence(COH,freqs,varargin)
%-----------------------------------------------------------------------
% FUNCTION: cca_plotcoherence.m
% PURPOSE:  plot coherence (takes output of pwcausal.m or pwcausalcond.m)
%           also plots power spectra along the diagonal
%
% INPUTS:   COH             -   coherence values (power on diagonal)
%                               (nvar * nvar * freq)
%           freqs           -   vector of frequencies in M (3rd dimension)
%
% OUTPUT:   none
%
%           AKS April 09 2009
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

if nargin<2,
    error('at least 2 inputs needed to cca_plotcausality_spectral2.m');
end

PSCALEFAC = 10;     % scale factor to make power visible on the figure, adjust as needed

% replace -999 with 0
COH(COH==-999) = 0;
nvar = size(COH,1);

% scale up power
for i=1:nvar,
    COH(i,i) = COH(i,i).*PSCALEFAC;
end

% set up graphics
clf reset;
ct = 1;
for ii=1:nvar,
    for jj=1:nvar,
        inx(ii,jj) = ct;
        ct = ct+1;
    end
end

% plot out coherence and power
for ii=1:nvar,
    for jj=1:nvar,
        pinx = inx(ii,jj);
        subplot(nvar,nvar,pinx);
        vec = squeeze(COH(ii,jj,:));
        if ii==jj,
            plot(freqs,vec,'r');    % power in red
        else
            plot(freqs,vec);        % coherence in blue
        end
        ylim([0 1]);
        set(gca,'Box','off');
        set(gca,'FontSize',8);
        if (ii==nvar),
            xlabel([num2str(jj)]);
        end
        if (jj==1),
            ylabel([num2str(ii)]);
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
% along with GCCAtoolbox.  If not, see <http://www.gnu.org/licenses/>.
