function [vmin,vmax,diagnostic] = solve_PossInterval(PossProblem,poss,flux,mode,options)
% 
% solve_possInterval — Returns an interval estimate for a flux for the
%                       desired degree of possibility.
%                        
% Syntax
% [vmin, vmax]=solve_PossInterval(PossProblem, poss, flux);
% [vmin, vmax]=solve_PossInterval(PossProblem, poss, flux, mode);
% [vmin, vmax, diagnostic]=solve_PossInterval(PossProblem, poss, flux, mode, options);
% 
% Description
% [vmin, vmax, diagnostic]=solve_PossInterval(PossProblem, poss, flux) returns 
% an interval estimate for a flux, for the desired degree of conditional 
% possibility. The vectors vmin and vmax contain the upper and lower limits
% of the flux of interest for the degrees of possibility specified as input. 
% The input PossProblem is a structure defining the Possibilistic MFA problem
% (see define_MEC and define_MOC). The vector poss indicates the degree of 
% possibility for the intervals that you want to compute (e.g., 0.8, or [0.99 0.8 0.1], etc.).
% Flux indicates the index of the flux to be estimated. 
% 
% Example. [vmin, vmax]= solve_PossInterval (ProblemA, [0.99 0.5 0.1], 7)
% computes three interval estimates for the flux 7 in the ProblemA, for 
% conditional of possibilities 0.99, 0.5 and 0.1.
% 
% The optional input “mode” can be used to get estimates of marginal possibility,
% instead of conditional possibility. If mode is not provided, the function
% provides conditional possibilities as a default. 
% The optional input “options” specifies the YALMIP solver options (see ‘help yalmip’). 
% The optional output “diagnostic” returns information about the solver status
% (see ‘help yalmiperror’). “diagnostic.error” indicates if the problem was 
% successfully solved (it return ‘0’ if the problem is successfully solved,
% ‘1’ if the problem is infeasible, etc. See ‘yalmiperror’). 
% “diagnostic.details” provides all the info returned by the optimization solver.
% 
% See also   define_MEC, define_MOC
% 
% Additional information, please visit https://github.com/kikollan/PFA-Toolbox
%
%====================================================================================================

% check inputs, process and use defaults if necessary
if (nargin==5)
    if (strcmp(mode,'') || isempty(mode))
        mode = 'cond';
    end
elseif (nargin==4)
	if (strcmp(mode,'') || isempty(mode))
        mode = 'cond';
    end
    options=[];
    
elseif (nargin==3)
    options=[];
    mode = 'cond';
end

%check: transform row vectors into column vectors 
  if(isrow(poss)==0)     poss=poss';  end
    
% compute the min & max value with the desired possibility for the flux of interest
[vmin, vmax,diagnostic]=solve_PossIntervalYMP(PossProblem.CB, PossProblem.J, poss, PossProblem.v(flux), mode, options);
vmin = vmin'; 
vmax = vmax';
