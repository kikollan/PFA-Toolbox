function [vmin, vmax, diagnostic] = solve_maxPossIntervals(PossProblem, options)
% 
% solve_maxPossIntervals — Returns the interval estimate of fluxes with
%                           maximum possibility.
%                            
% Syntax
% [vmin,vmax]=solve_maxPossIntervals(PossProblem);
% [vmin, vmax, diagnostic] = solve_maxPossIntervals(PossProblem, options);
% 
% Description
% [vmin, vmax]=solve_maxPossIntervals(PossProblem) returns the interval 
% estimate with maximum possibility in vectors vmin, and vmax, which contain
% the lower and upper limits for each flux. The only mandatory input is
% PossProblem, a structure defining the Possibilistic MFA problem 
% (see define_MEC and define_MOC).
% The optional input “options” specifies the YALMIP solver options
% (see ‘help yalmip’). 
% The optional output “diagnostic” returns information about the solver status
% (see ‘help yalmiperror’). “diagnostic.error” indicates if the problem was 
% successfully solved (it return ‘0’ if the problem is successfully solved,
% ‘1’ if the problem is infeasible, etc. See ‘yalmiperror’).
% “diagnostic.details” provides all the info returned by the optimization solver.
% 
% See also   define_MEC, define_MOC
% 
% Additional information, please visit http://www.possmfa.edu
%
%==============================================================================================

% if single input, use default values
if (nargin==1)    options=[];	end

% init empty variables
vmin=[];
vmax=[];

% for each flux...
for i=1:length(PossProblem.v)
    
    % compute its min & max value with full conditional possibility for flux v(i)
    [vmin_i, vmax_i,diagnostic]=solve_PossIntervalYMP(PossProblem.CB, PossProblem.J, 1, PossProblem.v(i), 'cond', options);
    
    %outputs
    vmin = [vmin; vmin_i];
    vmax = [vmax; vmax_i];
end
