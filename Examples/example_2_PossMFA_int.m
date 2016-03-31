% EXAMPLE 2. POSSIBILISTIC INTRODUCTION

% This example presents the use of the PFA TOOLBOX to
% solve a problem with the Possibilistic MFA approach.
%
% It presents a metabolic network with six (6) fluxes and three (3) metabolites. 
% There are two (2) fluxes measured. 
%
% The example presents:
% 
% 1.	PROBLEM FORMULATION
% 2.	PLOT DEFINED MEASURES
% 3.	FLUX ESTIMATIONS AND PLOT COMPUTED ESTIMATIONS
%         - Compute a Point–wise estimation
% 	      - Compute an interval estimation with maximum possibility
%         - Compute Interval estimates for specific possibilities of 0.5,0.8,1
%         - Plot interval estimates for specific possibilities of 0.5,0.8,1
% 	      - Compute a distribution as estimation
%         - Plot distribution estimations
%
% For additional information, please visit http://kikollan.github.io/PFA-Toolbox
%
%===============================================================================

%% 1. PROBLEM FORMULATION 

%clear all
% Define model: model stoichiometry
model.S=[-1  1  0 -1  0  0;
          1  0  1  0 -1  0;
          0 -1 -1  0  0  1];

% Define model: irreversibility for each flux 
model.rev=[0 0 0 1 0 0];

% Initialize the possibilistic problem with the model constraints
[PossProblem] = define_MOC(model);

% Measured fluxes and their uncertainty in possibilistic terms:
PossMeasurements.wm    = [9.5  10.5]';
PossMeasurements.e2max = [0.25 1.5]';
PossMeasurements.m2max = [0.25 1.5]';
PossMeasurements.alpha = [2    0.15]';
PossMeasurements.beta  = [2    0.15]';


%% 2. PLOT DEFINED MEASURES

% Now you can plot the measures, as have been defined:
figure
index = [4 6];  % Measured fluxes in the model
for f=[1:6]
    subplot(2,3,f), xlim([0 50]), hold on
    m=find(index==f);
    if(not(isempty(m)))
     [x,y] = plot_PossMeasurements(PossMeasurements, m);
         plot(x,y,'b--')
    end
    xlabel('flux'),ylabel('Poss')
end

%% 3. FLUX ESTIMATION

% Extend the possibilistic problem adding the measurements-constraints
index = [4 6]; % Measured fluxes in the model
[PossProblem] = define_MEC(PossProblem, PossMeasurements, index);

% Perform a point_wise estimation (an unreliable estimate)
[v, poss]=solve_maxPoss(PossProblem);

% Perform an interval estimation with maximum possibility
[vmin,vmax]=solve_maxPossIntervals(PossProblem);

% Interval estimates for specific possibilities of 0.5, 0.8, 1
fluxes = [1 2 3 4 5 6];
for f=fluxes
    [min2(f), max2(f)]=solve_PossInterval(PossProblem,[1],f);
    [min3(f), max3(f)]=solve_PossInterval(PossProblem,[0.8],f);
    [min4(f), max4(f)]=solve_PossInterval(PossProblem,[0.5],f);
end

% Plot these estimations for specific possibilities of 0.5, 0.8, 1
figure
plot_intervals(fluxes,min2,max2,min3,max3,min4,max4);
xlabel('Reaction'),ylabel('Flux')
title({'Interval estimates for every flux';'three especific possibilities (0.5,0.8,1)'})

% Compute a posibility distrubution
possibilities = [0.05:0.05:1];
fluxes = [1 2 3 4 5 6];
for f=fluxes
    [min_p(:,f), max_p(:,f)]=solve_PossInterval(PossProblem,possibilities,f);
end

% Plot a posibility distribution
figure
for f=fluxes
    subplot(2,3,f), hold on
    [x,y] = plot_distribution(min_p(:,f),max_p(:,f),possibilities);
    plot(x,y,'k','lineWidth',2)
    xlim([0 50])
    if(find(index==f))
        [x,y] = plot_PossMeasurements(PossMeasurements, find(f==index));
        plot(x,y,'b--')
    end
     xlabel('Flux'),ylabel('Poss')
end
