function [pp,cohe,Fx2y,Fy2x]=pwcausal(x,Nr,Nl,porder,fs,freq)
% Using Geweke's method to compute the causality between any two channels
%
%   x is a matrix whose every row is one variable's time series
%   Nr is the number of realizations, 
%   Nl is the length of every realization
%      If the time series are stationary long, just let Nr=1, Nl=length(x)
%   porder is the order of AR model
%   fs is sampling frequency
%   freq is a vector of frequencies of interest, usually freq=0:fs/2
%
%   pp is power spectrum
%   cohe is coherence between any two channels
%   Fx2y is the causality measure from x to y
%   Fy2x is causality from y to x
%        the order of Fx2y/Fy2x is 1 to 2:L, 2 to 3:L,....,L-1 to L.  That is,
%        1st column: 1&2; 2nd: 1&3; ...; (L-1)th: 1&L; ...; (L(L-1))th: (L-1)&L.

% Finished March 2003 by Yonghong Chen

[L,N] = size(x); %L is the number of channels, N is the total points in every channel
[A,Z] = armorf(x,Nr,Nl,porder);  %fitting AR model using my own code

f_ind  = 0;
    for f  = freq
        f_ind = f_ind + 1;
        % Spectrum Matrix
        [S,H] = spectrum(A,Z,porder,f,fs); 
        % Power spectrum (N.B.: this is the two-sided power spectrum. For 1-sided multiply S by 2).
        
        pp(:,f_ind)   = real(diag(S)) .*2 ;
        
        % Coherence spectrum
        
        num              = abs(S).^2;
        denum            = repmat(diag(S),1,L) .* repmat(diag(S),1,L)';
        cohe(:,:,f_ind) = real( num ./ denum );
    end
        
index = 0;
 for i = 1:L-1
     for j = i+1:L
         index = index + 1;
         y(1,:) = x(i,:);
         y(2,:) = x(j,:);  
         [A2,Z2] = armorf(y,Nr,Nl,porder); %fitting a model on every possible pair
         eyx = Z2(2,2) - Z2(1,2)^2/Z2(1,1); %corrected covariance
         exy = Z2(1,1) - Z2(2,1)^2/Z2(2,2);
         f_ind = 0;
         for f = freq
             f_ind = f_ind + 1;
             [S2,H2] = spectrum(A2,Z2,porder,f,fs);
              Iy2x(index,f_ind) = abs(H2(1,2))^2*eyx/abs(S2(1,1))/fs; %measure within [0,1]
              Ix2y(index,f_ind) = abs(H2(2,1))^2*exy/abs(S2(2,2))/fs;
             Fy2x(index,f_ind) = log(abs(S2(1,1))/abs(S2(1,1)-(H2(1,2)*eyx*conj(H2(1,2)))/fs)); %Geweke's original measure
             Fx2y(index,f_ind) = log(abs(S2(2,2))/abs(S2(2,2)-(H2(2,1)*exy*conj(H2(2,1)))/fs));
         end
     end
 end
