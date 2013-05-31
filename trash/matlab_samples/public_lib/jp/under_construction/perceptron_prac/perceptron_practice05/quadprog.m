function [X,fval,exitflag,output,lambda]=quadprog(H,f,A,B,Aeq,Beq,lb,ub,X0,options,varargin) 
%QUADPROG Quadratic programming.  
%   X=QUADPROG(H,f,A,b) attempts to solve the quadratic programming problem: 
% 
%            min 0.5*x'*H*x + f'*x   subject to:  A*x = b  
%             x     
% 
%   X=QUADPROG(H,f,A,b,Aeq,beq) solves the problem above while additionally 
%   satisfying the equality constraints Aeq*x = beq. 
% 
%   X=QUADPROG(H,f,A,b,Aeq,beq,LB,UB) defines a set of lower and upper 
%   bounds on the design variables, X, so that the solution is in the  
%   range LB = X = UB. Use empty matrices for LB and UB 
%   if no bounds exist. Set LB(i) = -Inf if X(i) is unbounded below;  
%   set UB(i) = Inf if X(i) is unbounded above. 
% 
%   X=QUADPROG(H,f,A,b,Aeq,beq,LB,UB,X0) sets the starting point to X0. 
% 
%   X=QUADPROG(H,f,A,b,Aeq,beq,LB,UB,X0,OPTIONS) minimizes with the default  
%   optimization parameters replaced by values in the structure OPTIONS, an  
%   argument created with the OPTIMSET function.  See OPTIMSET for details.   
%   Used options are Display, Diagnostics, TolX, TolFun, HessMult, LargeScale,  
%   MaxIter, PrecondBandWidth, TypicalX, TolPCG, and MaxPCGIter. Currently,  
%   only 'final' and 'off' are valid values for the parameter Display ('iter' 
%   is not available). 
% 
%   X=QUADPROG(Hinfo,f,A,b,Aeq,beq,LB,UB,X0,OPTIONS,P1,P2,...) passes the  
%   problem-dependent parameters P1,P2,... directly to the HMFUN function 
%   when OPTIMSET('HessMult',HMFUN) is set. HMFUN is provided by the user.  
%   Pass empty matrices for A, b, Aeq, beq, LB, UB, XO, OPTIONS, to use the  
%   default values. 
% 
%   [X,FVAL]=QUADPROG(H,f,A,b) returns the value of the objective function at X: 
%   FVAL = 0.5*X'*H*X + f'*X. 
% 
%   [X,FVAL,EXITFLAG] = QUADPROG(H,f,A,b) returns an EXITFLAG that describes the 
%   exit condition of QUADPROG. Possible values of EXITFLAG and the corresponding  
%   exit conditions are 
% 
%     1  QUADPROG converged with a solution X. 
%     3  Change in objective function value smaller than the specified tolerance. 
%     4  Local minimizer found. 
%     0  Maximum number of iterations exceeded. 
%    -2  No feasible point found. 
%    -3  Problem is unbounded. 
%    -4  Current search direction is not a direction of descent; no further  
%         progress can be made. 
%    -7  Magnitude of search direction became too small; no further progress can 
%         be made. 
% 
%   [X,FVAL,EXITFLAG,OUTPUT] = QUADPROG(H,f,A,b) returns a structure 
%   OUTPUT with the number of iterations taken in OUTPUT.iterations, 
%   the type of algorithm used in OUTPUT.algorithm, the number of conjugate 
%   gradient iterations (if used) in OUTPUT.cgiterations, a measure of first  
%   order optimality (if used) in OUPUT.firstorderopt, and the exit message 
%   in OUTPUT.message. 
% 
%   [X,FVAL,EXITFLAG,OUTPUT,LAMBDA]=QUADPROG(H,f,A,b) returns the set of  
%   Lagrangian multipliers LAMBDA, at the solution: LAMBDA.ineqlin for the  
%   linear inequalities A, LAMBDA.eqlin for the linear equalities Aeq,  
%   LAMBDA.lower for LB, and LAMBDA.upper for UB. 
 
