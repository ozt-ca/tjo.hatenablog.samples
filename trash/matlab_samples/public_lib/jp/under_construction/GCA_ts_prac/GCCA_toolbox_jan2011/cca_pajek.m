function cca_pajek(PR,GC,fname,nodenames)
%-----------------------------------------------------------------------
% FUNCTION: cca_pajek.m
% PURPOSE:  create Pajek readable file
% 
% INPUTS:   PR:     nvar by nvar binary matrix of significant links
%           GC:     corresponding matrix of magnitudes  (optional)
%           fname:  filename (use .net extension)
%           nodenames: labels for nodes (optional)
%         
% OUTPUT:   fname.net file readable by Pajek program
%           http://vlado.fmf.uni-lj.si/pub/networks/pajek/
%     
%           Written by Anil K Seth, December 2005
%           Updated AKS May 2008
%           updated AKS apr 01 2009 to deal with ratio magnitude
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

nvar = length(PR);
% check input
if(nargin == 1)
    GC = ones(nvar);
    fname = 'demo.net';
    nodenames = [1:nvar];
elseif(nargin == 2)
    fname = 'demo.net';
    nodenames = [1:nvar];
elseif(nargin == 3)
    nodenames = [1:nvar];
end

% create file
netfile = fopen(fname,'wt');

% write nodes
vstr = ['*vertices ',num2str(nvar)];
fprintf(netfile,'%s\n',vstr);
for i=1:nvar
    if(~isstr(nodenames(i)))
        temp = num2str(nodenames(i));
    else 
        temp = nodenames{i};
    end
    fprintf(netfile,'%d%s%s%s%s%s\n',i,' "',temp,'" ic ','Blue',' x_fact 1.5 y_fact 1.5');
end

% write arcs
fprintf(netfile,'%s\n','*arcs');
for i=1:nvar
    for j=1:nvar
        v = GC(i,j);
        if(v~=0)
            fprintf(netfile,'%d %d %.4f\n',j,i,v);
        end
    end
end
fclose(netfile);

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

