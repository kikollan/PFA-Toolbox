function [PossProblem] = define_MOC(model)
% 
% define_MOC — Generate the constraint-based model structure.
% 
% Syntax
% [PossProblem] = define_MOC(model)

% Description
% [PossProblem] = define_MOC(model) returns a struct that defines the
% Possibilistic MFA problem. Initially, it contains some symbolic decision
% variables (the fluxes v) and the first constraints into the CB 
%(the stoichiometry and the irrerversibilities). The function receives
% as input another struct, model. This struct can be a COBRA model 
% —it has the same fields— or be created by the user. The struct is a 
% simple one, containing the following: 
% 
% model.S	 The stoichiometric matrix.
% model.rev	 A vector indicating which reactions are reversible with ‘1’ for those reversible and ‘0’ otherwise.
% model.lb	(optional) Lower bound for each flux.
% model.ub	(optional) Upper bound for each flux.
% 
% For additional information, please visit https://github.com/kikollan/PFA-Toolbox
%
% ==========================================================================================

% extract N and irrev from the model structure
N=full(model.S);
irrev=not(model.rev);

% create flux variables for the possibilistic problem
PossProblem.v = sdpvar(size(N,2),1);

% define MEC constraints given by the model, 
% and add to them to the contraint-base struct (CB)
PossProblem.CB = [                  N*PossProblem.v==0];
PossProblem.CB = [PossProblem.CB,   diag(irrev)*PossProblem.v>=0];

% if upper and lower bounds are given, include them
if (isfield(model,'ub') && isfield(model,'lb'))
    
  %check: transform row vectors into column vectors
   if iscolumn(model.lb)==0;
      model.lb=model.lb';
   end
   if iscolumn(model.ub)==0;
      model.ub=model.ub';
   end

  % add bounds to the constraint-base
    lb=model.lb;
    ub=model.ub;
    
    PossProblem.CB = [PossProblem.CB,   PossProblem.v>=lb];
    PossProblem.CB = [PossProblem.CB,   PossProblem.v<=ub];
    
end
