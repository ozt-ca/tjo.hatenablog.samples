function [wvec_new,nE,H]=tjo_LR_train(wvec,x_list,y_list,clength)

nE=[0;0;0];
H=[0 0 0;0 0 0;0 0 0];
wvec_new=[1;1;1];
wvec_old=wvec;

while (norm(wvec_new-wvec_old)/norm(wvec_old) > 0.01)
    for j=1:clength
        nE=nE+(tjo_sigmoid(wvec_old'*x_list(:,j))-y_list(j))*x_list(:,j);
        H=H+y_func(wvec_old,x_list(:,j))*(1-y_func(wvec_old,x_list(:,j)))*x_list(:,j)*(x_list(:,j))';
    end;
    wvec_new=wvec_old-(inv(H))*nE;
    wvec_old=wvec_new;
end

end