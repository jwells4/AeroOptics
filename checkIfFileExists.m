function [totalFilename, casenumber] = checkIfFileExists(saveDirectory, extension, filename)
% -------------------------------------------------------------------------
%
%
% Inputs:
%
% Outputs:
%
% Original Author: Barry Pawlowski <bpawlows@nd.edu>
%
% Last Updated: March 28,2018
% -------------------------------------------------------------------------
% --- Begin Function ---
casenumber = 1; stringNumber = leadingZeros(casenumber);

if ~exist(saveDirectory,'dir')
    mkdir(saveDirectory)
end

totalDirectory = [saveDirectory '\' filename stringNumber extension];

if exist(totalDirectory, 'file')
    fileYes = dir([saveDirectory '\*' extension]);
    for iFile = 1:length(fileYes)
        fileDirectory = fileYes(iFile).name;
        fileNameLast = regexp(fileDirectory, ['^.*(?=' extension ')'], 'match','lineanchors');
        fileNumber(iFile) = str2double(regexp(fileNameLast{1}, '\d*', 'match'));
    end
    
    casenumber = max(fileNumber) + 1;
    stringNumber = leadingZeros(casenumber);
end

totalFilename = [filename stringNumber];










