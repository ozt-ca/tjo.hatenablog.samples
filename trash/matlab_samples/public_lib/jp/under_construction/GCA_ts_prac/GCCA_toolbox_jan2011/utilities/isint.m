function [int, nearest, rem] = isint(num)
% isint Test if a number is an integer
%
%   int? = isint(num)
%
%   [int?, rounded, remainder] = isint(num)


n = round(num);
r = num-n;
int = (abs(r) == 0);
inte = (abs(r) <= 2*eps);
if inte & ~int,
    disp('Real close to an int! within 2 eps.')
end

if nargout > 1,
    nearest = n;
    rem = r;
end