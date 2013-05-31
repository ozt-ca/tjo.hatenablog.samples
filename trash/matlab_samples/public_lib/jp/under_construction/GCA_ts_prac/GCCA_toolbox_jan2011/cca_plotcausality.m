function cca_plotcausality(M,nodenames,sfac);
%-----------------------------------------------------------------------
% FUNCTION: cca_plotcausality.m
% PURPOSE:  plot causal connectivity given a matrix of Granger causalities
% 
% INPUTS:   M:  log ratio Granger causalities, NaN for nonsig values
%           nodename: vector of node labels (optional)
%           sfac:  scaling factor for linewidth (optional)
%
% OUTPUT:   none
%          
%           Written by Anil K Seth, March 2004
%           Updated AKS August 2004
%           Updated AKS December 2005
%           Updated AKS February 2009
%           Ref: Seth, A.K. (2005) Network: Comp. Neural. Sys. 16(1):35-55
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

nvar = length(M);

% check input
if nargin == 2,
    sfac = 1;
elseif nargin == 1,
    nodenames = [];
end

%   parse input
if(isempty(nodenames)),
    for i=1:nvar,
        nodenames{i} = num2str(i);
    end
end
if nargin < 3,
    sfac = 1;
end
hold off;

% replace bad values with 0
M(isnan(M)) = 0;
M(isinf(M)) = 0;
M(M<0) = 0;

% plot nodes
set(gca,'XTickLabel',[]);
angle = (2*pi)/nvar;
X = zeros(nvar,1); Y = zeros(nvar,1);
for i=1:nvar
    X(i) = cos(angle*(i-1));
    Y(i) = sin(angle*(i-1));
end
for i=1:nvar
    h=plot(X(i),Y(i),'.');
    set(h,'Color','k');
    set(h,'MarkerSize',8);
    hold on;
end
XX=X*1.1;
YY=Y*1.1;

% find reciprocal edges
temp = M.*M';
[toinx,frominx] = find(temp);
R = [toinx frominx];
for i=1:length(toinx),
    xf = X(frominx(i)); yf = Y(frominx(i));
    xt = X(toinx(i)); yt = Y(toinx(i));
    h = line([xf xt],[yf yt]);
    set(h,'LineWidth',M(toinx(i),frominx(i)).*sfac);
    set(h,'Color',[1 0 0]); % red for reciprocal edge   
end
% label nodes
for i=1:nvar
    if(isempty(nodenames))
        h=text(XX(i),YY(i),num2str(i));
    else
        h=text(XX(i),YY(i),nodenames{i});
    end
    set(h,'FontSize',14);
end

% find non-reciprocal edges
[x2,y2] = find(M);
nonR = [x2 y2];
nonR = setdiff(nonR,R,'rows');
toinx = nonR(:,1);
frominx = nonR(:,2);
for i=1:length(toinx),
    xf = X(frominx(i)); yf = Y(frominx(i));
    xt = X(toinx(i)); yt = Y(toinx(i));
    h = line([xf xt],[yf yt]);
    set(h,'LineWidth',M(toinx(i),frominx(i)).*sfac);
    set(h,'Color',[0 1 0]); % green for non-recip edges
    cca_arrowh([xf (xf+xt)/2 ],[yf (yf+yt)/2],'g',400,50);
end

set(gca,'Box','off');
axis('square');
axis off;

xlim([-1.4 1.4]);
ylim([-1.4 1.4]);

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