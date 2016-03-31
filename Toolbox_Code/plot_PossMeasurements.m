function [meas_out,pos_out] = plot_PossMeasurements(PossMeasurements,flux,resolution,pos_min)
% 
% plot_PossMeasurements — Plot measurements defined in possibilistic terms.
% 
% Syntax
% plot_PossMeasurements(PossMeasurements,flux);
% plot_PossMeasurements(possmeas,flux, resolution, pos_min);
% [meas_out,poss_out]= plot_PossMeasurements(…);
% 
% Description
% plot_PossMeasurements(PossMeasurements, flux) creates a 2D plot with 
% the possibilistic distribution of one measured flux. This way the user can 
% check if the measurements and its uncertainty is well-defined. The function
% receives as input a set of measurements in a structure, PossMeasurements. 
% The measured flux to be plotted is indicated with flux.
%
% The input PossMeasurements is a struct with the measured fluxes wm the
% limits e2max and m2max, and the weights alpha and beta. It can be defined 
% manually by the user or via function define_PossMeasurements.
% The optional inputs “resolution” and “pos_min” are used to specify the number
% of points used to create the plots (default, 20) and the minimum possibility 
% to be plotted (default, 0.001).
% 
% If output variables are given, as in [meas_out, poss_out]=…, instead of 
% drawing a graph, the data is returned as two output variables for x and y 
% coordinates. This way, the user can use plot function to plot the data
% with a custom style.
% 
%   Example: [x, y] = plot_PossMeasurements(A, 3); plot(x, y, ‘*k’).
% 
% See also define_PossMeasurements
%
% For additional information, please visit http://kikollan.github.io/PFA-Toolbox
%
%==============================================================================================


% use default values, if needed
if (nargin==3)    
    pos_min = 0.001;
elseif (nargin==2)
    resolution = 20;
    pos_min = 0.001;
end
if(isempty(resolution)) resolution = 20; end

% check: if hold option is active
if (ishold == 1)    hld = 1;
else                hld = 0;
end

med=[];
pos=[];

% define the poss. points to plot (to left and right)
g1=logspace(log10(pos_min),log10(1),resolution);
g2=logspace(log10(1),log10(pos_min),resolution);

% calculate first side of the plot...
for i=1:1:(resolution-1)
    nmed=(log(g1(i))/PossMeasurements.alpha(flux))+(PossMeasurements.wm(flux)-PossMeasurements.e2max(flux));
    pos=[pos;g1(i)];
    med=[med;nmed];
end

% add fully possible values to plot data...
med = [med; (PossMeasurements.wm(flux)-PossMeasurements.e2max(flux))];
pos = [pos; 1];
med = [med; (PossMeasurements.wm(flux)+PossMeasurements.m2max(flux))];
pos = [pos; 1];

% calculate second side of the plot...
for i=2:1:resolution
    nmed=-((log(g2(i))/PossMeasurements.beta(flux))-(PossMeasurements.wm(flux)+PossMeasurements.m2max(flux)));
    pos=[pos;g2(i)];
    med=[med;nmed];
end

% plot if there is no output variables...
if (nargout == 0)
    plot(med,pos,'r')
    if (hld == 0) hold on;  end
    plot(PossMeasurements.wm(flux)*ones(1,11),0:.1:1,'--g')
    if (hld == 0) hold off;  end

% otherwise, return the data
else
    meas_out=med;
    pos_out=pos;
end
