function [dataOut] = loadInputs(inputFile)
% ------------------------------------------------------------------------- 
% This function is used in order to load a generic inputfile into MATLAB.
% This program does not care how many variables are inserted into the file
% or what is written in it.  The only requirement for the input file is
% that the following construct is used for the input variables:
% 
%           Format:        "variable" = "value"
% 
%      ->  The variable name can be anything as long as it follows the
%          requirements for a variable convention.
%
%      -> An '=' sign is used as the character denoting a variable
%       
%      -> The value can be a string, or an array of numbers.
% 
% Inputs:
%           inputFile:  Filename of the input file.  The file needs to be
%                       an ASCII file.
% 
% Outputs: 
%           dataOut:    Output structure containing all inputs from the
%                       load file.
% 
% Original Author: Barry Pawlowski <bpawlows@nd.edu>
% 
% Last Updated: March 19, 2018
% -------------------------------------------------------------------------
% --- Begin Function ---
% Since this is an ASCII file, fopen will provide the ID and textscan will
% read in every word (or number) as a seperate cell into MATLAB.  These
% inputs are created as strings and this will be accounted for later.
loadID = fopen(inputFile, 'r'); 
inputData = textscan(loadID, '%s', 'Delimiter', '\n');
inputData = inputData{1};

% "//" is a commented line, and all of these will be removed from the
% variables of interest.
commentIdentify = regexp(inputData, '//');
indexCompleteComment = cellfun(@isempty,commentIdentify);
variablesWithoutComment = inputData(indexCompleteComment);

% Here the indicies that say where the variables and their values are
% located. "ind" uses the regular expression "=" to locate the middlepoint
% for each variable and then "indC" allows to find where they are exactly
% located since regexp states where they are but gives empty matricies for
% where they aren't.
indexMidIndentify = regexp(variablesWithoutComment,'[=]');
indexComplete = cellfun(@isempty,indexMidIndentify);
variablesIndex = find(indexComplete == 0);

% Here the dataOut structure will be created using the names of the
% variables that were constructed in the input file.
for iVar = 1:length(variablesIndex)
    currentVariableLine = variablesWithoutComment{variablesIndex(iVar)};

    % An '=' sign denotes a variable.  Everything before that is the name
    % and everything after that is the value assigned to that variable.
    % strtim is used to trim the excess of whitespace at the beginning and
    % end of the variable.
    indexMidSplit = regexp(currentVariableLine, '={1}');
    variableName = strtrim(currentVariableLine(1:indexMidSplit(1)-1));
    variableValue = strtrim(currentVariableLine(indexMidSplit(end)+1:end));
    
    % Check if the input variable is numerric. If it is than evaluate it as
    % numeric and then it is the new variable.
    numVarCheck = str2num(variableValue);
    if ~isempty(numVarCheck) 
        variableValue = numVarCheck;        
    end
    
    % Output dynamic variable name to structure
    dataOut.(variableName) = variableValue;
end

