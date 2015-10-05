function [vmin, vmax, diagnostic] = solve_Interval(constraints, flux, options)

% solve_interval — Solve an interval MFA problem.
% 
% Syntax
% [vmin, vmax] = solve_interval(constraints,flux);
% [__, __, diagnostic]=solve_interval(__, __, options);
% 
% Description
% [vmin, vmax]=solve_interval(constraints, flux, options) returns 
% the column vectors vmin and vmax, which define the interval estimates for
% the fluxes that have been asked. Regarding the inputs, the constraints are 
% a YALMIP struct with a set of constraints for interval MFA problem. 
% 
% Flux is a vector with the indexes of the fluxes to be estimated. 
% options is an optional input that allows to specify the YALMIP solver options 
% (use ‘help yalmip’ for details). 
% 
% 
% Additional information, please visit https://github.com/kikollan/PFA-Toolbox
%
%============================================================================================

% use default values, if needed
if (nargin < 3)    options = []; end

% find the minimun value fulfilling the constraints
solvesdp(constraints,flux,options);
vmin = double(flux);

% find the maximum value fulfilling the constraints
solmax=solvesdp(constraints,-flux, options);
vmax = double(flux);

% get info from optimisation diagnostics
diagnostic.details = solmax.info;
diagnostic.error = solmax.problem;

% check error: if there is an error, rise a warning
if (solmax.problem ~= 0)
    warning('There was a problem solving the PossMFA problem. Please review the diagnostic output.');
end
