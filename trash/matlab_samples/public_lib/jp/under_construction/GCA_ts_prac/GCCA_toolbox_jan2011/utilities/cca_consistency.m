function [cons] = cca_consistency(X,xpred)
%-----------------------------------------------------------------------
% FUNCTION: cca_consistency.m
% PURPOSE:  check what portion of the correlation structure in data is
%           accounted for by an MVAR model, based on Ding et al 2000
%
% INPUTS:   X         nvar (rows) by nobs (cols) observation matrix
%           xpred     predicted values from the MVAR model
%
% OUTPUT:   cons:  consistency check (near 100% is good)
%
%           Ding, Bressler, Yang, Liang (2000) Biol Cyb 83:35-45
%
%           Seth, A.K. (in preparation), A MATLAB Toolbox for Granger
%           causal connectivity analysis
%-----------------------------------------------------------------------
nvar = size(X,1);
Rr = cov(X');
Rs = cov(xpred);
Rr = reshape(Rr,1,nvar*nvar);
Rs = reshape(Rs,1,nvar*nvar);
cons = abs(Rs-Rr)/abs(Rr);
cons = (1-cons)*100;

