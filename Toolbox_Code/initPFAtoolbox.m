function initPFAtoolbox()
% 
% initPFAtoolbox — The function initiates the PFA Toolbox.
% 
% Syntax
% >> initPFAtoolbox    
% 
% Description
% The function initiates the PFA Toolbox. It adds the toolbox folder to the
% MATLAB path. If YALMIP is not already installed, a copy is also added to 
% the path. The optimization solver GLPK is selected, if it is installed and
% is detected. Otherwise, YALMIP is initialized with the available solver.
% 
% For additional information visit http://kikollan.github.io/PFA-Toolbox
%
% ==========================================================================================

% verify if yalmip and glpk exist...
exst_ymp=exist('yalmip');
exst_glpk=exist('glpk');

% if they do not, install those in PossMFA Toolbox
if (exst_ymp == 0)
    addpath(cd);
    cd Gui;
    addpath(cd);
    cd ..;
    cd Optimizer;
    addpath(genpath(cd));
    cd ..;
    if(exst_glpk~=0)    yalmip('solver','glpk');    end
    yalmiptest;
else
    addpath(cd);
    cd Gui;
    addpath(cd);
    cd ..;
    if(exst_glpk~=0)    yalmip('solver','glpk');    end
    yalmiptest;
end

% Save path
savepath;
