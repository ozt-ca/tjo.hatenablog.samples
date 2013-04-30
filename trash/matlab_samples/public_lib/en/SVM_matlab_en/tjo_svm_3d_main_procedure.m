function [new_m,alpha,bias,linear_index]=tjo_svm_3d_main_procedure(xvec,delta,Cmax,loop)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Support Vector Machine (SVM) for 3D data by Takashi J. OZAKI %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This code is just a very simple implementation of SVM.
% At least it implements with:
% 1) 3 kinds of the kernel function (linear / polynomial / Gaussian RBF)
% for nonlinear classification
% 2) SMO (Sequential Minimal Optimization) proposed by J. Platt: one of the
% strongest solution of convex quadratic programmes)
% 3) Visualization (implmented with Matlab functions) including contour
% plots of classifying hyperplanes
% 
% To see how it works, just try it by typing on the command line as follows:
% [new_m,alpha,bias,linear_index]=tjo_svm_3d_main_procedure([2;2;3],2,10,100)
% you'll find a beautiful XOR classification pattern.
% 
% Input variables:
% xvec: test signal (input vector) in xy coordinates, such as [x;y;z]
% delta: constant for kernels (sorry, actually this should be "sigma" :))
% Cmax: parameter C in Karush-Kuhn-Tucker (KKT) condition for soft-margin SVM
% loop: maximum number of iteration if SMO does not converge
%
% The code works for not only 3D data, but also data with more dimension.
% If you want to learn more about SVM and its principles, please see
% "An Introduction to Support Vector Machines (and other kernel-based
% learning methods)" (ISBN: 0 521 78019 5) by Nello Christianini.
% Very unfortunately, I have only a Japanese translated version...
% 
%%%%%%%%%%%%%%%%
% About Matlab %
%%%%%%%%%%%%%%%%
% Matlab(c) is a commercial package of scientific / mathematical / linear
% algebraic programming language and IDE.
% As a programming language, Matlab is incredibly loose; there are less
% restriction than native C, but it is similar to native C. Most of native
% C grammer are included in Matlab. Even Matlab has its own compiler for
% native C / C++ in order to apply C / C++ codes.
% Indeed, Matlab is looser than native C; for example, Matlab does not
% require any declaration of variables (if you want to initialize any
% variables, just use "zeros" function to create all-zero matrices).
% If you want to port this code to Java or other programming languages,
% keep aware of such a characteristic and just consider it as a prototype
% of the algorithm.

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setting training signals %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, "ones" function provides all-one matrices as base signals.
% Second, "rand" function adds some fluctuation to the base signals.
% Thus we have four 3 x 10 matrices as the training signals.

% c is a coefficient for "rand" function that controls magnitude of
% fluctuation of training signals.
% Each column means xy coordinates of each training signal and each row
% means an index of the signals.

c=1.5;

% XOR nonlinear samples in 3D
x1_list=[[ones(1,15)+c*rand(1,15);ones(1,15)+c*rand(1,15);2*ones(1,15)+c*rand(1,15)] ...    % 1st quadrant positive
    [-1*ones(1,15)+c*rand(1,15);ones(1,15)+c*rand(1,15);-2*ones(1,15)+c*rand(1,15)] ...     % 2nd quadrant negative
    [-1*ones(1,15)+c*rand(1,15);-1*ones(1,15)+c*rand(1,15);2*ones(1,15)+c*rand(1,15)] ...   % 3rd quadrant positive
    [ones(1,15)+c*rand(1,15);-1*ones(1,15)+c*rand(1,15);-2*ones(1,15)+c*rand(1,15)]]; ...   % 4th quadrant negative
    
x2_list=[[ones(1,15)+c*rand(1,15);ones(1,15)+c*rand(1,15);-2*ones(1,15)+c*rand(1,15)] ...   % 1st quadrant negative
    [-1*ones(1,15)+c*rand(1,15);ones(1,15)+c*rand(1,15);2*ones(1,15)+c*rand(1,15)] ...      % 2nd quadrant positive
    [-1*ones(1,15)+c*rand(1,15);-1*ones(1,15)+c*rand(1,15);-2*ones(1,15)+c*rand(1,15)] ...  % 3rd quadrant negative
    [ones(1,15)+c*rand(1,15);-1*ones(1,15)+c*rand(1,15);2*ones(1,15)+c*rand(1,15)]]; ...    % 4th quadrant positive
    
c1=size(x1_list,2); % The number of x1_list
c2=size(x2_list,2); % The number of x2_list
clength=c1+c2; % The number of all training signals

