%  kalman.m
%
% ----------------------------------
%  Prediction by Kalman Filter
% ----------------------------------
%
Fs = 1000; N =150; time=1:N;
%
% ----------------------------------
NA = 2; a = [1.4 -0.98]; aa = [1 -a];  %  given AR Model
% ----------------------------------
%
yobs = filter(1,aa,1*randn(N,1));      %  サンプル時系列生成
subplot(311);plot(yobs);
axis([0 N -20 20]);legend('sample')
%
%   State Space Representation
%
%   x(t+1) = F x(t) + G w(t)        %  cov{w(t) w(t)} = {Q 0}
%   y(t)   = H x(t) +   v(t)        %     {v(t),v(t)} = {0 R}
%
F = [[zeros(1,NA-1); eye(NA-1)] flipud(a')] ; 
G = flipud(a')                              ;
H = [zeros(1,NA-1) 1]                       ;
Q = 1;
R = 0;
%
% ----------------------------------
%   Kalman Filter
% ----------------------------------
%
%                              initial value
x = zeros(NA,1);                    %   x(0|0)
P = eye(NA);                        %   P(0|0)
ypre = [];
Spre = [];
%      
for t=1:N*2/3    % --------- ＜　一期先予測　+　観測による更新　＞
   %
   %                           prediction 
   x = F * x                        ;  %   x(t+1|t)  <-  x(t|t)  
   P = F * P * F' + G * Q * G'      ;  %   P(t+1|t)  <-  P(t|t)
   ypre = [ypre H*x]                ;
   Spre = [Spre sqrt(H*P*H'+R)]           ;
   %
   %                           filtering 
   K = P * H' / ( H * P * H' + R )  ;  %     Kalman Gain
   x = x + K * ( yobs(t) - H * x )  ;  %     x(t|t)  <-  x(t|t-1)
   P = P - K * H * P                ;  %     P(t|t)  <-  P(t|t-1)
end
for t=N*2/3+1:N  % --------- ＜　長期予測（観測更新なし）　＞
   %
   %                           prediction
   x = F * x                        ;    
   P = F * P * F' + G * Q * G'      ;  
   ypre = [ypre H*x]                ;
   Spre = [Spre sqrt(H*P*H'+R)]           ;
   %
end
%
subplot(312);plot(time,yobs,'b',time,ypre,'m');
axis([0 N -20 20]);legend('observation','prediction')
subplot(313);plot(Spre);
axis([0 N   0 10]);legend('standard deviation of prediction ')
%--------------------------------------------------------
%                                2000.7.04  by K.Tsukada
%                                2002.7.09  revised 
