function p = cca_cdff(x,v1,v2)
%   CDF computes the cumulative 'F' distribution

p = 0;
t = (v1 <= 0 | v2 <= 0 | isnan(x) | isnan(v1) | isnan(v2));
p(t) = NaN;
s = (x==Inf) & ~t;
if any(s)
   p(s) = 1;
   t = t | s;
end

% Compute P when X > 0.
k = find(x > 0 & ~t & isfinite(v1) & isfinite(v2));
if any(k), 
    xx = x(k)./(x(k) + v2(k)./v1(k));
    p(k) = betainc(xx, v1(k)/2, v2(k)/2);
end

if any(~isfinite(v1(:)) | ~isfinite(v2(:)))
   k = find(x > 0 & ~t & isfinite(v1) & ~isfinite(v2) & v2>0);
   if any(k)
      p(k) = chi2cdf(v1(k).*x(k),v1(k));
   end
   k = find(x > 0 & ~t & ~isfinite(v1) & v1>0 & isfinite(v2));
   if any(k)
      p(k) = 1 - chi2cdf(v2(k)./x(k),v2(k));
   end
   k = find(x > 0 & ~t & ~isfinite(v1) & v1>0 & ~isfinite(v2) & v2>0);
   if any(k)
      p(k) = (x(k)>=1);
   end
end

