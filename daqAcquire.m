%{
***************************************************************************
Program  communicate with the Data Aquistion Board in order to collect data
in the foreground. Allows for stepping as well. Program is written in a 
way to require an input script, but this can be replaced with "inline" user
inputs. (see sample input file -> sampleDataAcqusition.txt). This particular 
program communicates using MATLAB's session based interface.

@author:  Barry Pawlowski <bpawlows@nd.edu>
@version: September 16, 2020, currently updated to MATLAB 2020a

--- Required to run Program (3 additional files) ---
      -> Class file: directoryInOut.m
      -> Class file: daqNIsetup.m
      -> User input file (optional)
***************************************************************************
%}
clear; clc;
dataAcquisitionObject  = daqNIsetup;
fileImportExportObject = directoryInOut;

% Load in inputs from textfile and place those inputs into the DAQ object
invals = fileImportExportObject.asciiparser('dataAcquisition.txt');

% ----------- These values can be manually specified if desired ----------
dataAcquisitionObject.fsamp            = invals.fsamp;
dataAcquisitionObject.sampleTime       = invals.sampleTime;
dataAcquisitionObject.boardIDs_input   = invals.boardIDs_input;
dataAcquisitionObject.nchannels_input  = invals.nchannels_input;
dataAcquisitionObject.boardIDs_output  = invals.boardIDs_output;
dataAcquisitionObject.numberofsamples  = invals.fsamp * invals.sampleTime;
fileImportExportObject.wkdir           = invals.wkdir;
fileImportExportObject.numberofsteps   = invals.numberOfSteps;
% -----------------------------------------------------------------------------

%{
Setting up the data acqusition analog input channels.. Additionally, create
the total output directory. This is done here instead of in the for loop i
in order to make the loop cleaner.
%}
[fileImportExportObject,totaldirarray] = fileImportExportObject.totalDirMake();
[s,nChannels] = dataAcquisitionObject.sessionSetupNI(invals.triggerYes);
dataAcquisitionObject.printSetup2Screen(totaldirarray{1},nChannels);

%{
For homing DAQ device (need to specificy channel for homing). Comment this
out if not needed.
%}
if invals.numberOfSteps > 1
    % Homing signal (in case it is not homed already)
    dataAcquisitionObject.signalOutput(2);
end

for istep = 1:invals.numberOfSteps
    fprintf('****** Step Number: %2.0f ****** \n', istep)
    pause(invals.pauseTime);
    
    [sampledata,timestamp] = read(s, seconds(invals.sampleTime));
    dataAcquisitionObject.write2csv(sampledata,timestamp,totaldirarray{istep},1)
    
    %{
    Here, an output signal is sent to one channel for the step (1 <istep < nsteps), 
    the other is for homing (istep = nsteps/nsteps ~= 1)
    %}
    if istep ~= invals.numberOfSteps 
        % Steping Signal
        dataAcquisitionObject.signalOutput(3);
    elseif invals.numberOfSteps >1 && istep == invals.numberOfSteps
        % Homing Signal
        dataAcquisitionObject.signalOutput(2);
    end
end

stop(s); delete(s);
fprintf('\n **** DAQ Acquisition Complete, File Number: %s **** \n', fileImportExportObject.caseNameNumber)
