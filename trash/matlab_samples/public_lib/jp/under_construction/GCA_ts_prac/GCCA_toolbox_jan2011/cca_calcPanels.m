% find best organization of subplot panels
function [nx,ny] = calc_panels(nvar)

if nvar == 2,
    nx = 1;
    ny = 2;
elseif nvar < 5,
    nx = 2;
    ny = 2;
elseif nvar < 10,
    nx = 3;
    ny = 3;
elseif nvar < 16,
    nx = 4;
    ny = 4;
else
    t = sqrt(nvar);
    nx = ceil(t);
    ny = ceil(t);
end