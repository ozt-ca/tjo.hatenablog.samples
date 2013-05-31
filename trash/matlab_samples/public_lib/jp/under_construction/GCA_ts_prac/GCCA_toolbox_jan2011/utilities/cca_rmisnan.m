function Y=cca_rmisnan(X,val)
% FUNCTION: Y=cca_rmisnan(X)
% returns matrix with NaN values replaced by val (default val = 0)
% Anil K Seth Oct 2010

if nargin<2,
    val = 0;
end

inx = find(isnan(X));
X(inx) = val;
Y = X;