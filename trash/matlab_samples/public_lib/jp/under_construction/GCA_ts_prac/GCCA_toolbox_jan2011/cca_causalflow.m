function [ret] = cca_causalflow(GC,PR)
%-----------------------------------------------------------------------
% FUNCTION: cca_causalflow.m
% PURPOSE:  calculate causal flow given a matrix of Granger causalities
% 
% INPUTS:   GC: nvar by nvar matrix of Granger magnitudes
%           PR: nvar by nvar binary matrix of significant links (optional)
%           (if PR is present, GC will be filtered by PR)
%      
% OUTPUT:   ret.indeg:     only incoming causal influences                         
%           ret.outdeg:    only outgoing causal influences                       
%           ret.flow:      outdeg minus indeg
%           ret.windeg:    as above but weighted                       
%           ret.woutdeg:   as above but weighted                      
%           ret.wflow:     as above but weighted  
%     
%           Written by Anil K Seth, March 2004
%           Updated AKS August 2004
%           Updated AKS December 2005
%           Updated AKS May 2008 for compatability
%           Updated AKS Apr 2009 for new toolbox, no longer uses F stat
%
%           Ref: Seth, A.K. (2005) Network: Comp. Neural. Sys. 16(1):35-55
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

if nargin == 1,     % just the GC matrix
    
    ret.windeg = sum(GC');
    ret.woutdeg = sum(GC);
    ret.wflow = ret.woutdeg-ret.windeg;

else
   
    PR(PR~=0) = 1;  % ensure that all sig connections have value = 1 (Apr 24 2006)
    
    % unweighted
    ret.indeg = sum(PR');
    ret.outdeg = sum(PR);
    ret.flow = ret.outdeg-ret.indeg;
    
    % weighted
    GC(PR==0) = 0;
    ret.windeg = sum(GC');
    ret.woutdeg = sum(GC);
    ret.wflow = ret.woutdeg-ret.windeg;   
end


% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2004-2009) 
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











