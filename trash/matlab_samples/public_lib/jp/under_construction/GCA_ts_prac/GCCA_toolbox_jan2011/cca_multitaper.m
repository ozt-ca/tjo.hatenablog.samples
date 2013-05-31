function y = cca_multitaper(x,Fs,Fnoise,WSIZE)
%------------------------------------------------
%   FUNCTION:   cca_multitaper.m
%
%   line noise removal (windowed) using multitaper filter


%   INPUTS:     x       -   1*N vector of observations
%               Fs      -   sampling rate
%               Fnoise  -   line noise
%               WSIZE   -   window size (in # samples)
%
%   OUTPUT:     y       -   cleaned signal
%
%   Written  by AKS Feb 27 2009
%   (with help from Hualou Liang)
% COPYRIGHT NOTICE AT BOTTOM
%------------------------------------------------

%   multitaper parameters
NW = 3;             % halfbandwidth
K=5;                % number of tapers
N = length(x);      % number of observations
pad = WSIZE*10;     % fft padding

% find surrogate sampling frequency (multiple of Fnoise)
if Fs/Fnoise ~= round(Fs/Fnoise),
    Fs2 = Fnoise.*(ceil(Fs/Fnoise));
    Fnoise2 = Fnoise.*(Fs/Fs2);
else
    Fs2 = Fs;
    Fnoise2 = Fnoise;
end

% calculate number of windows
nsampwin = WSIZE;           % samples per window
nwin = ceil(N/nsampwin);    % number of windows
if rem(N,nsampwin)>0 & rem(N,nsampwin)<(nsampwin/2),
    nwin = nwin-1;
end

disp(['Applying multitaper to remove line noise']);
disp(['# data windows = ',num2str(nwin)]);

%   loop thru windows
startinx = 1;
y = zeros(1,N);
for i=1:nwin,
    stopinx = startinx+nsampwin-1;
    if stopinx>N,
        stopinx = N;
        i = nwin;
    end
    if i==nwin & stopinx < N,
        stopinx = N;
    end
    
    % apply multitaper and subtract from original signal
    dat = x(startinx:stopinx);
    [fstat, mu, f] = FTEST2(dat, NW, K, pad, Fs2);
    newid = findnearest(Fnoise,f,0);
    harmon = RECONSTR(fstat, mu, length(dat), newid, 3)';
    dat = dat-harmon';
    if Fnoise2 ~= Fnoise,
        newid = findnearest(Fnoise2,f,0);
        harmon = RECONSTR(fstat, mu, length(dat), newid, 3)';
        dat = dat-harmon';
    end
    y(startinx:stopinx) = dat;
    startinx = startinx+nsampwin;     
end


% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2007-2009) and Hualou Liang (2009)
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
