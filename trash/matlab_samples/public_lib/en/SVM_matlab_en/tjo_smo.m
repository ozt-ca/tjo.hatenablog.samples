function [alpha_smo,bias]=tjo_smo(x_list,y_list,alpha,delta,Cmax,clength,learn_stlength,loop)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SMO (Sequential Minimal Optimization)     %
% A solution of convex quadratic programmes %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Please see Christianini's textbook for details.
% DO NOT EDIT this code without understanding the textbook above!!!!!

idx=randperm(clength);
i1=idx(1);
e_list=zeros(clength,1);

main_routine;
alpha_smo=alpha;

    function output=Es(i)
        output=alpha(i)+learn_stlength*(1-(y_list(i)*tjo_margin(x_list(i),x_list,alpha,y_list,delta,clength)));
    end

    function output=Ks(p,q)
        norm_dat=norm(x_list(p)-x_list(q));
        abs_dat=(norm_dat)^2;
        p=(abs_dat)/(2*(delta)^2);
        output=exp(-p);
    end

    function output = takeStep(i1,i2)
        eps=0.001;
        output=0;
        if(i1==i2)
            return;
        end;
        
        alph1=alpha(i1);
        y1=y_list(i1);
        alph_t2=alpha(i2);
        y2=y_list(i2);
        
        E1=Es(i1)-y1;
        E2=Es(i2)-y2;
        
        s=y1*y2;
        
        gamma=alph1+alph_t2*s;
        
        % Computing L (U in the textbook) and H (V in the textbook)
        if(s==1)
            L = max([0 alph1+alph_t2-Cmax]);
            H = min([Cmax alph_t2+alph1]);
        else
            L = max([0 alph_t2-alph1]);
            H = min([Cmax Cmax+alph_t2-alph1]);
        end;
        
        % Terminating if L = H
        if(L==H)
            return;
        end;
        
        k11=Ks(i1,i1);
        k12=Ks(i1,i2);
        k22=Ks(i2,i2);
        
        eta = k11+k22-2*k12; % "eta" is defined in the opposite sign
        
        if(eta>0)
            a2=alph_t2+y2*(E1-E2)/eta;
            a2=min([max([a2 L]) H]);
        else
            Lobj=gamma-s*L+L-0.5*k11*(gamma-s*L)^2-0.5*k22*L^2-s*k12*(gamma-s*L)*L-y1*(gamma-s*L); % W when a2 = L
            Hobj=gamma-s*H+H-0.5*k11*(gamma-s*H)^2-0.5*k22*H^2-s*k12*(gamma-s*H)*H-y1*(gamma-s*H); % W when a2 = H
            if(Lobj < Hobj-eps)
                a2 = L;
            elseif(Lobj > Hobj+eps)
                a2 = H;
            else
                a2 = alph_t2;
            end;
        end;
        
        if abs(a2-alph_t2) < eps*(a2+alph_t2+eps)
            return;
        end
        
        a1 = alph1 + s*(alph_t2-a2);

        % Update threshold to reflect change in Lagrange multipliers

        updateThreshold(i1,i2,a1,a2);
        % Update weight vector to reflect change in a1 & a2, if SVM is linear
        %%%%%%%%%%%%%
        alpha(i1) = a1;
        alpha(i2) = a2;
        % Update eror cache using new Lagrange multipliers
        updateErrorList;
        
        output = 1;
    end

    function updateThreshold(i1,i2,a1,a2)
        alph1 = alpha(i1);
        y1 = y_list(i1);
        
        alph_t2 = alpha(i2);
        y2 = y_list(i2);
        
        E1=Es(i1)-y1;
        E2=Es(i2)-y2;

        b1 = E1 + y1 * (a1 - alph1) * Ks(i1,i1) + y2 * (a2 - alph_t2) * Ks(i1,i2);
        b2 = E2 + y1 * (a1 - alph1) * Ks(i1,i2) + y2 * (a2 - alph_t2) * Ks(i2,i2);

        if(b1 == b2)
            bias = b1;
        else
            bias = mean([b1 b2]);
        end;
    end

    function updateErrorList
        for j=1:clength
            e_list(j) = Es(j) - y_list(j);
        end;
    end

    function output=examEx(i2)
        output = 0;
        y2 = y_list(i2);
        alph_t2 = alpha(i2);
        E2 = Es(i2);
        r2 = E2*y2;
        
        if (r2 < -0.001 && alph_t2 < Cmax) || (r2 > 0.001 && alph_t2 > 0)
            indx_nz_nC = find(alpha > 0 & alpha < Cmax);
            if length(indx_nz_nC) > 1
                i1 = secondChoiceHeuristic(i2);
                if takeStep(i1,i2)
                    output = 1;
                    return;
                end;
            end;
            % loop over all non-zero and non-C alpha, starting at a random point
            rand_indx = randperm(length(indx_nz_nC));
            for j=1:length(indx_nz_nC)
                i1 = indx_nz_nC(rand_indx(j));
                if takeStep(i1,i2)
                    output = 1;
                    return;
                end;
            end;
            % loop over all pssible i1, starting at a random point
            rand_indx = randperm(clength);
            for j=1:clength
                i1 = rand_indx(j);
                if takeStep(i1,i2)
                    output = 1;
                    return;
                end;
            end;
        end;
    end
        
    function output=secondChoiceHeuristic(i2)
        E2 = e_list(i2);
        [sE,idx] = sort(e_list);
        if E2 > 0
            if idx(1) == i2
                output = idx(2);
            else
                output = idx(1);
            end;
        else
            if idx(end) == i2
                output = idx(end-1);
            else
                output = idx(end);
            end;
        end;
    end

    function main_routine
        nexamples = clength;
        
        numChanged = 0;
        examineAll = 1;
        max_repeat = 0;
       
        while((numChanged > 0 || examineAll) && max_repeat < loop)
            numChanged = 0;
            max_repeat=max_repeat+1;
            if examineAll
                for I=1:nexamples
                    numChanged = numChanged + examEx(I);
                end;
            else
                for I=1:nexamples
                    if alpha(I) > 0 && alpha(I) < Cmax
                        numChanged = numChanged + examEx(I);
                    end;
                end;
            end;
            
            if examineAll == 1
                examineAll = 0;
            elseif numChanged == 0
                examineAll = 1;
            end;
        end;
    end


end