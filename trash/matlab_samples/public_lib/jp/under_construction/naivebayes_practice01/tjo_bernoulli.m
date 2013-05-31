function out = tjo_bernoulli(xvec,x1_list,x2_list)


p1=size(x1_list,2)/(size(x1_list,2)+size(x2_list,2));
p2=1-p1;

m1=mean(x1_list,2);
m2=mean(x2_list,2);

np1=p1*prod(m1.^xvec.*(1-m1).^(1-xvec));
np2=p2*prod(m2.^xvec.*(1-m2).^(1-xvec));

px=np1/(np1+np2);

out=px;

end