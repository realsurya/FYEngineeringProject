function [v0Array, percentError] = calcV0Vals(dataType); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENGR 132 
% Program Description 
% This function will use the MOVING MEDIAN method in order to smooth
% the data and then will use the smoothed data to find v0 for all products
%
% Function Call
% [v0Array, percentError] = calcV0Vals(dataType);
%
% Input Arguments
% dataType: the datatype being examined (either 'noisy' or 'clean')
%
% Output Arguments
% v0Array: array of all v0 values for all 10 products in the dataset.
% percentError: the average percent error for all the the v0 values
%
% Assignment Information
%   Assignment:     Project Milestone 2
%   Team member:    Surya Manikhandan, smanikha@purdue.edu
%                   Julius Mesa, jmesa@purdue.edu
%                   Alex Norkus, anorkus@purdue.edu
%                   Vincent Lin, lin971@purdue.edu
%   Team ID:        001-30
%   Academic Integrity:
%     [] We worked with one or more peers but our collaboration
%        maintained academic integrity.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ____________________
%% INITIALIZATION

% set the appropriate filename and given v0 values for calculation of percent error
if dataType == 'noisy'
    fileName = "Data_PGOX50_noisy.csv";
    givenv0 = [0.028, 0.055, 0.11, 0.19, 0.338, 0.613, 0.917, 1.201, 1.282, 1.57];
elseif dataType == 'clean'
    fileName = "Data_PGOX50_clean.csv";
    givenv0 = [0.028, 0.056, 0.11, 0.193, 0.360, 0.6, 0.883, 1.212, 1.376, 1.584];
else
    fprintf(2,"Parameter Error: dataType must be either 'noisy' OR 'clean'\n");
    return;
end

substrateData = readmatrix(fileName, 'range', 'B6:K6'); % holds all [S] values for each substrate 1-10 (Units: uM)
time = readmatrix(fileName, 'range', 'A9:A'); % holds the variable of time (Units: mins)
productConc = readmatrix(fileName, 'range', 'B:K'); % holds all the concentration data for the products in (Units : uM) 

%% ____________________
%% CALCULATIONS
segmentWidth = 25; % the width of the segment the smoothing algorithm should use
v0 = []; % the array which will hold all of the v0 values

for productNum = 1:10 % cycle between all of the 10 products
    
    smoothedPVals = []; % the array which will hold the smoothed [P] vals for each (Units: uM)
    smoothedTimes = []; % the array which will hold the smothed time values (Units: uM)
    
    P = productConc(5:1227, productNum); % get the product concentration data for the given substrate
    
    for index = 1:segmentWidth:(length(P) - segmentWidth) % cycle through each [P] value
        % take a given segment of [P] whith width of smoothPasses
        segmentPvals = P(index:(index + segmentWidth)); 
        
        % take average of segments of time whith width of smoothPasses
        segmentTimes = time(index:(index + segmentWidth));
        
        % take the median of the segment given and 
        medianPvals = median(segmentPvals);
        medianTimes = median(segmentTimes);

        smoothedPVals = [smoothedPVals,medianPvals]; % add median [P] to final array
        smoothedTimes = [smoothedTimes,medianTimes];% add median time to final array
    end
    
    v0 = [v0, (smoothedPVals(2) - smoothedPVals(1)) / (smoothedTimes(2) - smoothedTimes(1))]; %find the first slope and add that to the v0 array
end

%% ____________________
%% FORMATTED TEXT/FIGURE DISPLAYS


%% ____________________
%% COMMAND WINDOW OUTPUT

percentError = (mean(abs(v0 - givenv0) / givenv0) * 100); % calculate the percent error through the use of give v0
v0Array = v0; % return final v0array

%% ____________________
%% ACADEMIC INTEGRITY STATEMENT
% We have not used source code obtained from any other unauthorized
% source, either modified or unmodified. Neither have we provided
% access to my code to another. The function we are submitting
% is our own original work.
end


