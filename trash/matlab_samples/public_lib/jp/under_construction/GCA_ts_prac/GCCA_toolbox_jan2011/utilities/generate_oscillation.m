%   generate_oscillation.m
%
%   given a sample rate (srate), a target frequency (freq), and a sample length (N)
%   this function will generate a time series of a corresponding oscillation
%
%   AKS August 26 2004

function osc = generate_oscillation(freq,srate,N,phase)

if nargin < 4,
    phase = 0;
end

cyclen  = round((1/freq)*srate);
dt      = (2*pi)/cyclen;
sinx    = sin(([1:cyclen] + phase*cyclen).*dt);
fac = floor(N/cyclen);
osc = repmat(sinx,1,fac);
r = rem(N,cyclen);
osc(cyclen*fac+1:N) = sinx(1:r);

