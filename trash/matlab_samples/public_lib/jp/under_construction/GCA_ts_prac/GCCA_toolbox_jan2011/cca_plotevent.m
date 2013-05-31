function cca_plotevent(X,Nr,Nl);
%-----------------------------------------------------------------------
% FUNCTION: cca_plotevent.m
% PURPOSE:  plot multitrial raw data  (1 panel per channel)
% 
% INPUTS:   X:  data matrix
%           Nr: number of trials
%           Nl: trial length
%
% OUTPUT:   none
%          
%           Written by Anil K Seth, December 2009
%           Ref: Seth, A.K. (2010) J. Neurosci. Meth
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

clf reset;
nvar = size(X,1);
[nx,ny] = cca_calcPanels(nvar);

% reshape
offset = 1;
for ii=1:Nr,
    xx{ii} = X(:,offset:offset+Nl-1);
    offset = offset+Nl;
end

% plot 
for jj=1:nvar,
    subplot(nx,ny,jj); hold on;
    XX = zeros(Nr,Nl);
    for ii=1:Nr,
        vec = xx{ii}(jj,:);
        XX(ii,:) = vec;
        h=plot(vec); hold on;
        set(h,'Color',[0.8 0.8 0.8]);
    end
    m = mean(XX);
    h=plot(m);
    set(h,'LineWidth',2);
    title(['var ',num2str(jj)]);
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