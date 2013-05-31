function [PR,q] = cca_findsignificance(ret,pval,CFLAG)
%-----------------------------------------------------------------------
% FUNCTION: cca_findsignificance.m
% PURPOSE:  calculate significant Granger causalities
% 
% INPUTS:   ret:    output of cca_granger_regress.m (or similar)
%           pval:   desired P-value threshold
%           CFLAG:  0 = no correction, 1 = Bonferroni, 2 = false discovery
%                   rate, 3 = approx false discovery rate (see ref below)
%
% OUTPUT:   PR:    nvar by nvar matrix of 1s (sig connections)
%           q:     threshold used (=pval for no correction) 
%
%           Written by Anil K Seth, December 2005
%           Updated May 28, 2008
%           Updated Apr 2009 AKS, to return only sig connections
%           Ref: Seth, A.K. (2005) Network: Comp. Neural. Sys. 16(1):35-55
%           Ref: Benjamini, Yoav; Hochberg, Yosef (1995):
%           "Controlling the false discovery rate: a practical and powerful approach 
%           to multiple testing". Journal of the Royal Statistical Society, 
%           Series B (Methodological) 57 (1): 289–300. 
%           FDR code adapted from: http://www.sph.umich.edu/~nichols/FDR/
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

prb = ret.prb;
nvar = length(prb);
PR = zeros(nvar);

if CFLAG == 0,   % no correction
    
    PR(prb<pval) = 1;
    q = pval;

elseif CFLAG == 1, % Bonferroni correction
    
    q = pval./(nvar*(nvar-1));
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
    % BUG FIX Nov 02
    if isempty(pID),
        pID = -100;
    end
    % END BUG FIX Nov 02
    PR(prb<pID) = 1;    % use independent or +ve
    
    q = pID;

elseif CFLAG == 3, % 'rough' false discovery rate (RFDR), based on average alpha
    
    m = nvar*(nvar-1);
    q = ((m+1)/(2*m))*pval;
    
    PR(prb<q) = 1;
 
else
    error('CFLAG must be 1-3, in cca_findsignificance.m');
end
            
        
% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2007-2009) and Thomas Nichols
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
     





