function out=tjo_part_prob(xvec_id,data_row)

cl=size(data_row,2);
num=size(find(data_row==xvec_id),2);

out=num/cl;

end