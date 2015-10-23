% ESCHERICHIA COLI CASE OF USE, USING THE TOOLBOX POSSMFA.
% 
% This example present some of the utilities of the PossMFA toolbox, using
% a metabolic model of the Core E. Coli Metabolic Model . The example
% contains an interval estimation of biomass flux of E. Coli under under six
% different experiments.  Additionally a consistency evaluation of the data 
% sets is also performed.
%
% The example cover:
% 
% 1.	PROBLEM FORMULATION
% 2.	INTERVAL FLUX ESTIMATIONS
% 3.	PLOT ESTIMATIONS.
% 4.	CONSISTENCY EVALUATION OF MEASUREMENTS.
% 5.	BIOMASS ESTIMATION WITH POSIBILISTIC MFA.
% 6.    PLOT ESTIMATIONS FOR THREE INTERVALS OF POSSIBILITY 0.1, 0.5, 0.99.
% 
% For additional information, please visit https://github.com/kikollan/PFA-Toolbox
%
%===================================================================================
%
%% 1. PROBLEM FORMULATION 


clear all

%charge stoichometric model
[DATA,TXT]=xlsread('File_2.xlsx','Network', '', 'basic');
model.rev = DATA(2,3:end);
model.S = DATA(3:74,3:end);
%define Upper and lower bounds
model.lb=DATA(76,3:end);
model.ub=DATA(77,3:end);

%define flux variables using YALMIP syntax.

v = sdpvar(95,1);

%generate the constraint base, CB

CB = [model.S*v==0];
CB = [CB, diag(not(model.rev))*v>=0];

for i=1:95
    
CB = [CB, model.lb(i) <= v(i) <= model.ub(i)];

end
% add the measurements,and the uncertainty
CB = [CB, 0.08 <= v(13) <= 0.1];
CB = [CB, -1.5 <= v(28) <= -1.3];
CB = [CB, -4.7 <= v(36) <= -4.5];
CB = [CB, 4.8 <= v(23) <= 5];
CB = [CB, 0 <= v(20) <= 0];
CB = [CB, 0 <= v(38) <= 0];

CB = [CB, v(89) <= 5];
CB = [CB, v(44) <= 5];

%% 2. INTERVAL FLUX ESTIMATION

for i=1:95
    
[vmin(i,:), vmax(i,:)] = solve_Interval(CB,v(i))
  
end

%% 3.	PLOT  INTERVAL ESTIMATIONS FOR ALL FLUXES

plot_intervals([1:95], vmin, vmax)
xlim([0 100])
ylim ([-6 12])
axis square
xlabel('flux'), ylabel('values')

%% 4.	CONSISTENCY EVALUATION OF MEASUREMENTS.
clear all

% charge model from XLS file
[DATA,TXT]=xlsread('File_2.xlsx','Network', '', 'basic');
model.rev = DATA(2,3:end);
model.S = DATA(3:74,3:end);

% define the model

[PossProblem] = define_MOC(model);

%define the measurements.
% With Growth

index = [13 28 36 23 20 38];

exp{1}.wm = [0.09   -1.4    -4.6    4.9     0   0];
exp{2}.wm = [0.4    -4.8    -11.8   12.4    0   0];
exp{3}.wm = [0.09    -2.2    -5.1   5.2    1.3   0.1];

exp{4}.wm = [0.08    -1.4    -5.5   5.6    0   0];
exp{5}.wm = [0.4    -5    -12.8   13.7    0   0];
exp{6}.wm = [0.08    -2.7    -7   6.3    1.2   0];

% Without Growth

index = [28 36 23 20 38];

exp{1}.wm = [-1.4    -4.6    4.9     0   0];
exp{2}.wm = [-4.8    -11.8   12.4    0   0];
exp{3}.wm = [-2.2    -5.1   5.2    1.3   0.1];

exp{4}.wm = [-1.4    -5.5   5.6    0   0];
exp{5}.wm = [-5    -12.8   13.7    0   0];
exp{6}.wm = [-2.7    -7   6.3    1.2   0];

i = 6;

%Adding uncertainty.
intFP = max(0.01, abs(exp{i}.wm*0.05));
intLP = max(0.02, abs(exp{i}.wm*0.2));

%Generate the possibilistic measures structure.
[measures] = define_PossMeasurements(exp{i}.wm, intFP, intLP);
[PossProblem] = define_MEC(PossProblem, measures, index);

% Calculate max posibility.
[v, poss] = solve_maxPoss(PossProblem);


%% 5.    BIOMASS ESTIMATION WITH POSIBILISTIC MFA.

%Develop interval estimates for three intervals of possibility 0.1, 0.5, 0.99

fluxes = [13]; %biomass flux in stoichometric model

for f = fluxes
    
    [vmin1(f), vmax1(f)] = solve_PossInterval(PossProblem, [0.99], f);
    [vmin2(f), vmax2(f)] = solve_PossInterval(PossProblem, [0.5], f);
    [vmin3(f), vmax3(f)] = solve_PossInterval(PossProblem, [0.1], f);

end

%%
%% PLOT ESTIMATIONS FOR THREE INTERVALS OF POSSIBILITY 0.1, 0.5, 0.99.

%Define biomass measures and interval estimation vector three intervals of
%possibility 0.1, 0.5, 0.99

g=[0.09 0.4 0.09 0.08 0.4 0.08; %biomass measure
    0 0 0 0 0 0; 
   0.0921053247325627 0.419552722698002 0.137756595679193 0.0823695569806998 0.434835947587567 0.179541563986651;
    0 0 0 0 0 0;
   0.0961905502834755 0.439132215083027 0.146596335185692 0.0909210202016648 0.459209638910762 0.195608721704464;
    0 0 0 0 0 0;
    0.104204020858339 0.462450804713319 0.156620691339787 0.111069040531815 0.499476769536064 0.218679029460509];
figure
plot_intervals([1:6], g(2,:), g(3,:), g(4,:), g(5,:), g(6,:), g(7,:));
hold on
scatter([1:6],g(1,:),'x');
xlabel('Dataset')
ylabel('Growth rate (h^{-1})')
axis([0 7 0 0.6])









