function [PR,q] = cca_findsignificance_autonomy(ret,pval,CFLAG)
%-----------------------------------------------------------------------
% FUNCTION: cca_findsignificance_autonomy.m
% PURPOSE:  calculate significant Granger autonomies
% 
% INPUTS:   ret:    output of cca_autonomy_regress.m
%           pval:   desired P-value threshold
%           CFLAG:  0 = no correction, 1 = Bonferroni, 2 = false discovery
%                   rate, 3 = approx false discovery rate (see ref below)
%
% OUTPUT:   PR:    nvar by nvar matrix of 1s (sig connections)
%           q:     threshold used (=pval for no correction) 
%
%           Written by Anil K Seth, Apr 2009 (based on
%           cca_findsignificance.m)
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

prb = ret.prb;
nvar = length(prb);
PR = zeros(nvar,1);

if CFLAG == 0,   % no correction
    
    PR(prb<pval) = 1;
    q = pval;

elseif CFLAG == 1, % Bonferroni correction
    
    q = pval/(nvar-1);
    PR(prb<q) = 1;
    
elseif CFLAG == 2, %  false discovery rate (assuming independent null hypotheses)

    temp = prb(:);
    p = sort(temp);
    q = pval;
    V = length(p);
    I = (1:V)';
    cVID = 1;
    cVN = sum(1./(1:V));
    pID = p(max(find(p<=I/V*q/cVID)));  % independent or positive dependent
    pN = p(max(find(p<=I/V*q/cVN)));    % nonparametric
    PR(prb<pID) = 1;    % use independent or +ve
    
    q = pID;

elseif CFLAG == 3, % 'rough' false discovery rate (RFDR), based on average alpha
    
    m = nvar-1;
    q = ((m+1)/(2*m))*pval;
    
    PR(prb<q) = 1;
 
end

PR = PR';
            
% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2007-2009) 
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
      

        





