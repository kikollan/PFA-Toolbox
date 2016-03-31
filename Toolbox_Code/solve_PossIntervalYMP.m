function [vmin, vmax] = solve_PossIntervalYMP(F, J, poss, var, mode, options)
% 
% solve_PossIntervalYMP  — Returns an interval estimate for a flux for the 
%                           desired degree of possibility. This function uses
%                           a different and rudimentary syntax. It is of use
%                           only for advanced users wanting to do non-standard
%                           computations.
%                           
% Syntax
% [vmin,vmax,diagnostic]=solve_PossIntervalYMP(F,J,poss,var); 
% [__,__,__] = solve_PossIntervalYMP (__,__,__,__,mode);
% [__,__,__] = solve_PossIntervalYMP (__,__,__,__,options);
% 
% Description
% This function uses a different and rudimentary syntax. It is of use only for
% advanced users wanting to do non-standard computations. 
%
% [vmin, vmax]=solve_PossIntervalYMP(F, J, poss, var) returns an interval 
% estimate for a flux, for the desired degree of conditional possibility. 
% The vectors vmin and vmax contain the upper and lower limits of the flux of
% interest for the degrees of possibility specified as input. 
% 
% The input F is a YALMIP structure defining a set of constraints. J is a
% YALMIP object function defining the possibility of each candidate solution 
% of F. The vector poss indicates the degree of possibility of the intervals
% that you want to compute (e.g., 0.8, or [0.99 0.8 0.1], etc.). 
% 
% Finally, var is the variable —typically a flux— that you want to estimate.
% 
% The optional input “mode” can be used to get estimates of marginal possibility,
% instead of conditional possibility. If mode is not provided, the function
% provides conditional possibilities as a default.
% 
% The optional input “options” specifies the YALMIP solver options (see ‘help yalmip’). 
% 
% 
% Additional information, please visit http://kikollan.github.io/PFA-Toolbox
%
%=============================================================================================================================================

% if needed, use default values
if (nargin < 5)
    mode = 'none';
	options = [];
elseif(nargin < 6)
	options = [];
end

% auxiliar variable to avoid numeric problems
quasiZero = 0.00001;

% compute the most possible solution (using YALMIP)
sol  = solvesdp(F,J, options);
maxJ = double(J);

% define the optimization problems parameterized with x
% (this way, computation is faster.
%  read YALMIP help for info about this procedure.)
x = sdpvar(1,1);
if (strcmp(mode,'cond'))     F1=[F, J-maxJ<=x+quasiZero]; % conditional possibility
else                         F1=[F, J     <=x+quasiZero];       
end

% check: if var is not an sdpvar --we assume is a constant--, we return its value
info = whos('var');
if (info.class ~= 'sdpvar')
    CI = [var var];
    return;
end

% define the optimization problem for min and max computation (parameterized)
optimiz_min = optimizer(F1, var,options,x,var);
optimiz_max = optimizer(F1,-var,options,x,var);

% compute min and max for each level of possibility
vmin = []; vmax = [];
for gamma=poss
    [aux_max, infeas_max] = optimiz_max{-log(gamma)};
    [aux_min, infeas_min] = optimiz_min{-log(gamma)};
	vmax=[vmax [aux_max]];
    vmin=[vmin [aux_min]];
end

% check error: if there is an error, rise a warning
if (or (infeas_max ~= 0, infeas_min ~= 0) )
    warning('Trying to run again with quasiZero=0.005. If you are using "linprog" as LP, you should try another solver, such as GPLK or CPLEX.');
    
    % rerun with larger tolerance...
    quasiZero = 0.005;  
    x = sdpvar(1,1);
    if (strcmp(mode,'cond'))     F1=[F, J-maxJ<=x+quasiZero]; % conditional possibility
    else                         F1=[F, J     <=x+quasiZero];       
    end
    optimiz_min = optimizer(F1, var,sdpsettings('verbose',2),x,var);
    optimiz_max = optimizer(F1,-var,sdpsettings('verbose',2),x,var);
    vmin = []; vmax = [];
    for gamma=poss
        [aux_max, infeas_max] = optimiz_max{-log(gamma)};
        [aux_min, infeas_min] = optimiz_min{-log(gamma)};
        vmax=[vmax [aux_max]];
        vmin=[vmin [aux_min]];
    end
    
    % check error: if there is  still an error, rise a warning
    if (or (infeas_max ~= 0, infeas_min ~= 0) )
        warning('CAUTION: There was a problem solving an optimization problem. The problem may be infeasible or unbounded. If you are using "linprog" as LP, you should try another solver, such as GPLK or CPLEX.');
    end
    
end
