function cca_autonomy_demo
%-----------------------------------------------------------------------
% FUNCTION: cca_autonomy_demo.m
% PURPOSE:  illustrate G-autonomy
%
% 'x1' is nonautonomous because it is random
% 'x2' is nonautonomous because it is both random and predicted by 'x1'
% 'x3' IS AUTONOMOUS because it has an AR component (even though it is
%       partly predicted by 'x1'
% 'x4' is nonautonomous because, even though it has an AR component,
%       this component is predicted by 'x3'.
% 'x5' IS AUTONOMOUS because it has an AR component that is not predicted
%     from other variables.
%
%   Ref:  Seth, A.K. (2009). Measuring autonomy and emergence via
%       Granger causality.  Artificial Life 
%   Ref:  Seth, A.K., Measuring autonomy via multivariate autoregressive
%           modelling, in Proceedings of the 9th European Conference on Artificial Life, 
%           2007, p. 475-484.
% COPYRIGHT NOTICE AT BOTTOM
%-----------------------------------------------------------------------

X = cca_autonomydata;   % generate sample data set (corresponding to above)

PVAL = 0.01;
NLAGS = -1;     % specify model order based on data
FSIZE = 8;      % font size for plotting results

% check covariance stationarity
disp('checking for covariance stationarity ...');
uroot = cca_check_cov_stat(X,10);
inx = find(uroot);
if sum(uroot) == 0,
    disp('OK, data is covariance stationary');
else
    disp('WARNING, data is NOT covariance stationary');
    disp(['unit roots found in variables: ',num2str(inx)]);
end

% find best model order
if NLAGS == -1,
    [bic,aic] = cca_find_model_order(X,2,12);
    disp(['best model order by Bayesian Information Criterion = ',num2str(bic)]);
    disp(['best model order by Akaike Information Criterion = ',num2str(aic)]);
    NLAGS = aic;    
end

% find G-autonomies [THIS IS THE KEY FUNCTION]
disp('computing G-autonomies');
ret = cca_autonomy_regress(X,NLAGS);

% analyze adjusted r-square to check that model accounts for the data
rss = ret.rss_adj;
inx = find(rss<0.3);
if isempty(inx)
    disp('Adjusted r-square is OK: >0.3 of variance is accounted for by model');
else
    disp(['WARNING, low adjusted r-square values for variables: ',num2str(inx)]);
    disp(['corresponding values are ',num2str(rss(inx))]);
end

%   extract significant autonomies
[PR,q] = cca_findsignificance_autonomy(ret,PVAL,1);

%   plot results
figure(1); clf reset;
GA = ret.gaut;
GA = GA.*PR;
bar(1:length(GA),GA);
xlabel('variable');
ylabel('G-autonomy');
set(gca,'Box','off');

%--------------------------------------------------------------------------
%   cca_autonomydata
function X = cca_autonomydata

N = 5000;
x1 = rand(1,N);
x2 = rand(1,N);
x3 = rand(1,N);
x4 = rand(1,N);
x5 = rand(1,N);

x2(2:end) = 0.5.*x2(2:end)+0.5.*x1(1:end-1);
x3(3:end) = 0.5.*x3(3:end)+ 0.5.*x3(1:end-2) + 0.5.*x1(1:end-2);;  
x4(2:end) = 0.5.*x4(2:end) + 0.5.*x3(1:end-1);        
x5(3:end) = 0.33*x1(1:end-2) + 0.33*x5(1:end-2) + 0.33*x5(3:end);

X = [x1 ; x2 ; x3 ; x4 ; x5];

% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2007-2009) 
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
% along with GCCAtoolbox. If not, see <http://www.gnu.org/licenses/>.