% Training label: 1 for x1 and -1 for x2
x_list=[x1_list x2_list]; % Binding training signals of x1 and x2
y_list=[ones(c1,1);-1*ones(c2,1)]; % Binding training labels of x1 and x2

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initializing variables %
%%%%%%%%%%%%%%%%%%%%%%%%%%
% "zeros" function provides all-zero matrices or vectors.

% Lagrange multiplier "alpha" (see Christianini's textbook for details)
alpha=zeros(clength,1);
% Learning rate (see Christianini's book: usually 0-2)
learn_stlength=0.5;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimating & training Lagrange multiplier "alpha" by SMO %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here we estimate Lagrange multiplier "alpha" by SMO.
% That is, this is a training process.
% In this process, we have to solve a convex quadratic programme such as to
% estimate "alpha" that meets the KKT condition while keeping a "linear
% restriction" as alpha'*y_list = 0.
% (See Christianini's textbook)

% If you want to solve the Lagrange multiplier programme in line with KKT
% condition, training signals "x_list", training labels "y_list",
% initialized Lagrange multiplier "alpha" (all-zero vector), kernel
% parameter delta (actually this should be sigma, sorry!), the number of
% signals "clength", learning rate "learn_stlength", maximum number of
% iteration "loop" are required. Please see comments in "tjo_smo" function,
% but DO NOT EDIT "tjo_smo". (It is too complicated)

[alpha,bias]=tjo_smo(x_list,y_list,alpha,delta,Cmax,clength,learn_stlength,loop);

% Thus we obtain both "alpha" and "bias".
% Using them, now we can compute a discriminant function.

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computing a weight vector %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here we need a weight vector "wvec" required to compute a discriminant
% function f(x) = w'x.
% "wvec" can be computed with the training labels "y_list" and Lagrange
% multiplier "alpha".

wvec=tjo_svm_classifier(y_list,alpha,clength);

% Now we can run SVM; let's input "wvec" and "bias" to "tjo_svm_trial"
% function, the discriminant function.

%%
%%%%%%%%%%%%%%%%%%%
% Trial (testing) %
%%%%%%%%%%%%%%%%%%%
% Here we can compute a discriminant function from estimated weight vector
% "wvec" and "bias", and then we can obtain a classification value "new_m"
% from the input vector (test signal) "xvec".
% If new_m > 0, xvec should be in "Group 1" or if new_m < 0, xvec should be
% in "Group 2". "tjo_svm_trial" function returns "new_m" and shows a result
% of classification on the command line.

new_m=tjo_svm_trial(xvec,wvec,x_list,delta,bias,clength);

% In case that SMO is forced to terminate, let's compute alpha'*y_list in
% order to check the linear restriction (alpha'*y_list = 0).
linear_index=y_list'*alpha;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting & visualization %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Almost all functions are original in Matlab...
figure(1);

for i=1:c1
    if(alpha(i)==0)
        scatter3(x_list(1,i),x_list(2,i),x_list(3,i),200,'ko');hold on;
    elseif(alpha(i)>0)
        scatter3(x_list(1,i),x_list(2,i),x_list(3,i),200,[127/255 0 127/255]);hold on;
    end;
end;

for i=c1+1:c1+c2
    if(alpha(i)==0)
        scatter3(x_list(1,i),x_list(2,i),x_list(3,i),200,'k+');hold on;
    elseif(alpha(i)>0)
        scatter3(x_list(1,i),x_list(2,i),x_list(3,i),200,[127/255 0 127/255],'+');hold on;
    end;
end;

if(new_m > 0)
    scatter3(xvec(1),xvec(2),xvec(3),600,'ro');hold on;
elseif(new_m < 0)
    scatter3(xvec(1),xvec(2),xvec(3),600,'r+');hold on;
else
    scatter3(xvec(1),xvec(2),xvec(3),600,'bo');hold on;
end;

xlim([-3 3]);
ylim([-3 3]);
zlim([-4 4]);

[xx,yy,zz]=meshgrid(-3:0.1:3,-3:0.1:3,-3:0.1:3);
[cxx,cxx,cxx]=size(xx);
mm=zeros(cxx,cxx,cxx);
V=[];
for p=1:cxx
    for q=1:cxx
        for r=1:cxx
            mm(p,q,r)=tjo_svm_trial_silent([xx(p,q,r);yy(p,q,r);zz(p,q,r)],wvec,x_list,delta,bias,clength);
            if(abs(mm(p,q,r))<0.2)
                V=[V [xx(p,q,r);yy(p,q,r);zz(p,q,r)]];
            end;
        end;
    end;
end;

scatter3(V(1,:),V(2,:),V(3,:),5,'green','+');hold on;


end