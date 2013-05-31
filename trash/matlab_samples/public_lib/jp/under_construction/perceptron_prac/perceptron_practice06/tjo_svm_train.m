function alpha=tjo_svm_train(x_list,y_list,alpha,delta,Cmax,loop,clength,learn_stlength)

for j=1:loop
    for i=1:clength
        x_fix=x_list(i);
        alph_t=alpha(i);
        alph_t=alph_t+learn_stlength*(1-(y_list(i)*tjo_margin(x_fix,x_list,alpha,y_list,delta,clength)));
        if(alph_t<0)
            alph_t=0;
        elseif(alph_t>Cmax)
            alph_t=Cmax;
        end;
        alpha(i)=alph_t;
    end;
end;

end