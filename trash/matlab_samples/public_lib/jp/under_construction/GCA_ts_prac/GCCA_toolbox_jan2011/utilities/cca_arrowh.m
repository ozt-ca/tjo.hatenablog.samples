%  ARROWH   Draws a solid 2D arrow head in current plot.
%     ARROWH(X,Y,COLOR,SIZE,LOCATION) draws a solid arrow head into 
%     the current plot to indicate a direction.  X and Y must contain
%     a pair of x and y coordinates ([x1 x2],[y1 y2]) of two points:
%
%     The first point is only used to tell (in conjunction with the 
%     second one) the direction and orientation of the arrow -- it 
%     will point from the first towards the second.
%
%     The head of the arrow will be located in the second point.  An
%     example of use is    plot([0 2],[0 4]); ARROWH([0 1],[0 2],'b')
%
%     You may also give two vectors of same length > 2.  The routine
%     will then choose two consecutive points from "about" the middle
%     of each vectors.  Useful if you don't want to worry each time
%     about where to put the arrows on a trajectory.  If x1 and x2 
%     are the vectors x1(t) and x2(t), simply put   ARROWH(x1,x2,'r')  
%     to have the right direction indicated in your x2 = f(x1) phase 
%     plane.
%
%                       (x2,y2)
%                       --o
%                       \ |
%                        \|
%
%
%            o
%        (x1,y1)
%
%     Please note that the following optional arguments need -- if 
%     you want to use them -- to be given in that exact order. 
%
%     The COLOR argument is exactely the same as for plots, eg. 'r'; 
%     if not given, blue is default.
%
%     The SIZE argument allows you to tune the size of the arrows.
%
%     The LOCAITON argument only applies, if entire solution vectors 
%     have been passed on.  With this argument you can indicate where
%     abouts inside those vectors to take the two points from.
%     Can be a vector, if you want to have more than one arrow drawn.
%
%     Both arguments, SIZE and LOCATION must be given in percent, 
%     where 100 means standard size, 50 means half size, respectively 
%     100 means end of the vector, 48 means about middle, 0 beginning. 
%     Note that those "locations" correspond to the cardinal position 
%     "inside" the vector, say "index-wise".
%
%     This routine is mainely intended to be used for indicating 
%     "directions" on trajectories -- just give two consecutive times 
%     and the corresponding values of a flux and the proper direction 
%     of the trajectory will be shown on the plot.  You may also pass 
%     on two solution vectors, as described above.
%
%     Note, that the arrow only looks good on the specific axis 
%     settings when the routine was actually started.  If you zoom in 
%     afterwards, the triangle gets distorted.
%
%     Examples of use:
%     x1 = [0:.2:2]; x2 = [0:.2:2]; plot(x1,x2); hold on;
%     arrowh(x1,x2,'r',100,20);      % passing on entire vectors
%     arrowh([0 1],[0 1],'g',300);   % passing on 2 points

%     Author:       Florian Knorn
%     Email:        florian.knorn@student.uni-magdeburg.de
%     Version:      1.08
%     Filedate:     Oct 28th, 2004
%
%     ToDos:        - More specific shaping-possibilities, 
%                   - Keep proportions when zooming or resizing
%     Bugs:         None discovered yet
%
%     If you have suggestions for this program, if it doesn't work for
%     your "situation" or if you change something in it - please send 
%     me an email!  This is my very first "public" program and I'd like
%     to improve it where I can -- your help is kindely appreciated! 
%     Thank you!

function arrowh(x,y,clr,ArSize,Where);

%-- errors
if exist('x')*exist('y') ~= 1,
    error('Please give enough coordinates!');
end
if ((length(x) < 2) | (length(y) < 2)),
    error('X and Y vectors must each have "length" 2!');
end
if (x(1) == x(2)) & (y(1) == y(2)),
    error('Points superimposed - cannot determine direction!');
end

%-- determine and remember the hold status, toggle if necessary
if ishold == 0,
    WasHold = 0;
    hold on;
else
    WasHold = 1;
end

%-- start for-loop in case several arrows are wanted
for Loop = 1:length(Where)
%clear ArSize

%-- no errors, move on. if vectors "longer" then 2 are given
if (length(x) == length(y)) & (length(x) > 2),
    if exist('Where') == 1, %-- and user said, where abouts to put arrow
        j = floor(length(x)*Where(Loop)/100); %-- determine that location
        if j >= length(x), j = length(x) - 1; end
        if j == 0, j = 1; end
    else %-- he didn't tell where, so take the "middle" by default
        j = floor(length(x)/2);
    end %-- now pick the right couple of coordinates
    x1 = x(j); x2 = x(j+1); y1 = y(j); y2 = y(j+1);
    
else %-- just two points given - must take those
    x1 = x(1); x2 = x(2); y1 = y(1); y2 = y(2);
end

%-- if no color given, use blue as default
if exist('clr') ~= 1
    clr = 'b';
end

%-- determine if size argument was given, if not, set it to default
if exist('ArSize') ~= 1,
    ArSize = 100 / 10000; %-- 10000 is an arbitrary value...
else
    ArSize = ArSize / 10000;
end

%-- get axe ranges and their norm
OriginalAxis = axis;
Xextend = abs(OriginalAxis(2)-OriginalAxis(1));
Yextend = abs(OriginalAxis(4)-OriginalAxis(3));

%-- determine angle for the rotation of the triangle
if x2 == x1, %-- line vertical, no need to calculate slope
    if y2 > y1
        p = pi/2;
    else
        p= -pi/2;
    end
else %-- line not vertical, go ahead and calculate slope
     %-- using normed differences (looks better like that)
    m = ( (y2 - y1)/Yextend ) / ( (x2 - x1)/Xextend );
    if x2 > x1, %-- now calculate the resulting angle
        p = atan(m);
    else
        p = atan(m) + pi;
    end
end

%-- the arrow is made of a transformed "template triangle".
%-- it will be created, rotated, moved, resized and shifted.

%-- the template triangle (it points "east", centered in (0,0)):
xt = [1    -sin(pi/6)    -sin(pi/6)];
yt = [0     cos(pi/6)    -cos(pi/6)];

%-- rotate it by the angle determined above:
for i=1:3,
    xd(i) = cos(p)*xt(i) - sin(p)*yt(i);
    yd(i) = sin(p)*xt(i) + cos(p)*yt(i);
end

%-- move the triangle so that its "head" lays in (0,0):
xd = xd - cos(p);
yd = yd - sin(p);

%-- stretch/deform the triangle to look good on the current axes:
xd = xd*Xextend*ArSize;
yd = yd*Yextend*ArSize;

%-- move the triangle to the location where it's needed
xd = xd + x2;
yd = yd + y2;

%-- draw the actual triangle
patch(xd,yd,clr,'EdgeColor',clr);

end % Loops

%-- restore original axe ranges and hold status
axis(OriginalAxis);
if WasHold == 0,
    hold off
end

%-- work done. good bye.