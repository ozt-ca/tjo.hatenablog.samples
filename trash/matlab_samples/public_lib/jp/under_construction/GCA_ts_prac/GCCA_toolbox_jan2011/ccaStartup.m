function ccaStartup
%---------------------------------------------------------------
%   ccaStartup.m
%   add matlab paths for causal connectivity analysis toolbox
%   run before anything else!
%   AKS Apr 09 2009
%---------------------------------------------------------------

addpath test/;
addpath utilities/;
addpath Bsmart_files/;
warning('off','MATLAB:dispatcher:InexactMatch');

% check all files are included
if exist('armorf.m') ~=2 | exist('pwcausal.m') ~=2,
    error('Functions armorf.m and/or pwcausal.m missing.  Download from www.brain-smart.org');
end

% check that mex file is compiled properly
dummy = 1;
try 
    x = marsaglia_normcdf(dummy);
catch
    error('Mex file marsaglia_normcdf is not properly compiled for this operating system. Please recompile by choosing a compiler (mex -setup) and then entering: mex utilities/marsaglia_normcdf.c');
end
if abs(x-0.8413)>1e-2,
    abs(x-0.8413)
    error('Mex file marsaglia_normcdf is not properly compiled for this operating system (runs but gives wrong value). Please recompile by choosing a compiler (mex -setup) and then entering: mex utilities/marsaglia_normcdf.c');
end
    
