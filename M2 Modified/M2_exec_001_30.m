function [vMax, kM, SSE] = runPlots(algNumber, dataType); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENGR 132 
% Program Description 
% This function will call the correct algorithm to produce product 
% concentration & reaction velocity plots. Will also calculate parameters
% vmax and km using the calculated values from the algorithm
%
% Function Call
% [vMax, kM, SSE] = runPlots(dataType);c
%
% Input Arguments
% algNumber: the number of the algorithm used (either 1 or 2)
% dataType: the datatype being examined (either 'noisy' or 'clean')
%
% Output Arguments
% vMax: the parameter vmax calculated through the Hanes-Wolf method
% kM: the parameter kM ascertained by using calculated vMax in equation
% SSE: SSE between reference initial velocities (v0i) and the reaction velocities (vi)
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
    if algNumber == 1
        [v0Array, percentError] = M2_Algorithm1_001_30("noisy");
    elseif algNumber == 2
        [v0Array, percentError] = M2_Algorithm2_001_30("noisy");
    end
    givenv0 = [0.028, 0.055, 0.11, 0.19, 0.338, 0.613, 0.917, 1.201, 1.282, 1.57];
    vMax = 1.72;
    kM = 226.92;
elseif dataType == 'clean'
    fileName = "Data_PGOX50_clean.csv";
    if algNumber == 1
        [v0Array, percentError] = M2_Algorithm1_001_30("clean");
    elseif algNumber == 2
        [v0Array, percentError] = M2_Algorithm2_001_30("clean");
    end  
    givenv0 = [0.028, 0.056, 0.11, 0.193, 0.360, 0.6, 0.883, 1.212, 1.376, 1.584];
    vMax = 1.61;
    kM = 214.28;
else
    fprintf(2,"Parameter Error: Please ensure all params meet guidelines\n");
    return;
end

time = readmatrix(fileName, 'range', 'A9:A'); % holds the variable of time (Units: mins)
productConc = readmatrix(fileName, 'range', 'B:K'); % holds all the concentration data for the products in (Units : uM) 
substrateData = readmatrix(fileName, 'range', 'B6:K6'); % holds all [S] values for each substrate 1-10 (Units: uM)

%% ____________________
%% PLOT 1 - PRODUCT CONCENTRATION 
figure(1);

for productNum = 1:10 % cycle between all of the 10 products
    
    P = productConc(5:1227, productNum); % get the product concentration data for the given substrate
    velocityVector = v0Array(productNum) * time; % calculate the tangent line for the v0 velocity vector

    subplot(2,5,productNum); % set appropriate subplot
    
    plot(time, P); % plot the product concentration vs time (raw data)
    hold on
   
    plot(time(1:250), velocityVector(1:250)); %plot the velocity vector vs time
    
    % add title, axis labels and legends
    title({"Product Conc vs Time", sprintf("for substrate %d", productNum)});
    xlabel("Time (mins)");
    ylabel("Product Concentration [P] (uM)");
    grid on
    legend("Raw Data", "v0 Velocity Vector", "location", "southeast");
    
    % add title to the figure window
    hold off
    figureTitle = sprintf("Algorithm %d with %s data.", algNumber, dataType);
    sgtitle(figureTitle);
    
end

%% ____________________
%% PLOT 2 - REACTION VELOCITY PLOT

figure(2); % set new figure
plot(substrateData, v0Array, "ro"); % plot the substrateData and v0 Array with markers only

hold on 

idealV0 = (vMax .* substrateData) ./ (kM + substrateData); % calculate ideal v0 vals using Michaelis-Menten equation
plot(substrateData, idealV0); % plot the Michaelis-Menten equation output

% title and label the plot to format for technical presentation
title({"Reaction Velocity vs Substrate Concentration", figureTitle});
xlabel("Substrate Concentration [S] (uM)");
ylabel("Reaction velocity v (uM/min)");
legend(sprintf("V0 Calculated Using Algorithm %d", algNumber), " Expected Reaction Velocity Vector", 'location', 'southeast');
grid on

%% ____________________
%% COMMAND WINDOW OUTPUT

% CALCULATION SOURCE - https://www.hindawi.com/journals/jchem/2017/6560983/
% ADDITIONAL REFERENCE FOR MORE METHODS - https://bit.ly/2JU1RV1

% Hanes-Wolf method states plotting [S] and [S]/v produces a linear curve where:
%      slope = 1/Vmax
%      y-intercept = km/Vmax
%           ---------
%           THEREFORE
%           ---------
%      vMax = 1/slope
%      km = y-intercept * Vmax
% NOTE : THIS METHOD'S CALCS COMPOUNDS EXPERIMENTAL ERROR. IMPROVEMENT NEEDED

% linearize data
linearSubstrateData = substrateData;
linearV0Array = linearSubstrateData ./ v0Array;

% find a regression line
linearCoeffs = polyfit(linearSubstrateData, linearV0Array, 1);

% seperate the slope and the intercept from the data
linearSlope = linearCoeffs(1);
linearYIntercept = linearCoeffs(2);

% calculate the parameters according to Hanes-Wolf method
vMax = 1 / linearSlope;
kM = linearYIntercept * vMax;

SSE = sum((v0Array - idealV0) .^ 2); % calculate and return the SSE


%% ____________________
%% ACADEMIC INTEGRITY STATEMENT
% We have not used source code obtained from any other unauthorized
% source, either modified or unmodified. Neither have we provided
% access to my code to another. The function we are submitting
% is our own original work.
end


