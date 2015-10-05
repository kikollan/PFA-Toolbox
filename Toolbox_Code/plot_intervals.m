function [h_out] = plot_intervals(flux,vmin_c1,vmax_c1,vmin_c2,vmax_c2,vmin_c3,vmax_c3)
%
% plot_intervals — Plot interval estimates for a set of fluxes.
% 
% Syntax
% plot_intervals(flux, vmin_c1, vmax_c1);
% plot_intervals(flux, vmin_c1, vmax_c1 ,vmin_c2, vmax_c2);
% plot_intervals(…, …, …, …, vmin_c3, vmax_c3);
% [h_out] = plot_intervals(…);
% 
% Description
% plot_intervals(flux, vmin_c1, vmax_c1) creates a 2D plot to show a set of
% interval estimates. The function receives as input a vector of x coordinates,
% flux (e.g., [1:5] or [1 7 8]). Vectors vmin_c1, vmax_c1 define the lower and 
% upper limits of the intervals to be plotted, which typically would have been
% computed with solve_PossInterval.
% 
% plot_intervals(flux, vmin_c1, vmax_c1, vmin_c2, vmax_c2) and 
% plot_intervals(flux, vmin_c1, max_c1, vmin_c2, vmax_c2, vmin_c3, vmax_c3)
% allow to plot two and three pairs of interval estimates in a single, compact graph.
% 
% If an output variable is indicated, “h_out”, the functions will return a
% structure with the handles of every object in the figure. 
% This way, it can be customized.
% 
% See also solve_PossInterval
% 
% For additional information, please visit https://github.com/kikollan/PFA-Toolbox
%
%================================================================================================


% check: transform row vectors into column vectors
 if(iscolumn(flux)==0)       flux=flux'; end
 if(iscolumn(vmin_c1)==0)    vmin_c1=vmin_c1'; end
 if(iscolumn(vmax_c1)==0)    vmax_c1=vmax_c1'; end

% cases depending on number of input arguments
switch nargin
    
    % CASE: three intervals
    case 7

    % check: transform row vectors into column vectors
    if(iscolumn(vmin_c2)==0)    vmin_c2=vmin_c2';    end
    if(iscolumn(vmax_c2)==0)    vmax_c2=vmax_c2';    end
    if(iscolumn(vmin_c3)==0)    vmin_c3=vmin_c3';    end
    if(iscolumn(vmax_c3)==0)    vmax_c3=vmax_c3';    end  

    %  set width for first first interval box
    widthbox = 0.15;
    
    % plot largest interval (lines)
    for i=1:length(vmin_c3)
        h.c3 =  line([flux(i) flux(i)],[vmin_c3(i) vmax_c3(i)],'LineWidth',2,'Color',0.4*ones(3,1));
    end
    
    hold on;
        
    % calculate width for errorbar
    Ax=(vmax_c2-vmin_c2)/2;
    Mx=vmin_c2 + Ax;
    
    % plot large interval (errorbar)
    h.c2 =  errorbar(flux,Mx,Ax,'Color',0.2*ones(1,3),'LineWidth',2,'Marker','none','LineStyle','none');

    % plot smallest interval (box)
    xdata=[flux'-widthbox;flux'-widthbox;flux'+widthbox;flux'+widthbox];
    ydata=[vmin_c1';vmax_c1';vmax_c1';vmin_c1'];
    zdata=ones(4,length(vmin_c1));
    h.c1 = patch(xdata,ydata,zdata,'LineWidth',1,'FaceColor',0.9*ones(1,3),'EdgeColor',0.6*ones(1,3));
  

    % CASE: two intervals
    case 5
    
    % check: transform row vectors into column vectors
    if(iscolumn(vmin_c2)==0)  vmin_c2=vmin_c2';   end
    if(iscolumn(vmax_c2)==0)  vmax_c2=vmax_c2';   end

    % calculate width for errorbar
    Ax=(vmax_c2-vmin_c2)/2;
    Mx=vmin_c2 + Ax;
    
    % plot large interval (errorbar)
    h.c2 = errorbar(flux,Mx,Ax,'Color',0.2*ones(1,3),'LineWidth',2,'Marker','none','LineStyle','none');
    hold on;
        
    % plot smallest interval (box)    
    xdata=[flux'-widthbox;flux'-widthbox;flux'+widthbox;flux'+widthbox];
    ydata=[vmin_c1';vmax_c1';vmax_c1';vmin_c1'];
    zdata=ones(4,length(vmin_c1));
    h.c1 = patch(xdata,ydata,zdata,'LineWidth',1,'FaceColor',0.9*ones(1,3),'EdgeColor',0.6*ones(1,3));
        
    % CASE: one interval
   case 3
        
    % calculate width for errorbar
    Ax=(vmax_c1-vmin_c1)/2;
    Mx=vmin_c1 + Ax;
    
    % plot smallest interval (errorbar)
    h =  errorbar(flux,Mx,Ax,'Color',0.2*ones(1,3),'LineWidth',2,'Marker','none','LineStyle','none');
        
    otherwise
        disp('Incorrect number of inputs.');
end

% figure handler to be returned
h_out=h;
hold off;
