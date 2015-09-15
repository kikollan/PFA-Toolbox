% EXAMPLE 3. DEFINE AND REPRESENT MEASUREMENTS
%
%This example show a brief introduction about how define and represent measures 
%with PFA TOOLBOX to solve problem with Possibilistic MFA approach.
% It present three (3) measurements, with different uncertainties. 
%
% The example cover:
% 
% 1. DEFINE MEASURES WITH ALL VARIABLES
% 2. PLOT DEFINED MEASURES
% 3. DEFINE MEASUREMENTS WITH TOOLBOX
% 4. DEFINITION OF UNCERTAINTY IN RELATIVE TERMS
%
% For additional information, please visit http://www.possmfa.edu
%
%===================================================================================
%
%% 1. DEFINE MEASURES WITH ALL VARIABLES
 %by user

%                       Glu  EtOH  O2  
PossMeasurements.wm=   [40.6 15.96 61.9];
PossMeasurements.e2max=[0.5 0 4 ];
PossMeasurements.m2max=[0.5 0 4 ];
PossMeasurements.alpha=[2 0.5 0.11];
PossMeasurements.beta= [2 0.5 0.11];

%% 2. PLOT DEFINED MEASURES
figure
for f=[1:3]
    subplot(1,3,f), hold on
    [x,y] = plot_PossMeasurements(PossMeasurements,f);
     plot(x,y,'b--')
     xlim([0 120])
end

%%  3. DEFINE MEASUREMENTS WITH TOOLBOX
 clear all
%      Glu  EtOH  O2   
wm=   [40.6 15.96 61.9];
intFP=[0.5   0   4 ];
intLP=[1.65 4.6 24.9 ];

[PossMeasures]=define_PossMeasurements(wm,intFP,intLP);

%  Plot defined measurements
figure
for f=[1:3]
    subplot(1,3,f), hold on
    [x,y] = plot_PossMeasurements(PossMeasures,f);
     plot(x,y,'r--')
     xlim([0 120]);
end
%% 4. DEFINITION OF UNCERTAINTY IN RELATIVE TERMS

% If the uncertainty of measurements is expressed in relative terms.
% add the following lines to represent the measurement.

% For example for flux of O2.

wm=[61.9];
intFP = max(0.01,abs(wm.*0.05));
intLP = max(0.02,abs(wm.*0.20));

[PossMeasures]=define_PossMeasurements(wm,intFP,intLP);