%   Copyright 1990-2004 The MathWorks, Inc.  
%   $Revision: 1.28.4.7 $  $Date: 2004/04/20 23:19:28 $ 
 
% Handle missing arguments 
 
defaultopt = struct('Display','final','Diagnostics','off',... 
   'HessMult',[],... % must be [] by default 
   'TolX',100*eps,'TolFun',100*eps,... 
   'LargeScale','on','MaxIter',200,... 
   'PrecondBandWidth',0,'TypicalX','ones(numberOfVariables,1)',... 
   'TolPCG',0.1,'MaxPCGIter','max(1,floor(numberOfVariables/2))'); 
 
% If just 'defaults' passed in, return the default options in X 
if nargin==1 && nargout == 1 && isequal(H,'defaults') 
   X = defaultopt; 
   return 
end 
 
if nargin  2 
   error('optim:quadprog:NotEnoughInputs', ... 
         'QUADPROG requires at least two input arguments.') 
end 
 
if nargin  10, options =[]; 
   if nargin  9, X0 = [];  
      if nargin  8, ub = [];  
         if nargin  7, lb = [];  
            if nargin  6, Beq = [];  
               if nargin  5, Aeq = []; 
                  if nargin  4, B = []; 
                     if nargin  3, A = []; 
                     end, end, end, end, end, end, end, end 
 
% Check for non-double inputs 
if ~isa(H,'double') || ~isa(f,'double') || ~isa(A,'double') || ... 
      ~isa(B,'double') || ~isa(Aeq,'double') || ... 
      ~isa(Beq,'double') || ~isa(lb,'double') || ... 
      ~isa(ub,'double') || ~isa(X0,'double') 
  error('optim:quadprog:NonDoubleInput', ... 
        'QUADPROG only accepts inputs of data type double.') 
end                      
                      
% Set up constant strings 
medium =  'medium-scale: active-set'; 
large = 'large-scale'; 
 
if nargout > 4 
   computeLambda = 1; 
else  
   computeLambda = 0; 
end 
 
% Options setup 
largescale = isequal(optimget(options,'LargeScale',defaultopt,'fast'),'on'); 
diagnostics = isequal(optimget(options,'Diagnostics',defaultopt,'fast'),'on'); 
switch optimget(options,'Display',defaultopt,'fast') 
case {'off', 'none'} 
   verbosity = 0; 
case 'iter' 
   verbosity = 2; 
case 'final' 
   verbosity = 1; 
case 'testing' 
   verbosity = Inf; 
otherwise 
   verbosity = 1; 
end 
mtxmpy = optimget(options,'HessMult',defaultopt,'fast'); 
% check if name clash 
if isequal(mtxmpy,'hmult') 
   warning('optim:quadprog:HessMultNameClash', ... 
           ['Potential function name clash with a Toolbox helper function:\n' ... 
            'Use a name besides ''hmult'' for your HessMult function to\n' ... 
            'avoid errors or unexpected results.']) 
end 
 
% Set the constraints up: defaults and check size 
[nineqcstr,numberOfVariablesineq]=size(A); 
[neqcstr,numberOfVariableseq]=size(Aeq); 
if isa(H,'double') && ( isempty(mtxmpy) ) 
   lengthH = length(H); 
else % HessMult in effect, so H can be anything 
   lengthH = 0; 
end 
 
numberOfVariables = ... 
    max([length(f),lengthH,numberOfVariablesineq,numberOfVariableseq]); % In case A or Aeq is empty 
ncstr = nineqcstr + neqcstr; 
 
if isempty(f), f=zeros(numberOfVariables,1); end 
if isempty(A), A=zeros(0,numberOfVariables); end 
if isempty(B), B=zeros(0,1); end 
if isempty(Aeq), Aeq=zeros(0,numberOfVariables); end 
if isempty(Beq), Beq=zeros(0,1); end 
 
% Expect vectors 
f=f(:); 
B=B(:); 
Beq=Beq(:); 
 
if ~isequal(length(B),nineqcstr) 
    error('optim:quadprog:InvalidSizesOfAAndB', ... 
          'The number of rows in A must be the same as the length of b.') 
