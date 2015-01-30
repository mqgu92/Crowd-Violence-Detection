function GLCM_Save(GLCMData, FRAMENUMBER, BASEOFFSET, SYMMETRY, LEVELS,...
    IMRESIZE,RANGE, PYRAMID,CURRENTPYRAMIDSTRUCTURE,DATA_VIDEO_CHOSENSET,VideoData)
%   Saves a GLCM Co-Occurance Matrix as a .MAT file 
%
%   REQUIRES all GLCM generation parameters
%   CURRENTPYRAMIDSTRUCTURE : The pyramid level used to compute the GLCM
%   PYRAMID : The entire geometric pyramid

SetupVariables; % Load the setup variables


if ~exist(DATA_GLCM,'dir')  % Create a GLCM Data Storage Folder
    mkdir(DATA_GLCM);
end

% Calculate Offset Neighbourhood
OFFSET = GLCM_CalculateNeighbourhood( BASEOFFSET,RANGE);

% Create Storage File
FolderExtension = GLCM_CalculateFolderName( BASEOFFSET,LEVELS,IMRESIZE,PYRAMID,RANGE,SYMMETRY);

FolderLocation = fullfile(DATA_GLCM,DATA_VIDEO_CHOSENSET.name,VideoData{3},FolderExtension);

if ~exist(FolderLocation,'dir')
    mkdir(FolderLocation);
end

% Create Settings File
if ~exist(fullfile(FolderLocation,'settings.mat'),'file')
    save(fullfile(FolderLocation,'settings.mat'),...
        'BASEOFFSET','OFFSET','SYMMETRY','LEVELS','IMRESIZE','RANGE','PYRAMID');
end
% Read the Video File
                    pyrString = [sprintf('%d',CURRENTPYRAMIDSTRUCTURE(1)),...
                        '-',sprintf('%d',CURRENTPYRAMIDSTRUCTURE(2))];
save( fullfile(FolderLocation,[num2str(MISC_Padzeros(FRAMENUMBER,6)),'pyr',pyrString,'.mat']),'GLCMData');

clear all;



end

