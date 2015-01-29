%% Generate STIP

% Directoy Full of Videos
VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\Videos - Copy';
addpath(genpath(VIDDIR))

%% Generate Video List
dirInfo = dir(strcat(VIDDIR,'\*.avi'));
dirSize = size(dirInfo);


%% Create an output directory for the features
STIPOUT = 'VIFDATA';

% Create the output directory if Needed
if (~exist(STIPOUT,'dir'))
    disp('Not Exist');
    mkdir([STIPOUT]);
end

for i = 1: dirSize(1)
    [PATHSTR,NAME,EXT] = fileparts(dirInfo(i).name);
    % Only Seems to work if the video is in the same dir as stipdet.exe
    copyfile([VIDDIR,'\',NAME,'.avi'],['stip\bin\',NAME,'.avi'])
    % Execute STIP
    system(['stip\bin\stipdet.exe -vis no -f ',NAME,'.avi -o ',STIPOUT,'\', NAME ,'-STIP.txt']);
    % Don't need the copy anymore so delete it
    delete(['stip\bin\',NAME,'.avi']);
end
