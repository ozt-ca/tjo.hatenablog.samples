function tjo_simple_SVM_output(i)

global e_list x_list y_list alpha delta Cmax learn_stlength;

alpha(i)=alpha(i)+learn_stlength*(1-(y_list(i)*tjo_margin(x_list(i),x_list,alpha,y_list,delta)));

end