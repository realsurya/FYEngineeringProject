function [vMaxArray, kSubMArray, sseArray] = M3_exec_001_30();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENGR 132 
% Program Description 
% this executive funciton will use the algorithm to produce product 
% reaction velocity plots. Exec Will automatically calculate parameters
% vmax and km using the calculated values from the algorithm. Finally,
% the SSE values are calculated between the ideal and expected curve.
%
% Function Call
% [vMaxArray, kSubMArray, sseArray] = M3_exec_001_30();
%
% Input Arguments
% None
%
% Output Arguments
% vMaxArray - the array containing unique vmax values for the 5 enzymes
% kSubMArray - the array containing unique km values for the 5 enzymes
% sseArray - the array containing the SSE values for each enzyme compared
% to the ideal michales-mitten curve.
%
% Assignment Information
%   Assignment:     Milestone 3
%   Team member:    Surya Manikhandan, smanikha@purdue.edu
%                   Julius Mesa, jmesa@purdue.edu
%                   Alex Norkus, anorkus@purdue.edu
%                   Luming Lin, lin971@purdue.edu
%   Team ID:        001-30
%   Academic Integrity:
%     [] We worked with one or more peers but our collaboration
%        maintained academic integrity.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ____________________
%% INITIALIZATION

figureNumber = 1; % humds the number of the fugure window being plotted on

fileName = "Data_nextGen_KEtesting_allresults.csv"; % the name of the datafile

% import the [S] values used to produce the plots
substrateData = readmatrix(fileName, "range", "B3:CW3");

%% ____________________
%% CALCULATIONS & FIGURE DISPLAYS

%initialize outputs as null
vMaxArray = [];
kSubMArray = [];
sseArray = [];

for enzymeNum = 1:5 % loop through all enzymes
    
    % use algorithm to find the v0 values
    v0Vals = M3_Algorithm_001_30(enzymeNum);
    
    % find the starting column of [S] values for the given enzyme
    sColumn = 11 + (20 * (enzymeNum - 1));
    % compute [S] for reaction velocity plots
    sData = substrateData(sColumn : sColumn + 9);
    
    % linearize [S] and v values for the linear regression.
    linearSData = sData; % [s] vals do not need transformation to be linear
    linearV0Array = linearSData ./ v0Vals;
    
    % find a regression line
    linearCoeffs = polyfit(linearSData, linearV0Array, 1);

    % seperate the slope and the intercept from the data
    linearSlope = linearCoeffs(1);
    linearYIntercept = linearCoeffs(2);
    
    % calc Vmax and Km values through the Hanes-Wolf Method (explanation can be found in M2 exec function)
    vMax = 1 / linearSlope;
    kM = linearYIntercept * vMax;
    
    % calculate SSE values between expected and actual values for raw data
    idealV = (vMax .* sData) ./ (kM + sData); % calculate ideal v0 vals using Michaelis-Menten equation
    SSE = sum((idealV - v0Vals) .^ 2);
    
    %Add params to the output variables
    vMaxArray = [vMaxArray, vMax];
    kSubMArray = [kSubMArray, kM];
    sseArray = [sseArray, SSE];
    
    % figure displays
    figure(figureNumber);
    
    % First, plot the raw function output for reaction velocities
    subplot(1, 2, 1);
    plot(sData, v0Vals, 'ro');
    xlabel("Substrate Concentration [S] (uM)");
    ylabel("Reaction Velocity v (uM/min)");
    title("Unaltered Data");
    grid on
    hold on
    % overlay the ideal reaction velocity vector
    plot(sData, idealV, "-b");
    legend("Raw Reaction Velocity", "Michaelis-Menten Expected Vector", "location", "south");
    hold off
 
    
    % Next, plot the linearized data according to Hanes-Wolf method
    subplot(1, 2, 2);
    plot(linearSData, sData ./ v0Vals, 'ro');
    xlabel("Linearized Substrate Concentration");
    ylabel("Linearized Reaction Velocity");
    title("Linearized Data");
    grid on
    hold on
    % overlay the linear regression on to that line
    plot(linearSData, (linearSlope * linearSData) + linearYIntercept, '-b');
    legend("Linerized Reaction Velocity", "Hanes-Wolf Best Fit Line", "location", "north");
    hold off
    
    % title the overall figure and increment figure number
    figureTitle = sprintf("Reaction Velocity Plots for Enzyme %d (NextGen-%c)", enzymeNum, ('A' + (enzymeNum - 1)));
    sgtitle(figureTitle);
    figureNumber = figureNumber + 1;

end
%% ____________________
%% FORMATTED TEXT/FIGURE DISPLAYS


%% ____________________
%% COMMAND WINDOW OUTPUT


%% ____________________
%% ACADEMIC INTEGRITY STATEMENT
% We have not used source code obtained from any other unauthorized
% source, either modified or unmodified. Neither have we provided
% access to my code to another. The function we are submitting
% is our own original work.
end

