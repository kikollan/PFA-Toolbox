% PICHIA PASTORIS CASE OF USE, USING THE TOOLBOX POSSMFA.
% 
% This example present some of the utilities of the PossMFA toolbox, using
% a small metabolic model of the yeast Pichia pastoris. The example contains
% possibilistic estimation of biomass flux of Pichia under two different
% scenarios.  Additionally a consistency evaluation of some data sets is
% also performed.
%
% The example cover:
% 
% 1.	PROBLEM FORMULATION
% 2.	BIOMASS ESTIMATION INCLUDING MEASURES OF CO2 AND O2 FLUXES.
% 3.	PLOT PREDICTIONS
% 4.	CONSISTENCY EVALUATION OF MEASUREMENTS.
% 
% For additional information, please visit https://github.com/kikollan/PFA-Toolbox
%
%===================================================================================
%
%% 1. PROBLEM FORMULATION 

clear all
%charge model (stoichometric matrix and irrevesibilities) from XLS file
[DATA,TXT]=xlsread('File_1.xlsx','Network', '', 'basic');
model.rev = DATA(2,1:end);
model.S = DATA(3:39,1:end);

% Eliminate  NAN from stoichometric matrix.
model.S(isnan(model.S))=0; 

% Init the Possibilistic problem with Model constraints.
[PossProblem] = define_MOC(model);

%% Charge Experimental data sets for Growth estimations.
 %  measures   OUR  GLU   CER  EtOH  Gly  Cit  Pyr   MET   Bio   		     
 %  index   = [ 39   40   41    42   43   44   45    46	47];
  exp{1}.wm = [ 2.71 1.51 3.18  0.00 0.00 0.00 0.00  0.00 5.74];
  exp{2}.wm = [ 4.78 0.00 3.25  0.00 2.53 0.00 0.00  0.18 4.54];
  exp{3}.wm = [ 0.87 0.00 0.65  nan  0.62  nan  nan  0.00 1.11];
  exp{4}.wm = [ 1.26 0.00 0.99  nan  0.00  nan  nan  1.89 0.90];
  exp{5}.wm = [ 2.16 0.00 1.56  0.00 1.09 0.00 0.00  0.00 1.88];
  
 %% 2.	BIOMASS ESTIMATION INCLUDING MEASURES OF CO2 AND O2 FLUXES.

% Interval of estimates for biomass, with three intervals of possibility 
% 0.1, 0.5, 0.99.

% Perform calculations.

  for i=1:length(exp)
% Charge measured flux constraints.

%  Measures     OUR             GLU              CER           EtOH          Gly             Cit           Pyr                MET    
  index     = [ 39               40               41             42            43             44            45                 46]; 
  Exp{i}.wm = [exp{i}.wm(1,1)  exp{i}.wm(1,2) exp{i}.wm(1,3) exp{i}.wm(1,4) exp{i}.wm(1,5) exp{i}.wm(1,6) exp{i}.wm(1,7)  exp{i}.wm(1,8)];
  index(isnan(Exp{i}.wm)) = [];    
  Exp{i}.wm(isnan(Exp{i}.wm)) = []; %Eliminate NAN's from constraints measures
  
% Adding uncertainty of measurements.
  intFP= 0.05 ;
  intLP= 0.2;

  intFP_abs = max((0.001),abs(Exp{i}.wm.*intFP));
  intLP_abs = max((2*0.001),abs(Exp{i}.wm.*intLP)); 

%Generate the possibilistic measures structure.

  [PossMeasures]=define_PossMeasurements( Exp{i}.wm,intFP_abs,intLP_abs);
  [PossProblem] = define_MEC(PossProblem, PossMeasures, index);
 
%Develop interval estimates for three intervals of possibility 0.1, 0.5, 0.99
   [Vmin,Vmax]=solve_PossInterval(PossProblem,[0.99,0.5,0.1],47);
   
% 3.	PLOT OF PREDICTIONS.

%convert units
vmin=Vmin*25.86/1000; %25.86 biomass molecular weight
vmax=Vmax*25.86/1000;
% Growth rate predictions Vs measured values.

 plot_intervals(i,vmin(1,1),vmax(1,1),vmin(2,1),vmax(2,1),vmin(3,1),vmax(3,1));hold on
 plot(i,exp{i}.wm(1,9)*(25.86/1000),'xk','LineWidth',2)
  end
  

 %% CONSISTENCY EVALUATION
 
%  Charge data sets.
  %  measures  OUR   GLU   CER  EtOH  Gly  Cit  Pyr   MET   Bio   		     
  %  index   = [ 39   40   41    42   43   44   45    46	 47];
  exp{1}.wm = [ 4.02  0.81 2.68  0.00 0.00 0.00 0.00  1.09 3.27];
  exp{2}.wm = [ 3.62  0.00 2.35  0.00 2.75 0.00 0.00  0.00 6.17];
  exp{3}.wm = [ 1.65  0.00 1.22  nan  1.21  nan  nan  0.00 2.38];
  exp{4}.wm = [ 3.12  0.00 2.29  nan  2.40  nan  nan  0.00 4.89];
  exp{5}.wm = [ 1.67  0.00 0.93  nan  0.00  nan  nan  1.87 0.94];
  exp{6}.wm = [ 2.16 0.00 1.15  nan  0.00  nan  nan  2.55 1.40];

% Perform calculations.
  for i=1:6
% Charge measured flux constraints.
  index   = [ 39     40   41    42   43   44  45    46	 47]; 
  index(isnan(exp{i}.wm)) = [];    
  exp{i}.wm(isnan(exp{i}.wm)) = []; %eliminate NAN's
  
%Adding uncertainty.
 
 intFP= 0.05 ;
 intLP= 0.2;

intFP_abs = max((0.001),abs( exp{i}.wm.*intFP));
intLP_abs = max((2*0.001),abs( exp{i}.wm.*intLP)); 

%Generate the possibilistic measures structure.

[PossMeasures]=define_PossMeasurements( exp{i}.wm,intFP_abs,intLP_abs);
[PossProblem] = define_MEC(PossProblem, PossMeasures, index);

% Calculate max posibility.
[x, poss]=solve_maxPoss(PossProblem);
poss_all(i)=[poss];
  i
 end