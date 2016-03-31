% EXAMPLE 1. INTERVAL METABOLIC FLUX ANALYSIS
% 
% This example shows how to use the PFA TOOLBOX to solve a problem with the 
% Interval MFA approach.
%
% It presents a metabolic network with six (6) fluxes
% and three (3) metabolites. There are two (2) fluxes measured. 
%
% The example covers:
% 
% 1. PROBLEM FORMULATION
% 2. INTERVAL FLUX ESTIMATION
% 3. GRAPHICAL REPRESENTATION
%
% For additional information, please visit http://kikollan.github.io/PFA-Toolbox
%
%===========================================================================

%% 1. PROBLEM FORMULATION

clear all
% Define model: model stoichiometry 
model.S=[-1  1  0 -1  0  0;
          1  0  1  0 -1  0;
          0 -1 -1  0  0  1];
          
% Define model: reversibility for each reaction/flux
model.rev=[0 0 0 1 0 0];  

% Define flux variables using yalmip sintax
v  = sdpvar(6,1);

% Generate the contraint base, CB: stoichiometry and reversibilities
CB = [model.S*v==0];
CB = [CB, diag(not(model.rev))*v>=0];

% Add bounds for all fluxes (if desired)
CB = [CB, v<=1000];
CB = [CB, v>=0];

% Add measurements as intervals
CB = [CB,   9<= v(4) <=12];
CB = [CB, 9.25<= v(6) <= 9.75];

%% 2. INTERVAL FLUX ESTIMATION

% Compute interval solution for flux 3
[vmin, vmax, diagnostic]=solve_Interval(CB, v(3));

% Compute interval solution for all fluxes
for i=1:6
    [vmin(i,:),vmax(i,:)]=solve_Interval(CB,v(i));
end

%% 3. GRAPHICAL REPRESENTATION

% Plot the interval solution for all fluxes
figure
plot_intervals([1 2 3 4 5 6],vmin,vmax)
axis square            
xlabel('Reaction'),ylabel('Flux')
