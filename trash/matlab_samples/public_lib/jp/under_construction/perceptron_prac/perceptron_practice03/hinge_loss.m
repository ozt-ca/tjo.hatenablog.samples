function out=hinge_loss(wvec,xvec,t_label)

out=max(0,-t_label*dot(wvec,xvec));

end