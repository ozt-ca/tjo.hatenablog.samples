function wvec = tjo_PA2_train(wvec,x_list,y_list,Cmax,loop)

cl=size(x_list,2);

for i=1:loop
    for j=1:cl
        if(y_list(j)*(dot(wvec,x_list(:,j)))>=1)
            lt=0;
        else
            lt=1-(y_list(j)*(dot(wvec,x_list(:,j))));
        end;
        tau=lt/((norm(x_list(:,j)))^2+(0.5/Cmax));
        wvec = wvec + tau*y_list(j)*x_list(:,j);
    end;
end;

end