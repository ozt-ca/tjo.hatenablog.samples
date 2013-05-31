function [ps,freq,psd] = cca_spec(signal,srate,DRAWFLAG)

if(nargin<3) DRAWFLAG = 1; end
n = length(signal); 
tau = 1/srate;
f=fft(signal,n);
ps=(f.*conj(f))/n;      %   this gives power spectrum for non-windowed (but finite) signal                  
psd=(f.*conj(f))/(n*n); %   power spectral density W/Hz (sum over this for a range of Freqs)  
freq = srate*(1:n/2)/n;
if(DRAWFLAG == 1)
    %plot(freq,ps(2:n/2+1),'r');
    %drawnow;
    hold on;
    plot(freq,psd(2:n/2+1),'g');
    xlim([0 100]);  
end