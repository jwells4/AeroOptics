function [data, caseNameNum] = loadFilename(wkdir, experiment, tunnel, nrun, caseName, nP)
% -------------------------------------------------------------------------
% Takes information in order to load data from DAQ collection.  User
% directory must follow the same format always after the working directory.
% The following format is used:
%
%         format:  [wkdir '\' tunnel '\' experiment 'Data\' year]
%              -> additional file structure is dependent on the experiment
%
% NOTE: The correct file structure will be used if saveFilename is used in
% data acqusition in order to save the file for the experiment.
%
% This funtion is meant to load only one file at a time.  This allows for
% simplicity of use to use with any funtion (since the use of the load in
% file is not known).
%
% Inputs:
%       wkdir: The working directory - everything from here will be appended
%       experiment: Experiment run:
%                       i.e. Pressure, Hotwire, CFD, etc...
%       tunnel: The tunnel in which the experiment was run in
%                       i.e.  Hessert, Whitefield
%       nrun:  Number of the run
%       caseName:  Format - [month (abbreviation), day (2digits), year(last 2 digits)]
%       nP: Pressure port number (if this is a scanivavle measurement)
%
% Outputs:
%       data:
%       caseNameNum:
%
% Original Author: Barry Pawlowski <bpawlows@nd.edu>
%
% Last Updated: March 27, 2018
% -------------------------------------------------------------------------
% --- Begin Function ---
if nargin < 6; nP = nan; end

if ~strcmp(experiment, 'CFD')
    % The year is created because the directory for the experiment is sorted
    % by years and the run number is converted to a string in order to place it
    % in the text string for the directory.
    year = ['20' caseName(end-1:end)];
    extendedDirectory = [wkdir '\' tunnel '\' experiment 'Data\' year];
    
    % The directory will always be the same if there is no scanivalve used.
    % Where the filename is the file.  If there is a scanivalve the filename is
    % the folder and within the folder there is a number of scanivavle ports.
    if strcmp(experiment, 'HotwireCalibration')
        caseNameNum = [caseName ' - Probe' num2str(nrun)];
    else
        runNumber = leadingZeros(nrun);
        caseNameNum = [caseName runNumber]; % Can be useful, therefore output
    end
    
    if isnan(nP)
        loadDirectory = [extendedDirectory '\' caseNameNum '.mat'];
    else
        loadDirectory = [extendedDirectory '\' caseNameNum '\Scanivalve_' num2str(nP) '.mat'];
    end
    
    data = load(loadDirectory);  % Data loaded in as a structure, depending on data saved
else
    
    % The CFD loading portion needs to be implemented - However this is
    % never going to be optimized for everyone.  This section is a matter
    % of personal preference.
    
end






