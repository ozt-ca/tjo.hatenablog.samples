function [harmon] = reconstr(fstat, mu, T, id, bw);

% Reconstruct harmonic components based F-statistic, 
% for subsequent reshaped spectrum analysis
%
% Usage:
%   [harmon] = reconstr(fstat, mu, T, id, bw);
% Input:
%   fstat: F-statistic
%   mu:    estimated amplitude & phase of harmonic signals
%   T:   the length of time series
%   id:  theoretical value of frequence index of line noise
%   bw:  bandwidth assumed around 60 Hz, e.g. 3
% Output:
%   harmon: reconstruct sinusoidal components (1 x T)
%
% Hualou Liang, 12/06/98, FAU
%
harmon = zeros(1, T);   % a column vector
ind = find(fstat == max(fstat));
if id-bw<=ind & ind <= id+bw,
  harmon = 2*real(mu(ind)*exp(2*pi*i*[0:T-1]*(ind-1)/(2*length(fstat))));
  %disp('using fstat');
else
  harmon = 2*real(mu(id)*exp(2*pi*i*[0:T-1]*(id-1)/(2*length(fstat))));
  %disp('NOT using fstat');
end





