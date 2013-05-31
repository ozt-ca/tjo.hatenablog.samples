function y = detrend(x,o,bp)
%DETREND Remove a linear trend from a vector, usually for FFT processing.
%   Y = DETREND(X) removes the best straight-line fit linear trend from 
%   the data in vector X and returns it in vector Y.  If X is a matrix,
%   DETREND removes the trend from each column of the matrix.
%
%   Y = DETREND(X,'constant') removes just the mean value from the vector X,
%   or the mean value from each column, if X is a matrix.
%
%   Y = DETREND(X,'linear',BP) removes a continuous, piecewise linear trend.
%   Breakpoint indices for the linear trend are contained in the vector BP.
%   The default is no breakpoints, such that one single straight line is
%   removed from each column of X.
%
%   Class support for inputs X,BP:
%      float: double, single
%
%   See also MEAN

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.2 $  $Date: 2004/03/09 16:16:16 $

if nargin < 2, o  = 1; end
if nargin < 3, bp = 0; end

n = size(x,1);
if n == 1,
  x = x(:);			% If a row, turn into column vector
end
N = size(x,1);

switch o
case {0,'c','constant'}
  y = x - ones(N,1)*mean(x);	% Remove just mean from each column

case {1,'l','linear'}
  bp = unique([0;bp(:);N-1]);	% Include both endpoints
  lb = length(bp)-1;
  % Build regressor with linear pieces + DC
  a  = [zeros(N,lb,class(x)) ones(N,1,class(x))]; 
  for kb = 1:lb
    M = N - bp(kb);
    a((1:M)+bp(kb),kb) = (1:M)'/M;
  end
  y = x - a*(a\x);		% Remove best fit

otherwise
  % This should eventually become an error.
  warning('MATLAB:detrend:InvalidTrendType', ...
      'Invalid trend type ''%s''.. assuming ''linear''.',num2str(o));
  y = detrend(x,1,bp); 

end

if n == 1
  y = y.';
end
