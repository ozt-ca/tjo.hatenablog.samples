function [bic,aic] = cca_find_model_order(X,MINP,MAXP)
%-----------------------------------------------------------------------
% FUNCTION: cca_find_model_order.m
% PURPOSE:  use the Bayesian Information Criterion (BIC) and/or the Aikaike
%           Information Criterion to find the best model order (NLAGS) 
%           for a multivariate data set.
% 
% INPUTS:   X: matrix of nvar variables by nobs observations of each variable    
%           MINP: minimum model order to consider
%           MAXP: maximum model order to consider
%
% OUTPUT:   bic: optimal model order according to BIC
%           aic: optimal model order according to Akaike Information Criterion (AIC)
%
%           Written by Anil Seth, March 2004
%           Updated August 2004
%           Updated December 2005
%           Ref: Seth, A.K. (2005) Network: Comp. Neural. Sys. 16(1):35-55
%-----------------------------------------------------------------------

[nvar,nobs] = size(X);
if(nobs<nvar) error('Fewer observations than variables, exiting'); end
if(MAXP<=MINP) error('MAXP must be bigger than MINP, exiting'); end

bc = ones(1,MAXP).*999;
ac = ones(1,MAXP).*999;
for i = MINP:MAXP
    eval('res = cca_regress(X,i,0);','res = -1');   % estimate regression model, catch errors
    if(~isnumeric(res))
        [bc(i),ac(i)] = findbic(res,nvar,nobs,i);
        %disp(['VAR order ',num2str(i),', BIC = ',num2str(bc(i)),', AIC = ',num2str(ac(i))]);
    else
        disp('VAR failed');
        bc(i) = 999; 
        ac(i) = 999;
    end
end

[bicmin,bic] = min(bc);
[aicmin,aic] = min(ac);

%---------------------------------------------------------------------
function [bc,ac] = findbic(res,nvar,nobs,nlag)

error = log(det(res.Z));
nest = nvar*nvar*nlag;       
bc = error + (log(nobs)*nest/nobs);   
ac = error + (2*nest/nobs);

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

