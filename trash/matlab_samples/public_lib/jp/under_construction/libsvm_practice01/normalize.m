function data = normalize(d)
% scale before svm
% the data is normalized so that max is 1, and min is 0
data = (d -repmat(min(d,[],1),size(d,1),1))*spdiags(1./(max(d,[],1)-min(d,[],1))',0,size(d,2),size(d,2));
end