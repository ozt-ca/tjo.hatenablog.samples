function XC = cca_center(X)
%CENTER XC = cca_center(X)
%	Centers each column of X.

%	J. Rodrigues 26/IV/97, jrodrig@ulb.ac.be

[T n] = size(X);
XC = X - ones(T,1)*(sum(X)/T); % Much faster than MEAN with a FOR loop