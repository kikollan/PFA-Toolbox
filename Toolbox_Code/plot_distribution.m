function [meas_out,pos_out] = plot_distribution(vmin,vmax,poss)
%
% % plot_distribution — Plot a complete the possibilistic distribution of a flux.
% 
% Syntax
% plot_distribution(vmin,vmax,poss)
% [meas_out,poss_out] = plot_distribution(vmin,vmax,poss)
% 
% Description
% plot_distribution(vmin,vmax,poss) plots the possibilistic distribution for
% a specific flux. The function receives three inputs, vectors vmin, and vmax,
% with the lower and higher limits of a set of interval estimates, each
% interval corresponding to the degrees of possibility indicated in poss. 
% vmin and vmax are the output of the solve_PossInterval(…, poss, …).
% 
% If output variables are given, as in [meas_out, poss_out]=…, instead of 
% drawing a graph, the data is returned as two output variables for x and y
% coordinates. This way, the user can use plot function to plot the data 
% with a custom style. 
% 
%  Example: [x, y] = plot_distribution(vmin, vmax, poss); plot(x, y, ‘r’).
% 
% See also   solve_PossInterval
% 
% For additional information, please visit http://kikollan.github.io/PFA-Toolbox
%
%=============================================================================================================

% check: transform row vectors into column vectors
 if(iscolumn(poss)==0)    poss=poss'; end

% arrange min and max values in a single vector
meas = [vmin; flipud(vmax)];
pos  = [poss; flipud(poss)];

% if there is an output, return
if (nargout>0)
    meas_out=meas;
    pos_out=pos;
else
% otherwise, plot
    plot(meas,pos);
end
