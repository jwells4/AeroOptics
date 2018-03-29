function [saveDirectory, caseName] = saveFileCreation(wkdir, experiment, tunnel, nP_Yes)
% -------------------------------------------------------------------------
% Program takes certain inputs in order to create the desired save file
% dependent on the experiment.  The additional function of this program is
% to analyze the casenumber inputed with what is already in the save
% directory and if it exists there is an option to append to the next
% available case number.
%
% The program will output a file with the casename if the variable nP_YEs
% is not given. If nP_Yes is used, it will create a directory using the
% appropriate case number and then provide a caseName that will not
% override the current data inside the folder.
%
% Inputs:
%       wkdir: The working directory - everything from here will be appended
%       experiment:  What experiment is being performed
%       tunnel:  Windtunnel the experiment is performed in
%       nP_Yes: If wanting to create the casenumber directory and not file.
%                   i.e. If this is a scanivavle measurement
%
% Outputs:
%       - saveFilename:  The filename created after running this program
%       - casenumber:  Will output the (altered) casenumber
%
% Original Author: Barry Pawlowski <bpawlows@nd.edu>
%
% Last Updated: February 26, 2018
% -------------------------------------------------------------------------
% --- Begin Fucntion ---
% Check if the input is to be a directory or a file.
if nargin < 4
    nP_Yes = nan;
end

% Create data string for the current day
casenumber = 1; % Initial case number, will be changed if already exists
[~,runNumber] = leadingZeros(casenumber);

% Book keeping for the current day
today = date; year = today(end-3:end); datestring = [today(4:6) today(1:2)];
caseName = [datestring year(3:4) runNumber];

% Through all information, the extended directory will be appended from the
% working directory
extendedDirectory = [wkdir '\' tunnel '\' experiment 'Data\' year];
if ~exist(extendedDirectory , 'dir')
    mkdir(extendedDirectory)
end

% The working directory is now created here.  Now moving forward if there
% is a scanivalve involved the caseName will become a folder and not a
% directory.  Else, the caseName is always a file.
if isnan(nP_Yes)
    dirType = 'file'; extension = '.mat'; checkNumberExist = 2;
else
    dirType = 'dir'; extension = '\'; checkNumberExist = 7;
end

saveDirectory = [extendedDirectory '\'];
saveCheck = exist([saveDirectory caseName extension], dirType); % Directory to be checked
index = 1;

while saveCheck == checkNumberExist
    caseNumberi = casenumber + index;
    [~,caseN] = leadingZeros(caseNumberi);
    caseName = [datestring year(3:4) caseN];
    
    saveCheck = exist([saveDirectory caseName extension], dirType);
    
    % Increment index, loop will exit if conditions are met anyways.
    index = index+1;
end

% If the directory exists create a file that does not overwrite anything
% currently in the folder.

if checkNumberExist == 7
    saveDirectory = [saveDirectory caseName];
    mkdir(saveDirectory)
end






