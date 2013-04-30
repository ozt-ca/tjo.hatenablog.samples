function [yvec,wvec]=tjo_perceptron_3d_main_procedure(xvec0)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perceptron for 3D data by Takashi J. OZAKI %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a very simple implementation of "perceptron".
% The code works for not only 3D data, but also data with more dimension.
% For example, just type as follows and run.
% [yvec,wvec]=tjo_perceptron_3d_main_procedure([3;3;3])

% In general, this code implements basic principles described in Ch2 of
% "An Introduction to Support Vector Machines (and other kernel-based
% learning methods)" (ISBN: 0 521 78019 5).
% Very unfortunately, I have only a Japanese translated version...

% I coded this based on a primal form of perceptron for simplification.
% For describing such machine learning algorithm, we can choose either
% (1) "primal form" or (2) "dual expression".
% Actually coding in dual expression would be more important especially
% in case of support vector machine (SVM), but in this code I omitted it.
% For the same reason, I omitted "margin maximization".
% FYI: if you want to implement margin maximization, you should code
% rather SVM than perceptron. :)

% Simply speaking, perceptron works with the following algorithm.
% Imagine the following discriminant function;
% 
% y = w'x + b@(y: output, w: weight vector, x: input vector, b: bias)
% 
% The output y is given by a sum of an inner product w' * x and bias b.
% Whether y is larger than 0 or not classifies the input vector to one of
% two preset classes. (Imagine a vector either below or above a simple
% linear function)
% Perceptron serially and gradually updates the weight vector w with
% "training signals"; this is a basic principle.

% Here I show how perceptron updates the weight vector with training
% signals: let's see "hinge loss function" and "steepest descent method".
% Hinge loss function is as follows:
% 
% loss(w,x,t) = max(0, -tw'x)
% (w: weight vector, x: training vector, t: training label either 1 or -1)
% 
% Check signs of w'x and t: if they have the same sign (w'x > 0 & t > 0 or
% vice versa), tw'x > 0 therefore -tw'x < 0. In this case, loss(w,x,t) = 0.
% On the other hand, if they have the opposite signs, loss(w,x,t) = -tw'x.
% In this case, we have "loss" with a size |w'x| (because |t| = 1), and we
% have to modify the weight vector w based on -tw'x.
% 
% Next, let's see the steepest descent method.
% This method is the most popular algorithm for sequential optimization in
% most of machine learning method.
% This is very simple; First, assume the loss function above is a function
% of w. Second, set w as a function of a counter variable n (i.e. w(n)) of
% the training signal x (i.e. x(n)). Finally, if n->n+1, subtract a partial
% differential of the loss function from w(n) and return w(n+1).
% w(n+1) = w(n) - Ý/Ýw loss(w,x,t)
% 
% The partial differential of loss(w,x,t) is quite simple. In case of this
% code,
% 
% loss(w,x,t) = max(0, -tw'x) -> Ýloss(w,x,t) = max(0, -tx)
% 
% That means we have to add just tx only when the discriminant function
% returns the incorrect answer for each training signal, and we don't have
% to do anything if it returns the correct answer.
% So now we obtain the following expression for updating w(n):
% 
% w(n+1) = w(n)@(correct answer for each training signal)
% w(n+1) = w(n) + tx@(incorrect)
% 
% After some iteration (with appropriate criteria for terminating updating
% w(n)), we'll obtain the desirable weight vector w.
% 
% A hyperplane is described as w'x + b = 0. If w = (m,n), the hyperplane
% can be explicitly expressed as mx + ny + b = 0.
% 
% In this code, for simplification I keep bias to 1.

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setting training signals %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, "ones" function provides all-one matrices as base signals.
% Second, "rand" function adds some fluctuation to the base signals.
% Thus we have two 4 x 15 matrices as the training signals.
% They are in xyz coordinates with a fixed bias value (= 1).

% c is a coefficient for "rand" function that controls magnitude of
% fluctuation of training signals.
% Each column means xyz coordinates of each training signal and each row
% means an index of the signals.

c=8;

x1_list=[(1*ones(3,15)+c*rand(3,15));ones(1,15)]; % x1 (Group 1)
x2_list=[(-1*ones(3,15)-c*rand(3,15));ones(1,15)]; % x2 (Group 2)
c1=size(x1_list,2); % The number of x1_list
c2=size(x2_list,2); % The number of x2_list
clength=c1+c2; % The number of all training signals

% Training label: 1 for x1 and -1 for x2
x_list=[x1_list x2_list]; % Binding training signals of x1 and x2
t_list=[ones(c1,1);-1*ones(c2,1)]; % Binding training labels of x1 and x2
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initializing variables %
%%%%%%%%%%%%%%%%%%%%%%%%%%
% "zeros" function provides all-zero matrices or vectors.

wvec=[0;0;0;1]; % Initial weight vector
loop=1000; % The number of iteration

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Training: estimating the weight vector %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Just it repeats "loop" times.
% Of course, the while loop can be used with criteria of termination.

for j=1:loop
    for i=1:clength
        wvec=tjo_train(wvec,x_list(:,i),t_list(i)); % A function for training
    end;
    j=j+1;
end;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trial: classifying the input vector into one of two classes %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The fixed bias 1 should be added to the input vector "xvec0".
% Now we have a preprocessed input vector xvec (x).
xvec=[xvec0;1];

% Input the estimated weight vector (wvec) and the preprocessed input
% vector (xvec).
[t_label,yvec]=tjo_predict(wvec,xvec); % A function for classifying

% Its result appears on the command line depending on its sign.
if(t_label>0)
    fprintf(1,'Group 1\n\n');
elseif(t_label<0)
    fprintf(1,'Group 2\n\n');
else
    fprintf(1,'On the border\n\n');
end;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting & visualization %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Almost all functions are original in Matlab...

a=wvec(1);
b=wvec(2);
c=wvec(3);
d=wvec(4);

[xx,yy]=meshgrid(-10:.1:10,-10:.1:10);
zz=-(a/c)*xx-(b/c)*yy-(d/c);
figure;
mesh(xx,yy,zz);hold on;
scatter3(x1_list(1,:),x1_list(2,:),x1_list(3,:),500,'ko');hold on;
scatter3(x2_list(1,:),x2_list(2,:),x2_list(3,:),500,'k+');hold on;
if(t_label>0)
    scatter3(xvec(1),xvec(2),xvec(3),500,'ro');
elseif(t_label<0)
    scatter3(xvec(1),xvec(2),xvec(3),500,'r+');
else
    scatter3(xvec(1),xvec(2),xvec(3),500,'bo');
end;

xlim([-10 10]);ylim([-10 10]);zlim([-10 10]);

end