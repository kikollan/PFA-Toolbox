% EXAMPLE 1. INTERVAL METABOLIC FLUX ANALYSIS
% 
% This example show how use the PFA TOOLBOX to solve a problem with the 
% Interval MFA approach.It present a metabolic network with Six (6) fluxes
% and three (3) metabolites. There are two (2) fluxes measured. 
%
% The example cover:
% 
% 1. PROBLEM FORMULATION
% 2. INTERVAL FLUX ESTIMATION
% 3. GRAPHICAL REPRESENTATION
%
% For additional information, please visit https://github.com/kikollan/PFA-Toolbox
%
%===========================================================================

%% 1. PROBLEM FORMULATION

% define model:model stoichiometry 
model.S=[-1  1  0 -1  0  0;
          1  0  1  0 -1  0;
          0 -1 -1  0  0  1];
          
% define model: reversibility for each reaction/flux
model.rev=[0 0 0 1 0 0];  

% define flux variables using yalmip sintax
v  = sdpvar(6,1);

% generate the contraint base, CB: stoichiometry and reversibilities
CB = [model.S*v==0];
CB = [CB, diag(not(model.rev))*v>=0];

% add bounds for all fluxes (if desired)
CB = [CB, v<=1000];
CB = [CB, v>=0];

% add measurements as intervals
CB = [CB,   9<= v(4) <=12];
CB = [CB, 9.25<= v(6) <= 9.75];

%% 2. INTERVAL FLUX ESTIMATION

% compute interval solution for flux 3
[vmin, vmax, diagnostic]=solve_Interval(CB, v(3));

% compute interval solution for flux all fluxes
for i=1:6
    [vmin(i,:),vmax(i,:)]=solve_Interval(CB,v(i));
end

%% 3. GRAPHICAL REPRESENTATION

% Plot the interval solution for all fluxes.
figure
 plot_intervals([1 2 3 4 5 6],vmin,vmax)
 axis square            
 xlabel('flux'),ylabel('Values')
