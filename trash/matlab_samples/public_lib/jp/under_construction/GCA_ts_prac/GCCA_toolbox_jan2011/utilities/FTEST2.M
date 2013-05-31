function [fstat, mu, f, trueid] = ftest(dat, NW, K, fftpad, Fs);
%
% calculate F-statistic, that is, F variance-ratio test.
% F has an F distribution, F(2, 2K-2) degrees of freedom.
% hypothesis test for sinusoidal signals under the assuption of a locally white
% background, which implyies the noise is iid complex Gaussian variables.
% The statistical significant level is chosen to be 1-1/N, 
%  N - N Raleigh frequencies
% For details, see Thomson(1987).
%
% Usage:
%   [fstat, mu, f, trueid] = ftest(dat, NW, K, fftpad, Fs);
% Input:
%   dat: time series, a column vector (T x 1)
%   NW:  half-time bandwidth product
%   K:  the numbers of data tapers used, e.g. 2*NW-1
%   fftpad: FFT zero-padding length
%   Fs: sampling rate
% Output:
%   fstat: F-statistic
%   mu:    estimated amplitude of harmonic signals
%   f:  frequency range
% Note:
%  Utilizing the fact that the taper sum is near zero for antisymmetric tapers
%  should greatly speed the computation up. 
%

%
% Hualou Liang, 12/04/98, FAU
% AKS mod Apr 22 2009 to supply noisefreq as an input
%

if nargin < 5
  Fs = 1;
end

if nargin < 4
  pad = 1024;
end

dat = dat(:);    
T = length(dat);
half_pad = fftpad/2;
f = (0:half_pad-1)*Fs/fftpad;

E = dpss(T, NW);
Wk0 = sum(E(:, 1:K));  
X = fft( E(:,1:K) .* dat(:, ones(1, K)), fftpad);  
mu = X(1:half_pad, :) * Wk0' / sum(Wk0.^2);       
denom = sum(abs(X(1:half_pad, :) - mu*Wk0).^2, 2);  
fstat = (K-1)*abs(mu).^2 * sum(Wk0.^2) ./ denom;




