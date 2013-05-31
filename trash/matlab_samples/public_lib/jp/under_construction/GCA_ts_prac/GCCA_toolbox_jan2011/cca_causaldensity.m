function [ret] = cca_causaldensity(GC,PR)
%-----------------------------------------------------------------------
% FUNCTION: cca_causaldensity.m
% PURPOSE:  calculate causal density given a matrix of Granger causalities
% 
% INPUTS:   GC: nvar by nvar matrix of Granger magnitudes
%           PR: nvar by nvar binary matrix of significant links (optional)
%           (if PR is present, GC will be filtered by PR)
%
% OUTPUT:   ret.cd:     causal density (bounded in range 0:1)
%           ret.cdw:    causal density weighted by  magnitude (not bounded)
%           ret.ucd:    vector of causal densities (per node)
%           ret.ucdw:   as above but weighted     
%
%           Written by Anil Seth, March 2004
%           Updated August 2004 AKS
%          
%           Ref: Seth, A.K. (2005) Network: Comp. Neural. Sys. 16(1):35-55
%
%           updated Apr 24 2006 AKS, to ensure that all sig connections = 1
%           updated May 28 2008 AKS, for compatability
%           updated April 2009 AKS, add ucd/ucdw outputs, reorganize I/O
%               structure
%   COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

nvar = length(GC);
if nargin == 1,     % just GC matrix
    
    ret.cd = -1;
    ret.cdw = sum(sum(GC))/(nvar*(nvar-1));
    ret.ucd = -1;
    ret.ucdw = (sum(GC)/nvar) + ((sum(GC'))/nvar);
    
else                % filter by significance
    
    PR(PR~=0) = 1;  % ensure that all sig connections have value = 1
    ret.cd = sum(sum(PR))/(nvar*(nvar-1));
    ret.ucd = (sum(PR)/nvar) + ((sum(PR'))/nvar);
    GC(PR==0)=0;
    ret.cdw = sum(sum(GC))/(nvar*(nvar-1));
    ret.ucdw = (sum(GC)/nvar) + ((sum(GC'))/nvar);
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









