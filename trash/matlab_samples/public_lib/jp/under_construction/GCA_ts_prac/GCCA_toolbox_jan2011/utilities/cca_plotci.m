function cca_plotci(m,ul,ll)
%-------------------------------------------------------------------
%   FUNCTION:   cca_plotci
%   PURPOSE:    plot a confidence interval given a mean and upper/lower
%               limits; for vectors of means/cis only.
%
%   INPUTS:     m   -   mean
%               ul  -   upper CI
%               ll  -   lower CI
%
%   AKS Apr 12 2009
%-------------------------------------------------------------------

for i=1:length(m),
    h=line([i i],[ll(i) ul(i)]);
    hold on;
    set(h,'Color',[0.9 0.9 0.9]);
    set(h,'LineWidth',length(m)/10);
end
h=plot(m,'r');
set(h,'LineWidth',2);

