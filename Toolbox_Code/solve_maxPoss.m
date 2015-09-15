function [v,poss,diagnostic] = solve_maxPoss(PossProblem,options)
%  
% solve_maxPoss — Returns one flux vector estimate of maximum possibility.
% 
% Syntax
% [v,poss] = solve_maxPoss(PossProblem);
% [v, poss, diagnostic] = solve_maxPoss(PossProblem, options);
% 
% Description
% [v, poss]=solve_maxPoss(PossProblem) returns the column vector v with a set
% of fluxes with maximum possibility. Notice, however, that it could more than
% one flux vector with maximum possibility, and the solver returns only one 
% of them. To know if there are multiple candidates, use solve_maxPossInterval.
% The only mandatory input is PossProblem, a structure defining the
% Possibilistic MFA problem (see define_MEC and define_MOC). 
% The optional input “options” specifies the YALMIP options 
% (see ‘help yalmip’). 
% The optional output “diagnostic” returns information about the solver status
% (see ‘help yalmiperror’). “diagnostic.error” indicates if the problem was 
% successfully solved (it return ‘0’ if the problem is successfully solved,
% ‘1’ if the problem is infeasible, etc. See ‘yalmiperror’).
% “diagnostic.details” provides all the info returned by the optimization solver.
% 
%  See also   define_MEC
% 
% Additional information, please visit http://www.possmfa.edu
%
%=======================================================================================

% if single input, use default values
if (nargin==1)    options=[];	end

% solve the optimization problem (with YALMIP)
sol=solvesdp(PossProblem.CB, PossProblem.J, options);

% get the results to be returned: fluxes and its possibility
v    = double(PossProblem.v);
poss = exp(-double(PossProblem.J));

% get info from optimisation diagnostics
diagnostic.details = sol.info;
diagnostic.error = sol.problem;

% check error: if there is an error, rise a warning
if (sol.problem ~= 0)
    warning('There was a problem solving the PossMFA problem. Please review the diagnostic output.');
end