function [waut,cons] = cca_mtrial_whitecon(X,Nr,Nl,nlags)
%-----------------------------------------------------------------------
% FUNCTION: cca_mtrial_whitecon.m
% PURPOSE:  wrapper function for cca_whiteness and cca_consistency
%           for multitrial regressions
%
% INPUTS:   X:      nvar (rows) by nobs (cols) observation matrix
%           Nr:     # repetitions (trials)
%           Nl:     length of each trial
%           nlags:  model order
%
% OUTPUT:   waut:  sig value of significant residual autocorrelation
%           cons:  model consistency
%
%           SEE ALSO: cca_whiteness.m, cca_consistency.m
%
%           Seth, A.K. (in preparation), A MATLAB Toolbox for Granger
%           causal connectivity analysis
%-----------------------------------------------------------------------
nobs = size(X,2);
nvar = size(X,1);
waut = zeros(1,nvar);
[Au,Su] = armorf(X,Nr,Nl,nlags);
Au = armorf_to_cca(Au,nvar,nlags);
startinx = 1;
uu = [];    % residuals
xp = [];    % predicted values
for i=1:Nr,
    endinx = startinx+Nl-1;
    if endinx>nobs,
        endinx = nobs;
    end
    XX = X(:,startinx:endinx);
    [u1,xp1] = cca_calc_resid(XX,Au,Nl,nvar,nlags);
    uu = [uu ; u1];
    xp = [xp ; xp1];
    startinx=startinx+Nl;
end

% whiteness test
for ii=1:nvar,
    waut(ii) = cca_whiteness(X,uu(:,ii));
end
% consistency check
[cons] = cca_consistency(X,xp);

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
% along with GCCAtoolbox. If not, see <http://www.gnu.org/licenses/>.