elseif ~isequal(length(Beq),neqcstr) 
    error('optim:quadprog:InvalidSizesOfAeqAndBeq', ... 
          'The number of rows in Aeq must be the same as the length of beq.') 
elseif ~isequal(length(f),numberOfVariablesineq) && ~isempty(A) 
    error('optim:quadprog:InvalidSizesOfAAndF', ... 
          'The number of columns in A must be the same as the length of f.') 
elseif ~isequal(length(f),numberOfVariableseq) && ~isempty(Aeq) 
    error('optim:quadprog:InvalidSizesOfAeqAndf', ... 
          'The number of columns in Aeq must be the same as the length of f.') 
end 
 
[X0,lb,ub,msg] = checkbounds(X0,lb,ub,numberOfVariables); 
if ~isempty(msg) 
   exitflag = -2; 
   X=X0; fval = []; lambda = []; 
   output.iterations = 0; 
   output.algorithm = ''; % Not known at this stage 
   output.firstorderopt = []; 
   output.cgiterations = [];  
   output.message = msg; 
   if verbosity > 0 
      disp(msg) 
   end 
   return 
end 
 
caller = 'quadprog'; 
% Check out H and make sure it isn't empty or all zeros 
if isa(H,'double') && isempty(mtxmpy) 
   if norm(H,'inf')==0 || isempty(H) 
      % Really a lp problem 
      warning('optim:quadprog:NullHessian', ... 
              'Hessian is empty or all zero; calling LINPROG.') 
      [X,fval,exitflag,output,lambda]=linprog(f,A,B,Aeq,Beq,lb,ub,X0,options); 
      return 
   else 
      % Make sure it is symmetric 
      if norm(H-H',inf) > eps 
         if verbosity > -1 
            warning('optim:quadprog:HessianNotSym', ... 
                    'Your Hessian is not symmetric. Resetting H=(H+H'')/2.') 
         end 
         H = (H+H')*0.5; 
      end 
   end 
end 
 
% Use large-scale algorithm or not? 
% Determine which algorithm and make sure problem matches. 
 
%    If any inequalities,  
%    or both equalities and bounds,  
%    or more equalities than variables, 
%    or no equalities and no bounds and no inequalities 
%    or asked for active set (~largescale) then call qpsub 
if ( (nineqcstr > 0) || ... 
      ( neqcstr > 0 && (sum(~isinf(ub))>0 || sum(~isinf(lb)) > 0)) || ... 
      (neqcstr > numberOfVariables) || ... 
      (neqcstr==0 && nineqcstr==0 && ...  
          all(eq(ub, inf)) && all(eq(lb, -inf))) || ...  % unconstrained 
      ~largescale) 
   % (has linear inequalites  OR both equalities and bounds) OR  
   % ~largescale, then call active-set code 
   output.algorithm = medium; 
   if largescale  && ... 
         (  issparse(H)  || issparse(A) || issparse(Aeq) )% asked for sparse 
     warning('optim:quadprog:FullAndMedScale', ... 
              ['This problem formulation not yet available for sparse matrices.\n', ... 
               'Converting to full matrices and switching to medium-scale method.']) 
   elseif largescale % and didn't ask for sparse 
     warning('optim:quadprog:SwitchToMedScale', ... 
             ['Large-scale method does not currently solve this problem formulation,\n' ... 
              'switching to medium-scale method.']) 
   end 
   if ~isa(H,'double') || ( ~isempty(mtxmpy) )  
      error('optim:quadprog:NoHessMult', ... 
            'H must be specified explicitly for medium-scale algorithm: cannot use HessMult option.') 
   end 
   H = full(H); A = full(A); Aeq = full(Aeq); 
else % call sqpmin when just bounds or just equalities 
   output.algorithm = large; 
   if isempty(mtxmpy)  
     H = sparse(H); 
   end 
   A = sparse(A); Aeq = sparse(Aeq); 
end 
 
if diagnostics  
   % Do diagnostics on information so far 
   gradflag = []; hessflag = []; line_search=[]; 
   constflag = 0; gradconstflag = 0; non_eq=0;non_ineq=0; 
   lin_eq=size(Aeq,1); lin_ineq=size(A,1); XOUT=ones(numberOfVariables,1); 
   funfcn{1} = [];ff=[]; GRAD=[];HESS=[]; 
   confcn{1}=[];c=[];ceq=[];cGRAD=[];ceqGRAD=[]; 
   msg = diagnose('quadprog',output,gradflag,hessflag,constflag,gradconstflag,... 
      line_search,options,defaultopt,XOUT,non_eq,... 
      non_ineq,lin_eq,lin_ineq,lb,ub,funfcn,confcn,ff,GRAD,HESS,c,ceq,cGRAD,ceqGRAD); 
end 
 
% if any inequalities, or both equalities and bounds, or more equalities than bounds, 
%    or asked for active set (~largescale) then call qpsub 
if isequal(output.algorithm, medium) 
   if isempty(X0),  
      X0=zeros(numberOfVariables,1);  
   end 
   [X,lambdaqp,exitflag,output,dum1,dum2,msg]= ... 
      qpsub(H,f,[Aeq;A],[Beq;B],lb,ub,X0,neqcstr,... 
      verbosity,caller,ncstr,numberOfVariables,options,defaultopt);  
   output.algorithm = medium; % have to reset since call to qpsub obliterates 
    
elseif isequal(output.algorithm,large)  % largescale: call sqpmin when just bounds or just equalities 
    [X,fval,output,exitflag,lambda]=... 
        sqpmin(f,H,X0,Aeq,Beq,lb,ub,verbosity,options,defaultopt,computeLambda,varargin{:}); 
 
    if exitflag == -10  % Problem not handled by sqpmin at this time: dependent rows 
        warning('optim:quadprog:SwitchToMedScale', ... 
            ['Large-scale method does not currently solve problems with dependent equalities,\n' ... 
            'switching to medium-scale method.']) 
        if isempty(X0), 
            X0=zeros(numberOfVariables,1); 
        end 
        output.algorithm = medium; 
        if ~isa(H,'double') || ( ~isempty(mtxmpy)  ) 
            error('optim:quadprog:NoHessMult', ... 
                'H must be specified explicitly for medium-scale algorithm: cannot use HessMult option.') 
        end 
        H = full(H); A = full(A); Aeq = full(Aeq); 
 
        [X,lambdaqp,exitflag,output,dum1,dum2,msg]= ... 
            qpsub(H,f,[Aeq;A],[Beq;B],lb,ub,X0,neqcstr,... 
            verbosity,caller,ncstr,numberOfVariables,options,defaultopt); 
        output.algorithm = medium; % have to reset since call to qpsub obliterates 
    end 
end 
 
if isequal(output.algorithm , medium) 
   fval = 0.5*X'*(H*X)+f'*X;  
   if computeLambda 
       llb = length(lb);  
       lub = length(ub); 
       lambda.lower = zeros(llb,1); 
       lambda.upper = zeros(lub,1); 
       arglb = ~isinf(lb); lenarglb = nnz(arglb); 
       argub = ~isinf(ub); lenargub = nnz(argub); 
       lambda.eqlin = lambdaqp(1:neqcstr,1); 
       lambda.ineqlin = lambdaqp(neqcstr+1:neqcstr+nineqcstr,1); 
       lambda.lower(arglb) = lambdaqp(neqcstr+nineqcstr+1:neqcstr+nineqcstr+lenarglb); 
       lambda.upper(argub) = lambdaqp(neqcstr+nineqcstr+lenarglb+1: ... 
                                  neqcstr+nineqcstr+lenarglb+lenargub); 
   end 
   output.firstorderopt = [];  
   output.cgiterations = [];   
 
   if exitflag == 1 
     normalTerminationMsg = sprintf('Optimization terminated.');   
     if verbosity > 0 
       disp(normalTerminationMsg) 
     end 
     if isempty(msg) 
       output.message = normalTerminationMsg; 
     else 
       % append normal termination msg to current output msg 
       output.message = sprintf('%s\n%s',msg,normalTerminationMsg); 
     end 
   else 
     output.message = msg; 
   end 
    
end 