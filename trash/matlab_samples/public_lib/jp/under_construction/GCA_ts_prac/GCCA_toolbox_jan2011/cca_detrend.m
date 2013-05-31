function [Y]=cca_detrend(X)
%-----------------------------------------------------------------------
% FUNCTION: cca_detrend.m
% PURPOSE:  remove determinstic linear trends (wrapper function)
% 
% INPUTS:   X:      nvar (rows) by nobs (cols) observation matrix
%         
% OUTPUT:   Y:      detrended matrix of same dimensions as X
%     
%           Written by Anil Seth, August 2009
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

nobs = size(X,2);
nvar = size(X,1);
if(nvar>nobs) error('error in cca_detrend: nvar>nobs, check input matrix'); end

X = X';
Y = detrend(X);  % use inbuilt detrend function
Y = Y';

% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2009) 
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