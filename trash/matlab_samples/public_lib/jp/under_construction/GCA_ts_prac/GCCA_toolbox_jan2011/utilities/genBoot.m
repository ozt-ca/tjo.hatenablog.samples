function XX = genBoot(X,Nbwin,nwin,nvar,N)
%-----------------------------------------------------------------
%   FUNCTION genBoot(X,Nbwin)
%   create bootstrap matrices by resampling with replacement from
%   original data, preserving both serial order and causal relations
%
%   AKS Apr 11 2009
%-----------------------------------------------------------------
XX = zeros(nvar,N);
inx = repmat(1:nwin,Nbwin,1);
inx = reshape(inx,1,nwin*Nbwin);
ct = 1;
for jj=1:nwin,
    temp = randperm(nwin);
    winx = find(inx==temp(1));
    XX(:,ct:ct+Nbwin-1) =  X(:,winx);  
    ct = ct + Nbwin;
end