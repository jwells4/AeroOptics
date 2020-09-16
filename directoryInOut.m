%{
***************************************************************************
Class file to work with directories and script inputs. Typical functions
that people might use for their saving their experiment results. There are
3 static function and 1 other function:

    1) asciiparser (static)
    2) getDirectoryNames (static)
    3) append_wkdir (static)
    4) totalDirMake

@author:  Barry Pawlowski <bpawlows@nd.edu>
@version: September 16, 2020; currently updated to MATLAB 2020a
***************************************************************************
%}
classdef directoryInOut
    properties
        wkdir = []                    % string of directory of interest
        caseNameNumber = []           % string - format: [mmm dd yy ###]
        numberofsteps {mustBeNumeric} 
    end
    
    methods(Static)
        function [importedStructure] = asciiparser(totaldir)
            %{
            ***************************************************************
            Reads and interprets a user input file. Saves the it to a
            structure dynamically. Usefulness of this comes into play if
            one wants to keep track of their experimental parameters from
            experiment to experiment.
            
            --- Inputs: 
                    - totaldir: path and filename of inputfile
            
            --- Outputs:
                    - importedStructure: Dynamic structure interpreted from
                                         import file.
            ***************************************************************
            %}
            
            %{
            Since this is an ASCII file, fopen will provide the ID and textscan will
            read in every word (or number) as a seperate cell into MATLAB. These
            inputs are created as strings and this will be accounted for later.
            %}
            loadID    = fopen(totaldir, 'r');
            fileData = textscan(loadID, '%s', 'Delimiter', '\n');
            fclose(loadID);
            fileData = fileData{1};
            
            %{
            Remove the lines with comments on them (comments here are classified as '//')
            as well as the empy lines.
            %}
            for iLine = 1:length(fileData)
                if ~startsWith(fileData{iLine},'//')
                    fileDataTruncate{iLine} = fileData{iLine};
                end
            end
            fileDataTruncate = fileDataTruncate(~cellfun(@isempty,fileDataTruncate));
            
            %{
            Obtaining the variable and its value from the remaining strings
            in the import. Will classify variable as everything to the
            left of the '=' sign and the value as everything to the right
            of the '=' sign. Also removes the comments on this line if
            there are any.
            %}
            for iVariableLine = 1:length(fileDataTruncate)
                indexEqual   = strfind(fileDataTruncate{iVariableLine}, '=');
                indexComment = strfind(fileDataTruncate{iVariableLine}, '//');
                
                if ~isempty(indexComment)
                    fileDataTruncate{iVariableLine} = fileDataTruncate{iVariableLine}(1:indexComment-1);
                end
                
                varKey   = strip(fileDataTruncate{iVariableLine}(1:indexEqual-1));
                varValue = strip(fileDataTruncate{iVariableLine}(indexEqual+1:end));
                
                % Using str2num because inputs might be arrays.
                if ~isempty(str2num(varValue))
                    varValue = str2num(varValue);
                end
                
                % Dynamically allocated MATLAB structure.
                importedStructure.(varKey) = varValue;
            end
        end
        
        function [subdir] = getDirectoryNames(wkdir)
            %{
            ***************************************************************
            Obtains all filenames and folders within the given directory
            that isn't "." and "..".
            
            --- Inputs: 
                    - wkdir: Directory of interest
            
            --- Outputs:
                    - subdir: filenames and folders within wkdir
            ***************************************************************
            %}
            pathvals  = dir(wkdir);
            pathnames = { pathvals.name };
            
            % Check for '.' and '..' and remove them.
            subdir = {};
            for ipv = 1:length(pathnames)
                if ~startsWith(pathnames{ipv}, '.')
                    subdir{ipv} = pathnames{ipv};
                end
            end

            subdir = subdir(~cellfun(@isempty,subdir));
        end
        
        function appenddir = append_wkdir(str)
            %{
            ***************************************************************
            Appends a file seperator onto the given string if it doesn't
            exist.
            
            --- Inputs: 
                    - str: Directory of interest
            
            --- Outputs:
                    - appendir: str with file seperator on end (if not already there) 
            ***************************************************************
            %}
            if ~endsWith(strip(str), '\')
                %{
                Check if wkdir is actually empty. isempty() does not work with '''',
                since the ' ' are counted as characters. Therefore checking for letters
                is more reliable in checking the directory.
                %}
                indexLetter = isletter(str);
                if sum(indexLetter) == 0; str = ' '; end
                appenddir   = [strip(str), '\'];
            else
                appenddir = str;
            end
        end
    end
    
    methods
        % --- Allow the class file to set the object variables ---
        function obj = set.wkdir(obj,str)
            obj.wkdir = str;
        end
        
        function obj = set.caseNameNumber(obj,str)
            obj.caseNameNumber = str;
        end
        % --------------------------------------------------------
        
        function [obj,totaldirs] = totalDirMake(obj)
            %{
            ***************************************************************
            Creates the total save files (directory + filename) depnding on the
            following file structure:
            
                                filename = string([mmm dd yy ###])
            
            It will auto append to this format (matching [mmm dd yy]) if
            these already exist in directory to the next available number.
            This only checks the largest number (will not check gaps in
            numbers).
            
            Object for number of steps is checked. If it is equal to 1,
            then filename is a csv file. If it is greater than one, it is a
            folder for the csv files with: File1.txt, File2.txt, ... , 
            FileN.txt where N = number of steps.

            --- Inputs:
                 - obj: daqNIsetup object with properties above
    
             Outputs:
                 - obj: daqNIsetup object with properties above 
                        (altered wkdir and caseNameNumber properties)
                - totaldirs: complete file string of save files.
                
            ***************************************************************
            %}
            
            % Put file seperator on end of directory if not there.
            obj.wkdir = directoryInOut.append_wkdir(obj.wkdir);
            
            caseName = datestr(now, 'mmmddyy'); % Casename based on day
            % Checking if this exists to append or not
            if ~exist(obj.wkdir, 'dir')
                mkdir(obj.wkdir)
                caseNumber = 1;
            else
                listings    = directoryInOut.getDirectoryNames(obj.wkdir);
                matchingDay = listings(~cellfun(@isempty, regexp(listings, caseName, 'match')));
                
                % Append to the next number of that listing. If there are no listings then
                % it is automatically one, else it will append to the digits of the highest
                % number in that directory.
                if isempty(matchingDay)
                    caseNumber = 1;
                else
                    caseNumber = str2double(matchingDay{end}(end-2:end)) + 1;
                end
            end
            
            % Create casename from zeros on casenumber
            zerosString        = num2str(zeros(1,(3-length(num2str(caseNumber)))));
            zerosString        = zerosString(~isspace(zerosString));
            obj.caseNameNumber = [caseName zerosString num2str(caseNumber)];
            
            % If nP_Yes is 2 or greater a directory will be created with the
            % caseNameNumber, else the caseNameNumber is a file.
            if obj.numberofsteps == 1
                totaldirs = {[obj.wkdir, obj.caseNameNumber]};
            else
                filenumbers = 1:obj.numberofsteps;
                saveDirectoryMake = [obj.wkdir, obj.caseNameNumber];
                
                %{
                If the folder starts with a file seperator it will make the save
                directory in the default OS drive. By removing it, it will make it in
                the current working directory. (Only an issue when saving to the
                current directory)
                %}
                
                if startsWith(saveDirectoryMake,'\')
                    saveDirectoryMake = saveDirectoryMake(2:end);
                end
                err = mkdir(saveDirectoryMake);
                if err == 0
                    error('Making save directory was unsuccesful');
                end
                
                obj.caseNameNumber = ['\' obj.caseNameNumber];
                filenames      = strcat('File', string(filenumbers));
                totaldirs      = strcat(saveDirectoryMake, '\', filenames);
            end
        end
    end
end






