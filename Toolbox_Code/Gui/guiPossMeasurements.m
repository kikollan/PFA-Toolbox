function varargout = guiPossMeasurements(varargin)

% guiPossMeasurements – Graphic User interface (GUI) to represent the measurements
%                        in possibilistic terms.
%                         
% Initialize
%   >>guiPossMeasurements
%   
% Description
% GUI contains four panels: 
% 
% (1) New/load – create or upload a set of measures
% % To create a new set of measures just click in the button «new set of measures».
% Alternatively, you can import a set of measurements from the workspace to continue 
% a previous work. In this case, write the name of the variable of the previously
% saved data and click «from workspace».  
% 
% (2) Measures: Addition, duplicate or remove measures
% Once a set of measurements has been create or uploaded, each measure will
% be listed and ploted in the box below. Here you can click button to add,
% remove or duplicate the selected flux. In the axes on the right, all measurements
% will be plotted simultaneously. You can chose if measurements are plotted as
% possibilistic distributions (more detailed) or intervals (more compact).
% 
% (3) Editing: To edit a flux measurement
% If you want edit a flux, first you must select it in the list of measurements.
% Then you can change the measured value and its ucertainty (by means of the 
% intervals of flux and half possibility). To do this, simply modify the values
% in the corresponding boxes.  The measurements uncertainty can be defined both
% in absolute (flux units) and relative terms (as a percentage of the measured value). 
% The axes on the right allow you to visualize the measurments being edited and 
% any other of your interest (selecting them in the box on the right). 
% 
% (4) Save: To save the measurements
% After adding all the measurements and defining their uncertainty, the GUI can
% generate a matlab struct with the results. This struct can then be used with
% PFA Toolbox. 
% To save this structure to the MATLAB workspace, just write a name for the variable
% and click «to workspace». A struct will be saved to the workspace with the given
% name and three fields:
% - wm (with the measured values),
% - intFP and intLP (with the intervals defining the uncertainty of each measurement).
% 
% This structure can be used as an input for define_PossMeasurements. 
% 
% NOTE: If you want to save the structure into a file, use the standard 
% MATLAB command, save.
% 
% More Information, please visit http://kikollan.github.io/PFA-Toolbox
%
%========================================================================================

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @guiPossMeasurements_OpeningFcn, ...
    'gui_OutputFcn',  @guiPossMeasurements_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

%% =============== INIT AND RETURN STEPS ========================

% --- Executes just before guiPossMeasurements is made visible.
function guiPossMeasurements_OpeningFcn(hObject, ~, handles, varargin)

% Choose default command line output for guiPossMeasurements
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% define global variables
global wm
global intFP_abs
global intLP_abs
global intFP_rel
global intLP_rel
global names
global alpha
global beta
global e2max
global m2max
global num_flux
global num_new_flux
global resolution

% init all...
if strcmp(get(hObject,'Visible'),'off')
    
    % Initialize internal GUIDE variables
    num_flux=0;
    num_new_flux=0;
    wm=[];
    intFP_abs=[];
    intLP_abs=[];
    intFP_rel=[];
    intLP_rel=[];
    names =[];
    alpha=[];
    beta=[];
    e2max=[];
    m2max=[];
    
    % Initialize plots
    resolution = 20;
    
    % put values to objects
    set(handles.list_flux, 'Value', []);
    set(handles.list_print, 'Value', []);
    set(handles.list_flux, 'String', []);
    set(handles.list_print, 'String', []);
    set(handles.edit_wm, 'String', []);
    set(handles.edit_intFP_abs,'String', []);
    set(handles.edit_intLP_abs,'String', []);
    set(handles.edit_intFP_rel,'String', []);
    set(handles.edit_intLP_rel,'String', []);
    set(handles.edit_flux, 'String', []);
    set(handles.radiobutton_dist,'Value',1);
    
    % init plots 1 and 2
    plot(handles.axes1,1,1);
    set(handles.axes1,'XColor',[0.42 0.42 0.42]);
    set(handles.axes1,'YColor',[0.42 0.42 0.42]);
    cla(handles.axes1);
    
    plot(handles.axes2,1,1);
    set(handles.axes2,'YTick',0:0.5:1);
    set(handles.axes2,'YTickLabel',{'0','0.5','1'});
    set(handles.axes2,'XColor',[0.42 0.42 0.42]);
    set(handles.axes2,'YColor',[0.42 0.42 0.42]);
    cla(handles.axes2);
    
    % add logos and arrow images
    axes(handles.axes_upv);
    im=imread('logo_upv.png');
    image(im);
    axis('off');
    axes(handles.axes_ai2);
    im=imread('logo_ai2.png');
    image(im);
    axis('off');
    axes(handles.axes_udg);
    im=imread('logo_udg.png');
    image(im);
    axis('off');
    axes(handles.axes_arrow);
    im=imread('arrow.jpg');
    image(im);
    axis('off');
