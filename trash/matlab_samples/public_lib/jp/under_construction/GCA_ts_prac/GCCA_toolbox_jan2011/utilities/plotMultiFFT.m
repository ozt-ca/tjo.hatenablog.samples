%   plotMultiFFT
%   plot multiple FFTs
%   AKS Apr 02 2009

function plotMultiFFT(fplot,freq,ps)

% plot
cmap = colormap('bone');
cmap = flipud(cmap);
colormap(cmap);
fmin  = min(fplot);
fmax  = max(fplot);
finx = find(freq >= fmin & freq <= fmax);
ps = ps(:,finx);
f = freq(finx);
imagesc(ps);

% label
xstep = floor(length(finx)/5);  % # x-marks
xmark = 1;
for i=1:5,
    xmark(i+1) = xstep*i;
end
ymark = linspace(fmin,fmax,length(xmark));
set(gca,'XTick',xmark);
set(gca,'XTickLabel',ymark);
ylabel('variable');
xlabel('frequency');
freezeColors;