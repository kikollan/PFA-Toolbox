function [PossMeasurements] = define_PossMeasurements(wm,intFP,intLP)
% 
% define_PossMeasurements — Generates a set of possibilistic measurements.
% 
% Syntax 
% [PossMeasurements]=define_PossMeasurements(wm, intFP, intLP); 
% [PossMeasurements]=define_PossMeasurements(meas);
% 
% Description
% [PossMeasurements]=define_PossMeasurements(wm, intFP, intLP) returns a
% PossMeasurements  struct that contains the measured fluxes wm the limits 
% e2max and m2max, and the weights alpha and beta, required to represent 
% a set of measurements in possibilistic terms. Vector wm is a vector with
% the measured values for each flux. intFP represent the interval around
% wm in which flux values have maximum possibility. It can be a single 
% value, equal for all the measurements, or a vector with a specific value
% for each measurement. intLP represent the interval around wm in which 
% measurements have a low possibility. It can be a single value or a vector.
%
% [PossMeasurements]=define_PossMeasurements(meas) does exactly the same,
% but receives a struct as input, with fields: wm, intFP and intLP.
% 
% wm	Measures values vector
% intFP	Interval with maximum possibility
% intLP	Interval with low possibility
% 
% Recall that define_PossMeasurements defines the measurements and their 
% uncertainty based on two intervals. Basically, the user only defines two 
% intervals of high possibility (intFP) and low possibility (intLP), and 
% parameters alpha, beta, ef^max  & muf^max are defined accordingly:
% 
% 	- Full possibility (Poss=1) is assigned to the interval w±intFP.
% 	- Larger deviations are penalized so that values equal to w ±intLP 
%     have a possibility of Poss=0.1.
%       
% As an alternative, advanced user can define directly the variables in the
% PossMeasurements struct.
%
% For additional information, please visit http://kikollan.github.io/PFA-Toolbox
%
%===========================================================================

 
% if the input is a single argument, parse it as a structure
if (nargin == 1)
    if isstruct(wm)
        intFP = wm.intFP;
        intLP = wm.intLP;
        wm = wm.wm;
    else
        error('If define one input, must be a structure.')
    end
end

%check: transform row vectors into column vectors
if(iscolumn(wm)==0)    wm=wm';       end
if(iscolumn(intFP)==0) intFP=intFP'; end
if(iscolumn(intLP)==0) intLP=intLP'; end

% check: if LP interval is smaller than FP interval...
if(intLP <= intFP)
    intLP = intLP+0.00001;    
    warning('The value of intLP must be larger than intFP. It has been changed to intLP + 0.00001.')
end

% if intervals are scalar entries, make them vectors for each measurement
if (length(intFP)==1)
    intFP=ones(length(wm),1)*intFP;
    intLP=ones(length(wm),1)*intLP;
end

% check error: if intervals have different lengths
if (length(intFP)~=length(intLP))
    PossMeasurements=[];
    display ('Error: Vector dimensions must agree.')
end 

% create output structure: Possibilistic measurements
PossMeasurements.wm = wm;
PossMeasurements.e2max = intFP;
PossMeasurements.m2max = intFP;
PossMeasurements.alpha = -log(0.1)./(intLP-PossMeasurements.e2max);
PossMeasurements.beta = -log(0.1)./(intLP-PossMeasurements.m2max);
