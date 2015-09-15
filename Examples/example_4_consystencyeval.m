% EXAMPLE 4.  EVALUATE CONSISTENCY

% This example show a brief introduction about how define and evaluate 
% consistency with PFA TOOLBOX 
% It present four (4) measurements, with different uncertainties. 
% The example cover:

% 1.    PROBLEM FORMULATION
% 2.    POSSIBILITY ESTIMATION 
% 3.    FLUX DISTRIBUTION AS ESTIMATION
% 4.    PLOT FLUX DISTRIBUTION ESTIMATIONS AND MEASUREMENTS DISTRIBUTIONS
%
% For additional information, please visit http://www.possmfa.edu
%
%=====================================================================================
%
%% 1. PROBLEM FORMULATION
clear all
% define model. stoichometric matrix
model.S=[-1 1 0 -1 0 0;
          1 0 1 0 -1 0;
          0 -1 -1 0 0 1];
%define model. irreversibilities
model.rev=[0 0 0 1 0 0];

%upper and lower bounds for each flux -Non Compulsory-
model.lb=-[0    0      0  1000  0     0];
model.ub=[1000 1000 1000 1000 1000 1000];

% Init the Possibilistic problem with Model constraints
[PossProblem] = define_MOC(model);

%define the measurements and its uncertainty

index    =[ 2      3     4    6   ];
exp{1}.wm=[ 1.88  1.09  0.0	  2.16];
exp{2}.wm=[ 2.07  0.95  0.63  2.70];
exp{3}.wm=[ 1.72  1     1.48  2.90];
exp{4}.wm=[ 2.02  0.57  1.33  3.55]; 
exp{5}.wm=[ 2.32  1.13  2.62  3.52]; 
exp{6}.wm=[ 0.73  2.04  1.98  2.55];

intFP=[0.5];
intLP=[1.2];

%% 2.POSSIBILITY ESTIMATION 

% FOR loop:
%  -Define of measurements in possibilistic terms.
%  -Add the measurement constraints to the problem.
% - compute the maximum possibility for each dataset


 for i=1:length(exp)
 [PossMeasures]=define_PossMeasurements(exp{i}.wm,intFP,intLP);
 [PossProblem] = define_MEC(PossProblem, PossMeasures, index);
 [v, poss]=solve_maxPoss(PossProblem);
 poss_all(i)=[poss];
  i
 end

%% 3. Investigating the inconsistencies, flux distributions

% Define the measurements in posibilistc terms 
[PossMeasures]=define_PossMeasurements(exp{6}.wm,intFP,intLP);

% Add the he measurement constraint to the problem.
[PossProblem] = define_MEC(PossProblem, PossMeasures, index);

% compute the flux distirbution and a estimation.
possibilities = [0.01:0.01:0.439];
fluxes = [1 2 3 4 5 6];
for f=fluxes
    [min_p(:,f),max_p(:,f)]=solve_PossInterval(PossProblem,possibilities,f,'none');
end

%% 4.    PLOT FLUX DISTRIBUTION ESTIMATIONS AND MEASUREMENTS DISTRIBUTIONS

figure
for f=fluxes
    subplot(2,3,f), hold on
    [x,y] = plot_distribution(min_p(:,f),max_p(:,f),possibilities);
    plot(x,y,'k','lineWidth',2)
    xlim([0 5])
    if(find(index==f))
        [x,y] = plot_PossMeasurements(PossMeasures, find(f==index));
         plot(x,y,'b--')
         xlim([0 5])
    end
end
