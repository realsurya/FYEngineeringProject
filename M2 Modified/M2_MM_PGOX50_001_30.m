function [SSE] = runReferencePlots(dataType); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENGR 132 
% Program Description 
% This function will produce reference plots for part 2 Section A
% This allows us to get a better idea of what to do for actual calcs.
% additionally, we will calculate the SSE
%
% Function Call
% [vMax, kM] = runReferencePlots(dataType);
%
% Input Arguments
% dataType: the datatype being examined (either 'noisy' or 'clean')
%
% Output Arguments
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

% set the appropriate filename and given parameters for calculation of SSE
if dataType == 'noisy'
    fileName = "Data_PGOX50_noisy.csv";
    givenv0 = [0.028, 0.055, 0.11, 0.19, 0.338, 0.613, 0.917, 1.201, 1.282, 1.57];
    vMax = 1.72;
    kM = 226.92;
elseif dataType == 'clean'
    fileName = "Data_PGOX50_clean.csv";
    givenv0 = [0.028, 0.056, 0.11, 0.193, 0.360, 0.6, 0.883, 1.212, 1.376, 1.584];
    vMax = 1.61;
    kM = 214.28;
else
    fprintf(2,"Parameter Error: dataType must be either 'noisy' OR 'clean'\n");
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
    velocityVector = givenv0(productNum) * time; % calculate the tangent line for the v0 velocity vector

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
    figureTitle = sprintf("Reference plots for %s data.", dataType);
    sgtitle(figureTitle);
    
end

%% ____________________
%% PLOT 2 - REACTION VELOCITY PLOT

figure(2); % set new figure
plot(substrateData, givenv0, "ro"); % plot the substrateData and v0 Array with markers only

hold on
idealV0 = (vMax .* substrateData) ./ (kM + substrateData); % calculate ideal v0 vals using Michaelis-Menten equation
plot(substrateData, idealV0); % plot the Michaelis-Menten equation output


% title and label the plot to format for technical presentation
title({"Reaction Velocity vs Substrate Concentration", figureTitle});
xlabel("Substrate Concentration [S] (uM)");
ylabel("Reaction velocity v (uM/min)");
legend("Original Data", " Expected Reaction Velocity Vector", 'location', 'southeast');
grid on

%% ____________________
%% COMMAND WINDOW OUTPUT

SSE = sum((givenv0 - idealV0) .^ 2); % calculate and return the SSE

%% ____________________
%% ACADEMIC INTEGRITY STATEMENT
% We have not used source code obtained from any other unauthorized
% source, either modified or unmodified. Neither have we provided
% access to my code to another. The function we are submitting
% is our own original work.
end


