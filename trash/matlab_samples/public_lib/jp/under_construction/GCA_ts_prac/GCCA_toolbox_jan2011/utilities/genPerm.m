function XX = genPerm(X,Nbwin,nwin,nvar,N)
%-----------------------------------------------------------------
%   FUNCTION genPerm(X,Nbwin,nwin,N)
%   create random permutation matrices by dividing each variable
%   time series into windows and reordering the windows randomly
%   for each variable
%
%   AKS Apr 14 2009
%-----------------------------------------------------------------

XX = zeros(nvar,N);
inx = repmat(1:nwin,Nbwin,1);
inx = reshape(inx,1,nwin*Nbwin);
for ii=1:nvar,
    worder = randperm(nwin);
    vec = [];
    for jj=1:nwin,
        winx = find(inx==worder(jj));
        vec = [vec X(ii,winx)];
    end
    XX(ii,:) = vec;
end