end

% --- Outputs from this function are returned to the command line.
function varargout = guiPossMeasurements_OutputFcn(~, ~, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;



%% =============== NEW BUTTON PRESS ========================
% Init a new set of measurements

function button_new_Callback(~, ~, handles)

% variables...
global wm
global intFP_abs
global intLP_abs
global intFP_rel
global intLP_rel
global names
global alpha
global beta
global e2max
global m2max
global num_flux
global num_new_flux
global print

% Reset to one flux
num_flux=1;
num_new_flux=1;

% Set default values...
wm = 1;
intFP_rel = 0.05;
intLP_rel = 0.2;
intFP_abs = max((0.01),abs(wm.*intFP_rel));
intLP_abs = max((2*0.01),abs(wm.*intLP_rel));
names = {'Flux1'};

% Calculate parameters to the plot function...
e2max = intFP_abs;
m2max = intFP_abs;
alpha = -log(0.1)./(intLP_abs-e2max);
beta = -log(0.1)./(intLP_abs-m2max);

% Update values of UI object
set(handles.list_flux, 'Value', 1);
set(handles.list_print, 'Value', 1);
set(handles.list_flux, 'String', names);
set(handles.list_print, 'String', names);
set(handles.edit_wm, 'String', num2str(wm(1)));
set(handles.edit_intFP_abs,'String', num2str(intFP_abs(1)));
set(handles.edit_intLP_abs,'String', num2str(intLP_abs(1)));
set(handles.edit_intFP_rel,'String', num2str(intFP_rel(1)));
set(handles.edit_intLP_rel,'String', num2str(intLP_rel(1)));
set(handles.edit_flux, 'String', names(1));

% Refresh the plots
print = 1;
refresh_plot1(handles);
refresh_plot2(1,handles)


%% =============== LOAD BUTTON PRESS ========================
% Load from workspace a structure with wm, intFP and intLP values.

function button_load_Callback(~, ~, handles)

% Global variables...
global wm
global intFP_abs
global intLP_abs
global intFP_rel
global intLP_rel
global names
global alpha
global beta
global e2max
global m2max
global num_flux
global num_new_flux
global print

% Get the name of the structure to be loaded
structure_name = get(handles.edit_load, 'String');

% Extract variables in the workspace...
ws=evalin('base','who');

% Search the structure to be loaded...
if isempty(structure_name)
    warndlg('The measures name is empty','Load Measurements')
elseif isempty(find(strcmp(ws,structure_name)))
    warndlg('Not exist this measures in the workspace','Load Measurements')
else
    % Load the structure and extract variables
    measures_struc=evalin('base',structure_name);
    wm = measures_struc.wm;
    intFP_abs = measures_struc.intFP;
    intLP_abs = measures_struc.intLP;
    
    % If scalar, make vectors...
    if length(intFP_abs) == 1
        intFP_abs=intFP_abs*ones(length(wm),1);
        intLP_abs=intLP_abs*ones(length(wm),1);
    end
    
    num_flux = length(wm);
    num_new_flux = length(wm);
    names = [];
    
    % Read names...
    for i=1:length(wm);
        names = [names; {strcat('Flux ',num2str(i))}];
    end
    
    % Compute intervals in relative terms
    intFP_rel = abs((intFP_abs)./wm);
    intLP_rel = abs((intLP_abs)./wm);
    
    % Calculate parameters to the plot function...
    e2max = intFP_abs;
    m2max = intFP_abs;
    alpha = -log(0.1)./(intLP_abs-e2max);
    beta = -log(0.1)./(intLP_abs-m2max);
    
    % Update values of UI object
    set(handles.list_flux, 'Value', 1);
    set(handles.list_print, 'Value', 1);
    set(handles.list_flux, 'String', names);
    set(handles.list_print, 'String', names);
    set(handles.edit_wm, 'String', num2str(wm(1)));
    set(handles.edit_intFP_abs,'String', num2str(intFP_abs(1)));
    set(handles.edit_intLP_abs,'String', num2str(intLP_abs(1)));
    set(handles.edit_intFP_rel,'String', num2str(intFP_rel(1)));
    set(handles.edit_intLP_rel,'String', num2str(intLP_rel(1)));
    set(handles.edit_flux, 'String', names(1));
    
    % Refresh the plots
    print = 1;
    refresh_plot2(1,handles)
    refresh_plot1(handles);
    set(handles.edit_load, 'String','');
end

function edit_load_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_load_Callback(~, ~, ~)


%% =============== SAVE BUTTON (edit) ========================

% Save to workspace this problem on structure
function button_save_Callback(~, ~, handles)

global wm
global intFP_abs
global intLP_abs

% Name of struct. output
name_structure=get(handles.edit_save, 'String');

if (isempty(name_structure))
    warndlg('Don''t specified name to save','Save')
    
else
    
    % Output variables
    structure.wm = wm;
    structure.intFP = intFP_abs;
    structure.intLP = intLP_abs;
    
    % Save structure
    assignin('base',name_structure,structure)
    set(handles.edit_save, 'String','');
    
end

% *********************** Edit SAVE button ********************************
function edit_save_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_save_Callback(~, ~, ~)
% empty function, but is necessary




%% **************************** MENU MEASURES *****************************

% ****************************** ADD button *******************************
function button_add_Callback(~, ~, handles)

global wm
global intFP_abs
global intLP_abs
global intFP_rel
global intLP_rel

global alpha
global beta
global e2max
global m2max

global print

global names
global num_flux
global num_new_flux

% Add new counter flux
num_flux = num_flux +1;
num_new_flux = num_new_flux + 1;

% Add new default possibilistic values
wm=[wm; 1];
names = [names; {strcat('Flux ',num2str(num_new_flux))}];
intFP_rel = [intFP_rel; 0.05];
intLP_rel = [intLP_rel; 0.2];
intFP_abs = [intFP_abs; max((0.01),abs(wm(num_flux).*intFP_rel(num_flux)))];
intLP_abs = [intLP_abs; max((2*0.01),abs(wm(num_flux).*intLP_rel(num_flux)))];

e2max = intFP_abs;
m2max = intFP_abs;
alpha = -log(0.1)./(intLP_abs-e2max);
beta = -log(0.1)./(intLP_abs-m2max);

% Set new value on guide
set(handles.edit_wm, 'String', wm(num_flux));
set(handles.list_flux, 'String', names);
set(handles.list_print, 'String', names);
set(handles.edit_intFP_rel, 'String', intFP_rel(num_flux));
set(handles.edit_intFP_abs, 'String', intFP_abs(num_flux));
set(handles.edit_intLP_rel, 'String', intLP_rel(num_flux));
set(handles.edit_intLP_abs, 'String', intLP_abs(num_flux));
set(handles.edit_flux, 'String', names(num_flux));
set(handles.list_flux,'Value',num_flux);

% Search flux are represented on print and add this new flux
actives=get(handles.list_print,'Value');
actives = [actives, num_flux];
print = actives;
set(handles.list_print,'Value',actives);

% Refresh plots
refresh_plot2(num_flux,handles);
refresh_plot1(handles);

% ************************* DUPLICATE button ******************************

% Duplicate the selected flux

function button_duplicate_Callback(~, ~, handles)

global wm
global intFP_abs
global intLP_abs
global intFP_rel
global intLP_rel

global alpha
global beta
global e2max
global m2max

global names
global print

global num_flux
global num_new_flux

% Add new counter flux
num_flux = num_flux +1;
num_new_flux = num_new_flux + 1;

% Index of selected flux
ind = get(handles.list_flux, 'Value');

% Add new possibilistic duplicated values
wm=[wm; wm(ind)];
names = [names; {strcat('Flux ',num2str(num_new_flux))}];
intFP_rel = [intFP_rel; intFP_rel(ind)];
intLP_rel = [intLP_rel; intLP_rel(ind)];
intFP_abs = [intFP_abs; intFP_abs(ind)];
intLP_abs = [intLP_abs; intLP_abs(ind)];

e2max = intFP_abs;
m2max = intFP_abs;
alpha = [alpha; alpha(ind)];
beta = [beta; beta(ind)];

% Set new value on guide
set(handles.edit_wm, 'String', wm(num_flux));
set(handles.list_flux, 'String', names);
set(handles.list_print, 'String', names);
set(handles.edit_intFP_rel, 'String', intFP_rel(num_flux));
set(handles.edit_intFP_abs, 'String', intFP_abs(num_flux));
set(handles.edit_intLP_rel, 'String', intLP_rel(num_flux));
set(handles.edit_intLP_abs, 'String', intLP_abs(num_flux));
set(handles.edit_flux, 'String', names(num_flux));
set(handles.list_flux,'Value',num_flux);

% Search flux are represented on print and add this new flux
actives=get(handles.list_print,'Value');
actives = [actives, num_flux];
print = actives;
set(handles.list_print,'Value',actives);

% Refresh plots
refresh_plot2(num_flux,handles);
refresh_plot1(handles);


% ***************************** REMOVE button *****************************

% Delete selected flux

function button_remove_Callback(~, ~, handles)

global wm
global intFP_abs
global intLP_abs
global intFP_rel
global intLP_rel

global alpha
global beta
global e2max
global m2max

global names

global num_flux
global num_new_flux

global print

% Index of the selected flux to be deleted
ind = get(handles.list_flux, 'Value');
num = get(handles.list_flux, 'String');
num = length(num);

% Don't remove the last flux
if (ind>1)
    
    % Delete one counter flux
    num_flux = num_flux - 1;
    num_new_flux = num_new_flux - 1;
    
    % Remove values to the flux
    wm(ind)=[];
    intFP_rel(ind) = [];
    intLP_rel(ind) = [];
    intFP_abs(ind) = [];
    intLP_abs(ind) =  [];
    names(ind) = [];
    
    e2max(ind) = [];
    m2max(ind) = [];
    alpha(ind) = [];
    beta(ind) = [];
    
    % Rename all fluxes
    for i=(ind):length(names)
        names(i) = {strcat('Flux ',num2str(i))};
    end
    
    if ind == num
        
        ind = ind-1;
        set(handles.list_flux,'Value',ind);
        
    end
    
    % Set the same number flux on the guide
    set(handles.edit_wm, 'String', wm(ind));
    set(handles.edit_intFP_rel, 'String', intFP_rel(ind));
    set(handles.edit_intFP_abs, 'String', intFP_abs(ind));
    set(handles.edit_intLP_rel, 'String', intLP_rel(ind));
    set(handles.edit_intLP_abs, 'String', intLP_abs(ind));
    
    act = get(handles.list_print,'Value');
    
    for i=1:length(act)
        if act(i)>ind
            act(i)=act(i)-1;
        end
    end
    
    set(handles.list_print,'Value',act);
    set(handles.list_flux, 'String', names);
    set(handles.list_print,'String',names);
    print = act;
    
    % Refresh plots
    refresh_plot2(ind,handles);
    refresh_plot1(handles);
    
end

% ************** Select distribution/interval radio button  ***************

% Set print mode on dist or int

function radiobutton_dist_Callback(~, ~, handles)

set(handles.radiobutton_int,'Value',0);
refresh_plot1(handles)

function radiobutton_int_Callback(~, ~, handles)

set(handles.radiobutton_dist,'Value',0);
refresh_plot1(handles)

% *********************** PRINT list   **************************

% Click on list FLUX
function list_print_Callback(hObject, ~, handles)

global print

% Set the values to print
print=get(hObject, 'value');
ind=get(handles.list_flux, 'Value');
print=[print,ind];
set(hObject,'value',print)

% Refresh plots
refresh_plot2(ind,handles)
refresh_plot1(handles);

% Create PRINT list
function list_print_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% *********************** FLUX list   **************************
% Create list FLUX
function list_flux_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Click on list FLUX
function list_flux_Callback(~, ~, handles)

global wm
global intFP_abs
global intLP_abs
global intFP_rel
global intLP_rel
global print
global names

% Set the selected flux on guide
ind = get(handles.list_flux, 'Value');
set(handles.edit_wm, 'String', num2str(wm(ind)));
set(handles.edit_intFP_abs,'String', num2str(intFP_abs(ind)));
set(handles.edit_intLP_abs,'String', num2str(intLP_abs(ind)));
set(handles.edit_intFP_rel,'String', num2str(intFP_rel(ind)));
set(handles.edit_intLP_rel,'String', num2str(intLP_rel(ind)));
set(handles.edit_flux, 'String', names(ind));

actives=get(handles.list_print,'Value');
actives = [actives, ind];
set(handles.list_print,'Value',actives);
print = actives;
refresh_plot2(ind,handles);

% ***************************** Edit flux *********************************

function edit_flux_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ****************************** Edit wm **********************************

% Change wm value and recalculate the other values

function edit_wm_Callback(~, ~, handles)

global wm
global intFP_abs
global intLP_abs
global intFP_rel
global intLP_rel
global e2max
global m2max
global alpha
global beta

% Index of selected flux
ind=get(handles.list_flux, 'Value');
pause(0.2);

% New value of wm
wm(ind)= str2double(get(handles.edit_wm,'String'));

% Recalculate other values
intFP_rel(ind) = str2double(get(handles.edit_intFP_rel,'String'));
intLP_rel(ind) = str2double(get(handles.edit_intLP_rel,'String'));
intFP_abs(ind) = max((0.01),abs(wm(ind).*intFP_rel(ind)));
intLP_abs(ind) = max((2*0.01),abs(wm(ind).*intLP_rel(ind)));

e2max(ind) = intFP_abs(ind);
m2max(ind) = intFP_abs(ind);
alpha(ind) = -log(0.1)./(intLP_abs(ind)-e2max(ind));
beta(ind) = -log(0.1)./(intLP_abs(ind)-m2max(ind));

% Set this values on guide
set(handles.edit_intFP_abs,'String', num2str(intFP_abs(ind)));
set(handles.edit_intLP_abs,'String', num2str(intLP_abs(ind)));
set(handles.edit_intFP_rel,'String', num2str(intFP_rel(ind)));
set(handles.edit_intLP_rel,'String', num2str(intLP_rel(ind)));

% Refresh plots
refresh_plot2(ind,handles);
refresh_plot1(handles);

function edit_wm_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ************************ Edit intFP Absolute ****************************

% Change intFP abs value and recalculate the other values

function edit_intFP_abs_Callback(~, ~, handles)

global wm
global intFP_abs
global intLP_abs
global intFP_rel
global e2max
global m2max
global alpha
global beta

% Index of selected flux
ind=get(handles.list_flux, 'Value');
pause(0.2);

% New value of intFP_abs
intFP_abs(ind) = str2double(get(handles.edit_intFP_abs,'String'));

% Recalculate other values
intFP_rel(ind) = (intFP_abs(ind))./wm(ind);

e2max(ind) = intFP_abs(ind);
m2max(ind) = intFP_abs(ind);
alpha(ind) = -log(0.1)./(intLP_abs(ind)-e2max(ind));
beta(ind) = -log(0.1)./(intLP_abs(ind)-m2max(ind));

% Set this values on guide
set(handles.edit_intFP_rel,'String', num2str(intFP_rel(ind)));

% Refresh plots
refresh_plot2(ind,handles);
refresh_plot1(handles);

function edit_intFP_abs_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ************************ Edit intLP Absolute ****************************

% Change intLP abs value and recalculate the other values

function edit_intLP_abs_Callback(~, ~, handles)

global wm
global intLP_abs
global intLP_rel
global e2max
global m2max
global alpha
global beta

% Index of selected flux
ind=get(handles.list_flux, 'Value');
pause(0.2);

% New value of intLP_abs
intLP_abs(ind) = str2double(get(handles.edit_intLP_abs,'String'));

% Recalculate other values
intLP_rel(ind) = (intLP_abs(ind))./wm(ind);

alpha(ind) = -log(0.1)./(intLP_abs(ind)-e2max(ind));
beta(ind) = -log(0.1)./(intLP_abs(ind)-m2max(ind));

% Set this values on guide
set(handles.edit_intLP_rel,'String', num2str(intLP_rel(ind)));

% Refresh plots
refresh_plot2(ind,handles);
refresh_plot1(handles);

function edit_intLP_abs_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ************************ Edit intLP Relaitve ****************************

% Change intFP rel value and recalculate the other values

function edit_intFP_rel_Callback(~, ~, handles)

global wm
global intFP_abs
global intLP_abs
global intFP_rel
global e2max
global m2max
global alpha
global beta

% Index of selected flux
ind=get(handles.list_flux, 'Value');
pause(0.2);


% New value of intFP_rel
intFP_rel(ind) = str2double(get(handles.edit_intFP_rel,'String'));

% Recalculate other values
intFP_abs(ind) = max((0.01),abs(wm(ind).*intFP_rel(ind)));

e2max(ind) = intFP_abs(ind);
m2max(ind) = intFP_abs(ind);
alpha(ind) = -log(0.1)./(intLP_abs(ind)-e2max(ind));
beta(ind) = -log(0.1)./(intLP_abs(ind)-m2max(ind));

% Set this values on guide
set(handles.edit_intFP_abs,'String', num2str(intFP_abs(ind)));

% Refresh plots
refresh_plot2(ind,handles);
refresh_plot1(handles);

function edit_intFP_rel_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ************************ Edit intLP Relaitve ****************************

% Change intLP rel value and recalculate the other values

function edit_intLP_rel_Callback(~, ~, handles)

global wm
global intLP_abs
global intLP_rel
global e2max
global m2max
global alpha
global beta

% Index of selected flux
ind=get(handles.list_flux, 'Value');
pause(0.2);

% New value of intLP_rel
intLP_rel(ind) = str2double(get(handles.edit_intLP_rel,'String'));

% Recalculate other values
intLP_abs(ind) = max((2*0.01),abs(wm(ind).*intLP_rel(ind)));

alpha(ind) = -log(0.1)./(intLP_abs(ind)-e2max(ind));
beta(ind) = -log(0.1)./(intLP_abs(ind)-m2max(ind));

% Set this values on guide
set(handles.edit_intLP_abs,'String', num2str(intLP_abs(ind)));

% Refresh plots
refresh_plot2(ind,handles);
refresh_plot1(handles);

function edit_intLP_rel_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% *************************** PRINT functions ****************************


function refresh_plot1(handles)

global wm
global alpha
global beta
global e2max
global m2max
global resolution

cla(handles.axes1,'reset');

if (get(handles.radiobutton_int, 'Value')==1)
    
    flux=[1:length(wm)]';
    
    xmin_c1 = zeros(length(wm),1);
    xmax_c1 = zeros(length(wm),1);
    xmin_c2 = zeros(length(wm),1);
    xmax_c2 = zeros(length(wm),1);
    xmin_c3 = zeros(length(wm),1);
    xmax_c3 = zeros(length(wm),1);
    
    for j=1:length(wm)
        
        
        med=(log(1)/alpha(j))+(wm(j)-e2max(j));
        xmin_c1(j) = med;
        
        med=(log(0.5)/alpha(j))+(wm(j)-e2max(j));
        xmin_c2(j) = med;
        
        med=(log(0.1)/alpha(j))+(wm(j)-e2max(j));
        xmin_c3(j) = med;
        
        med=-(log(1)/alpha(j))+(wm(j)+e2max(j));
        xmax_c1(j) = med;
        
        med=-(log(0.5)/alpha(j))+(wm(j)+e2max(j));
        xmax_c2(j) = med;
        
        med=-(log(0.1)/alpha(j))+(wm(j)+e2max(j));
        xmax_c3(j) =med;
        
        
    end
    
    widthbox=0.2;
    
    axes(handles.axes1);
    
    plot(1,1);
    cla;
    
    
    for i=1:length(xmin_c3)
        line([flux(i) flux(i)],[xmin_c3(i) xmax_c3(i)],'LineWidth',2,'Color',0.4*ones(3,1));
    end
    
    hold on;
    grid on;
    
    Ax=(xmax_c2-xmin_c2)/2;
    Mx=xmin_c2 + Ax;
    
    errorbar(flux,Mx,Ax,'Color',0.2*ones(1,3),'LineWidth',2,'Marker','none','LineStyle','none');
    
    xdata=[flux'-widthbox;flux'-widthbox;flux'+widthbox;flux'+widthbox];
    
    ydata=[xmin_c1';xmax_c1';xmax_c1';xmin_c1'];
    zdata=ones(4,length(xmin_c1));
    patch(xdata,ydata,zdata,'LineWidth',2,'FaceColor',0.8*ones(1,3),'EdgeColor',0.4*ones(1,3))
    axis (handles.axes1,'tight');
    set(handles.axes1,'YColor',[0.42 0.42 0.42]);
    set(handles.axes1,'XColor',[0.42 0.42 0.42]);
    
elseif (get(handles.radiobutton_dist, 'Value')==1)
    
    ColorSet = varycolor(length(wm));
    
    maxmed= -1000000;
    minmed= 1000000;
    
    for j=1:length(wm)
        
        id = j;
        med=zeros(2*resolution,1);
        pos=zeros(2*resolution,1);
        
        g1=logspace(log10(0.001),log10(1),resolution);
        g2=logspace(log10(1),log10(0.001),resolution);
        
        for i=1:(resolution-1)
            
            nmed=(log(g1(i))/alpha(id))+(wm(id)-e2max(id));
            pos(i)=g1(i);
            med(i)=nmed;
        end
        
        med(resolution) = (wm(id)-e2max(id));
        pos(resolution) = 1;
        med(resolution+1) = (wm(id)+m2max(id));
        pos(resolution+1) =  1;
        
        
        for i=2:resolution
            
            nmed=-((log(g2(i))/beta(id))-(wm(id)+m2max(id)));
            pos(i+resolution)=g2(i);
            med(i+resolution)=nmed;
        end
        
        if (max(med)>maxmed)
            maxmed = max(med);
        end
        if (min(med)<minmed)
            minmed = min(med);
        end
        
        plot(handles.axes1,med,pos,'Color', ColorSet(j,:))
        hold(handles.axes1,'on');
        plot(handles.axes1,wm(id)*ones(1,11),0:.1:1,'--','Color', ColorSet(j,:));
        axis(handles.axes1,[minmed maxmed 0 1.02]);
        grid(handles.axes1,'on');
        set(handles.axes1,'YTick',0:0.5:1);
        set(handles.axes1,'YTickLabel',{'0','0.5','1'});
        set(handles.axes1,'YColor',[0.42 0.42 0.42]);
        set(handles.axes1,'XColor',[0.42 0.42 0.42]);
        
    end
end

function refresh_plot2(ind,handles)

global wm
global alpha
global beta
global e2max
global m2max
global print
global resolution

cla(handles.axes2);

maxmed = -1000000;
minmed = 1000000;

for j=1:length(wm)
    
    if (find(print == j)>0)
        
        id = j;
        med=zeros(2*resolution,1);
        pos=zeros(2*resolution,1);
        
        g1=logspace(log10(0.001),log10(1),resolution);
        g2=logspace(log10(1),log10(0.001),resolution);
        
        for i=1:(resolution-1)
            
            nmed=(log(g1(i))/alpha(id))+(wm(id)-e2max(id));
            pos(i)=g1(i);
            med(i)=nmed;
        end
        
        med(resolution) = (wm(id)-e2max(id));
        pos(resolution) = 1;
        med(resolution+1) = (wm(id)+m2max(id));
        pos(resolution+1) =  1;
        
        
        for i=2:resolution
            
            nmed=-((log(g2(i))/beta(id))-(wm(id)+m2max(id)));
            pos(i+resolution)=g2(i);
            med(i+resolution)=nmed;
        end
        
        if (max(med)>maxmed)
            maxmed = max(med);
        end
        if (min(med)<minmed)
            minmed = min(med);
        end
        
        if (j==ind)
            plot(handles.axes2,med,pos,'r','LineWidth',2.5)
            hold(handles.axes2,'on');
            plot(handles.axes2,wm(id)*ones(1,11),0:.1:1,'--k','LineWidth',2.5)
        else
            plot(handles.axes2,med,pos,'b')
            hold(handles.axes2,'on');
            plot(handles.axes2,wm(id)*ones(1,11),0:.1:1,'--k');
        end
        set(handles.axes2,'YTick',0:0.5:1);
        set(handles.axes2,'YTickLabel',{'0','0.5','1'});
        set(handles.axes2,'YColor',[0.42 0.42 0.42]);
        set(handles.axes2,'XColor',[0.42 0.42 0.42]);
        
    end
end

if ~isempty(print)
    axis (handles.axes2,[minmed maxmed 0 1.02]);
    grid(handles.axes2,'on');
end



% --------------------------------------------------------------------
function contact_lab_Callback(hObject, eventdata, handles)
web('http://sb2cl.ai2.upv.es');

% --------------------------------------------------------------------
function contact_kiko_Callback(hObject, eventdata, handles)
web('http://francisco.llaneras.es');

% --------------------------------------------------------------------
function about_toolbox_Callback(hObject, eventdata, handles)
web('http://francisco.llaneras.es');

% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)
web('http://francisco.llaneras.es');
