%{
***************************************************************************
Class file to setup and work with a national instruments data acquisition
device. There are 4 methods within this class file:

    1) sessionSetupNI
    2) signalOutput
    3) printSetup2Screen
    4) write2csv

@author:  Barry Pawlowski <bpawlows@nd.edu>
@version: September 16, 2020; currently updated to MATLAB 2020a
***************************************************************************
%}
classdef daqNIsetup
    properties
        %{
        Refer to the Mathworks documentation on acquiring data using a
        national instruments data acquisition device.
        %}
        boardVendor      = 'ni'; % This class file is written for national instruments
        boardIDs_input   = [];   % String of channel ids.
        nchannels_input  = [];   % Array of values for the channels for each id.
        boardIDs_output  = [];   % Channel id for output channel
        fsamp {mustBeNumeric}           % [Hz]
        sampleTime {mustBeNumeric}      % [sec]
        numberofsamples {mustBeNumeric} % sampleTime * fsamp
    end
    
    methods
        function [s, nChannels] = sessionSetupNI(obj, triggerYes)
            %{
            ***************************************************************
            Sets the session object for communicating with the Data
            Acquisition Device to aquire data.
            
            --- Inputs:
                    - obj: daqNIsetup object with properties above
                    - triggerYes(Bool): device uses trigger or not
            
            --- Outputs:
                    - s: DAQ object
                    - nchannels (numeric value): total number of channels
            ***************************************************************
            %}
            if nargin < 4; triggerYes = 0; end
            
            % Setting up the acqusition board parameters
            s         = daq(obj.boardVendor);
            s.Rate    = obj.fsamp;
            nChannels = sum(obj.nchannels_input);
            
            % Finds the modules based on space delimeter between each ID
            modules = textscan(obj.boardIDs_input,'%s','Delimiter',' ');
            modules = modules{1};
            
            if length(modules) ~= length(obj.nchannels_input)
                error('Number of channels per module does not equal number of modules')
            end
            
            % Add channels to the session for each card module
            for iModule = 1:length(modules)
                addinput(s,modules{iModule}, (1:obj.nchannels_input(iModule))-1, 'Voltage');
            end
            
            % Add Trigger if neccessary
            if triggerYes == 1
                boardID = modules{1};
                externalTrigSettings  = [boardID(1:5) '/PFI1'];
                externalClockSettings = [boardID(1:5) '/PFI0'];
                
                addtrigger(s, 'Digital', 'StartTrigger', 'External', externalTrigSettings);
                addclock(s, ScanClock', 'External', externalClockSettings);
                
                s.Condition = 'FallingEdge';
            end
        end
        
        function [] = signalOutput(obj,channel_output)
            %{
            ***************************************************************
            Sets the session object and uses it to communicatewith the Data
            Acquisition Device to send an output step..
            
            --- Inputs:
                    - obj: daqNIsetup object with properties above
                    - channel_output: Channel to send output signal
            
            --- Outputs: NO OUTPUTS
            ***************************************************************
            %}
            o = daq(obj.boardVendor);
            o.Rate = obj.fsamp;
            addoutput(o,obj.boardIDs_output,channel_output-1,'Voltage')
            
            % Waveform is a step function with a peak of 5V
            t                 = pi*linspace(0,1,1024)';
            waveform          = ((5/2) * square(2.*t, 50) + (5/2));
            outputdata        = ones(length(t), length(channel_output)) .* waveform;
            outputdata(end,:) = zeros(1,length(channel_output));
            
            write(o, outputdata)
            stop(o); delete(o);
        end
        
        function [] = printSetup2Screen(obj,saveDir,nchans)
            %{
            ***************************************************************
            Prints parameters of experiment to screen.
            
            --- Inputs:
                    - obj: daqNIsetup object with properties above
                    - saveDir: Directory where data will be saved
                    - nchans: total number of channels
            
            --- Outputs: NO OUTPUTS
            ***************************************************************
            %}
            fprintf('\n----- Data Acqusition Parameters ---\n')
            fprintf('\t -> Number of Channels: %1.0f \n', nchans)
            fprintf('\t -> Sample Rate: %6.0f hz \n', obj.fsamp)
            fprintf('\t -> Sample Time: %2.0f sec \n', obj.sampleTime)
            fprintf('\t -> Number of Samples: %6.0f \n', obj.numberofsamples)
            
            % If it starts with a file seperator the file is being saved to
            % the current directory. Here, just want to display the folder
            % and not the filename.
            if startsWith(saveDir,'\')
                saveDir = [pwd, '\'];
            else
                indexSaveDir = regexp(saveDir, '\');
                saveDir = saveDir(1:indexSaveDir(end));
            end
            fprintf('\n Save Directory: \n\t%s \n\n', saveDir)
        end
        
        function [] = write2csv(obj,data,timestamp,totaldir,print2screenBool)
            %{
            ***************************************************************
            Provides additional functionality to the timetable output from
            the data acquisition read(). Adds the following parameters to
            the csv file:
                    1) Sample Time stamp
                    2) Sample Frequency
                    3) Sample Time
            
            --- Inputs:
                    - obj: daqNIsetup object with properties above
                    - data: timetable from [data,timestamp] = read()
                    - timestamp: timestamp from [data,timestamp] = read()
                    - totaldir: directory and filename of savefile
                    - print2screenBool (bool): Print save to screen
            
            --- Outputs: NO OUTPUTS
            ***************************************************************
            %}
            
            %%% TO DO %%%
            %{
                Need to create an optional positional location for CSV file
                experimental output parameter.
            %}
            
            % This isn't absolutely necessary for the MATLAB function to
            % work, but it is nice output for the screen.
            if ~endsWith(totaldir, '.txt')
                totaldir = [totaldir, '.txt'];
            end
            
            %{
                Want to include additioanl experimental data into CSV file:
            %}
            varfreq       = strings(1,2);
            vartimestamp  = strings(1,2);
            varsampletime = strings(1,2);
            
            % Assign Variables
            vartimestamp(1)  = 'Time Stamp:';        vartimestamp(2)  = timestamp(:);
            varfreq(1)       = 'Frequency-[Hz]:';    varfreq(2)       = obj.fsamp;
            varsampletime(1) = 'Sample Time-[sec]:'; varsampletime(2) = obj.sampleTime;
            
            if print2screenBool == 1; fprintf('\nSaving data...\n'); end
            % Write experimental data and append collected data
            writematrix([vartimestamp;varfreq;varsampletime], totaldir, 'delimiter','\t')
            writetimetable(data,totaldir,'delimiter','\t','WriteMode','append','WriteVariableNames',1)
            if print2screenBool == 1
                fprintf('\t...data saved\n')
                fprintf('-> Directory: %s\n\n', totaldir)
            end
        end
    end
end






