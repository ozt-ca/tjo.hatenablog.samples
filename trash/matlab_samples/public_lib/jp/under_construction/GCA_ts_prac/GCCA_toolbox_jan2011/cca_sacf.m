function [rho,bigY] = cca_sacf(y,m,gflag)
% -----------------------------------------------------------------------
% FUNCTION: cca_sacf.m
% PURPOSE:  find sample autocorrelation coefficients 
% 
% INPUTS:   y = a time-series (need not have mean zero)
%           m = # of sample autocorrelations to compute
%           gflag = 0, flag for graphing, 1 = no graph
%                   (default = 0, a graph is produced)
% OUTPUT:
%           p = an m x 1 vector of sample acf's
%           also plots sample acf's with 2-sigma intervals
%           if gflag == 1
%
% Originally from the JPL toolbox
% Vectorized by Kevin Sheppard
% Updated by Anil Seth, December 2005
%   COPYRIGHT NOTICE AT BOTTOM
% -----------------------------------------------------------------------
   
if nargin == 2
    flag = 0;
elseif nargin == 3
    flag = gflag;
else
    error('Wrong # of arguments to cca_sacf');
end;

if(size(y,2) > 1) y=y'; end

n = length(y);
rho = zeros(m,1);
npm = n+m;
tmp = std(y);
vary = tmp*tmp;

% put y in deviations from mean form
ym = mean(y);
e = zeros(n,1);
e(1:n,1) = y - ones(n,1)*ym;
bigY=repmat([1:n]',2*(m+1),1);
bigY=bigY(1:(2*n-1)*(m+1));
bigY=reshape(bigY,2*n-1,m+1);
bigY=bigY(1:n,2:m+1);
bigY=y(bigY);

E=repmat(e,1,m);
rho=(sum(E.*bigY)/(n*vary))';

ul = 2*(1/sqrt(n)*ones(m,1));
ll = -2*(1/sqrt(n)*ones(m,1));

if flag == 1,
    bar(rho);
    %title('Sample autocorrelation coefficients');
    xlabel('lags');
    ylabel('sacf');
    hold on;
    tt=1:m;
    plot(tt,ul,'*r',tt,ll,'*r');
    hold off;
end;


% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2005) and Kevin Sheppard
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


