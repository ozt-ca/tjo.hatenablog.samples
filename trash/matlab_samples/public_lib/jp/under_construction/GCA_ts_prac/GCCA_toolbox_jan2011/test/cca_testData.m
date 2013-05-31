function X = ccaTestData(N,FLAG)
%-------------------------------------------------------------------
%   FUNCTION:   ccaTestData.m
%   PURPOSE:    generate sample data for Granger analysis
%
%   INPUT:  N       -   # timepoints
%           FLAG    -   select generative model (see below)
%
%   OUTPUT: X       -   nvar * nobs matrix of observations

%   FLAG == 1:
%   Baccala & Sameshima data
%   Baccala, L. A. & Sameshima, K. 2001 Partial directed coherence:
%   a new concept in neural structure determination. Biol Cybern 84,
%   463-74.

%   FLAG == 2:
%   Schelter et al data
%   Schelter, B., Winterhalder, M., Eichler, M., Peifer, M., Hellwig, B.,
%   Guschlbauer, B., Lucking, C. H., Dahlhaus, R. & Timmer, J. 2006
%   Testing for directed influences among neural signals using partial directed coherence.
%   J Neurosci Methods 152, 210-9.

%   FLAG == 3:
%   Guo, S., Seth, A. K., Kendrick, K. M., Zhou, C., & Feng, J. (2008).
%   Partial Granger causality-Eliminating exogenous inputs and latent variables.
%   J Neurosci Methods, 172(1), 79-93.  (Figure 5C)

%   FLAG == 4,
%   4 variables, x2->x1 and x4->x3, no conditional relations,
%   use to demonstrate bootstrap/permutation for spectral G-causality

%   Written by AKS, Apr 02 2009
% COPYRIGHT NOTICE AT BOTTOM
%----------------------------------------------------------------

settleTime = 500;   % number of observations to allow dynamics to settle

if FLAG == 1,  % Baccala & Sameshima

    N = N + settleTime;
    X = cca_normrnd(0,1,5,N);   % 5 variables
    r = sqrt(2);
    for i=4:N,
        X(1,i) = X(1,i) + 0.95.*r.*X(1,i-1) - 0.9025.*X(1,i-2);
        X(2,i) = X(2,i) + 0.5.*X(1,i-2);
        X(3,i) = X(3,i) - 0.4.*X(1,i-3);
        X(4,i) = X(4,i) - 0.5.*X(1,i-2) + 0.25.*r.*X(4,i-1) + 0.25.*r.*X(5,i-1);
        X(5,i) = X(5,i) - 0.25.*r.*X(4,i-1) + 0.25.*r.*X(5,i-1);

    end
    X = X(:,settleTime+1:end);

elseif FLAG == 2,   % Schelter et al

    N = N + settleTime;
    X = cca_normrnd(0,1,5,N);   % 5 variables
    for i=5:N,
        X(1,i) = X(1,i) + 0.6.*X(1,i-1) + 0.65.*X(2,i-2);
        X(2,i) = X(2,i) + 0.5.*X(2,i-1) - 0.3.*X(2,i-2) - 0.3.*X(3,i-4) + 0.6.*X(4,i-1);
        X(3,i) = X(3,i) + 0.8.*X(3,i-1) - 0.7.*X(3,i-2) - 0.1.*X(5,i-3);
        X(4,i) = X(4,i) + 0.5.*X(4,i-1) + 0.9.*X(3,i-2) + 0.4.*X(5,i-2);
        X(5,i) = X(5,i) + 0.7.*X(5,i-1) - 0.5.*X(5,i-2) - 0.2.*X(3,i-1);
    end
    X = X(:,settleTime+1:end);


elseif FLAG == 3,   % Guo et al, Fig 5C

    N = N + settleTime;
    X = zeros(5,N);
    X(:,1:3) = cca_normrnd(0,1,5,3);

    % set noise and error terms
    v = [0.8 0.6 1.0 1.2 1.0 0.9 1.0]; % variances for error
    W = zeros(7,N);
    for i=1:7,
        W(i,:) = normrnd(0,sqrt(v(i)),1,N);
    end
    a = rand(1,5);
    b = rand(1,5);
    c = [1 1 1 1 1];
    r = sqrt(2);

    for i=4:N,
        X(1,i) = 0.95.*r.*X(1,i-1) - 0.9025.*X(1,i-2) + W(1,i) + a(1).*W(6,i) + b(1).*W(7,i-1) + c(1).*W(7,i-2);
        X(2,i) = 0.5.*X(1,i-2) + W(2,i) + a(2).*W(6,i) + b(2).*W(7,i-1) + c(2).*W(7,i-2);
        X(3,i) = 0.4.*X(1,i-3).*-1 + W(3,i) + a(3).*W(6,i) + b(3).*W(7,i-1) + c(3).*W(7,i-2);
        X(4,i) = 0.5.*X(1,i-2).*-1 + 0.25.*r.*X(4,i-1) + 0.25.*r.*X(5,i-1) + W(4,i) + a(4).*W(6,i) + ...
            b(4).*W(7,i-1) + c(4).*W(7,i-2);
        X(5,i) = 0.25.*r.*X(4,i-1).*-1 + 0.25.*r.*X(5,i-1) ...
            + W(5,i) + a(5).*W(6,i) + b(5).*W(7,i-1) + c(5).*W(7,i-2);
    end
    X = X(:,settleTime+1:end);
    
elseif FLAG == 4,
    
    N = N + settleTime;
    X = cca_normrnd(0,1,4,N);   % 4 variables
    r = sqrt(2);
    for i=4:N,
        X(1,i) = X(1,i) + 0.95.*r.*X(1,i-1) - 0.9025.*X(1,i-2);
        X(2,i) = X(2,i) + 0.5.*X(1,i-1);
        X(3,i) = X(3,i) - 0.4.*X(4,i-3);
        X(4,i) = X(4,i) + 0.35.*X(4,i-2);
    end
    X = X(:,settleTime+1:end);
    
else
    error('invalid input to ccaTestData.m');
end


% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2005-2009) 
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
