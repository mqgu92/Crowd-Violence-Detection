% For GEP Feature extraction refer toi GEP.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Violent Flows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OUTPUT = 'ALL DATA\Out';
%DATA = 'Cardiff-Original';
%DATA = 'Cardiff';
DATA = 'ViFData';
%DATA = 'Hockey';

WINDOWLENGTH = 5;  % Window Sampling Length
WINDOWSKIP = 40;    % Frames to skip between adjacent samples
XCELLS = 4;         % Horizontal Spatial Frame Split
YCELLS = 4;         % Vertical Spatial Frame Split
HISTSIZE = 80;      % NUmber of bins used to represent motion
PCA = true;         % Perform PCA?


if strcmp(DATA,'Hockey')
    FLOWDIR = 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\SIFTFlows\FLOWS\Cross\';
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\SIFTFlows\FLOWS\Cross\' );
    addpath(genpath('Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\Video\'));

    FOLD = 5;
elseif strcmp(DATA,'Cardiff-Original')
    FLOWDIR = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four Original\SIFTFlows\';
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four Original\SIFTFlows\' );
    addpath('E:\VideoPlayback\VideoCutsSmall');
    FOLD = 4;
    
    FLOWLIST{1,6} = [];
    % Override window skip offset for scenes of violence
    FLOWLIST(find(ismember(FLOWLIST(:,3),'Fight')),6) = {1};
    FLOWLIST(find(ismember(FLOWLIST(:,3),'NotFight')),6) = {WINDOWSKIP};
elseif strcmp(DATA,'Cardiff')
    addpath('E:\VideoPlayback\VideoCutsSmall');
    FOLD = 4;
    %Sift Flow Fields
    FLOWDIR ='Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\SIFTFlows\';
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\SIFTFlows\' );
    % Optical Flow Fields
    %FLOWLIST = LoadDataSet('Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\OpticalFlows\'); 
    %FLOWDIR = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\OpticalFlows\';
    
    FLOWLIST{1,6} = [];
    % Override window skip offset for scenes of violence
    FLOWLIST(find(ismember(FLOWLIST(:,3),'Fight')),6) = {1};
    FLOWLIST(find(ismember(FLOWLIST(:,3),'NotFight')),6) = {WINDOWSKIP};
    
elseif strcmp(DATA,'ViFData')
    % SIFT Flow
    FLOWDIR ='Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\SIFTFlows\';
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\SIFTFlows\' ); 
    % Optical Flow
    %FLOWLIST = LoadDataSet('Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\OpticalFlows\');
    %FLOWDIR = 'Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\OpticalFlows\';
    
    addpath(genpath('Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\Videos\'));
    FOLD = 5;
end

if ~exist(OUTPUT ,'dir')
    mkdir(OUTPUT);
end


%% VIF

% Extraction
Descriptors = []; % Descriptors, Tags
DescriptorsTags = [];
ViFClasses = [];
vs = size(FLOWLIST);
fs = size(FLOWLIST);
totalTime = 0;
for i = 1 : vs(1)
    tic;
    % Check if the window skip offset has been overridden
    if fs(2) >5
        WINDOWSKIP = FLOWLIST{i,6};
    end
    % Extract VIF features 
    
    vidScene = GetViFDescriptors(FLOWDIR,  FLOWLIST{i,1} ,WINDOWLENGTH,WINDOWSKIP,XCELLS,YCELLS,HISTSIZE );
    
    if ~isempty(vidScene) && iscell(vidScene);
        
        Descriptors = [Descriptors;vidScene];
        ds = size(vidScene);
        % CLASSES
        clear Tags
        [Tags{1:ds(1)}] = deal(FLOWLIST{i,3});
        DescriptorsTags = [DescriptorsTags;Tags'];
        % VIF DATA
        clear Tags
        [Tags{1:ds(1)}] = deal(FLOWLIST{i,4});
        ViFClasses = [ViFClasses;Tags'];
    end
    currentTime = toc;
    totalTime = totalTime + currentTime;
    disp(strcat(num2str(currentTime),'(',num2str(totalTime),')'));
end



if PCA
    ElementsToKeepMin = 5;%;
    %% Perform PCA on DATA
    pyrDataSize = size(Descriptors);
    %Fill in missing data
    
    %Create Mat vectors
    yMatVect = zeros(length(Descriptors),1);
    for m = 1:length(Descriptors)
        subSize = size(Descriptors{m});
        yMatVect(m) = subSize(1);
    end
    numericFlatData = cell2mat(Descriptors);
    %Perform Reduction
    [~,PC, e] = princomp(numericFlatData);
    
    esum = sum(e);
    eperc = esum * 0.90;
    % Keep 95% of eigen data
    ElementsToKeep = 0;
    for i = 1: length(e)
        if sum(e(1:i)) >= eperc
            ElementsToKeep = i;
            break;
        end
    end
    if ElementsToKeep < ElementsToKeepMin
        ElementsToKeep = ElementsToKeepMin;
    end
    
    % Reconstruct Data
    numericFlatData = PC(:,1:ElementsToKeep);
    Descriptors = mat2cell(numericFlatData,yMatVect,ElementsToKeep);
    
end

VIFDescriptors = Descriptors;
VIFDescriptorsTags = DescriptorsTags;
subName = [DATA,'VIF'];
save(strcat(OUTPUT,'/',subName,'.mat'),...
    'VIFDescriptors',...
    'VIFDescriptorsTags',...
    'ViFClasses',...
    '-v7.3');

 clear all;

% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Trajectory HOF OPTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OUTPUT = 'ALL DATA\Out';
%DATA = 'Cardiff-Original';
%DATA = 'Cardiff';
DATA = 'ViFData';
%DATA = 'Hockey';

FEATURES = 300;     %   Feature points per scene
TRAINPERC = 0.70;   %   Percentage of data to train
WINDOW = [5]; % Trajectory Length
WINDOWSKIP = 40;        % Distance Between Samples
ACCESSMETHOD = 'RANDOM';    %Does nothing
PYRAMIDSTRUCT = [1,1;2,2];  %Spatial Structure
PCA_OVERRIDE = 0;   % Override the number of PCA elements kept
PCA = true;     %Perform PCA?    

% Set up the data
if strcmp(DATA,'Hockey')
    FLOWDIR = 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\SIFTFlows\FLOWS\Cross\';
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\SIFTFlows\FLOWS\Cross\' );
    addpath(genpath('Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\Video\'));

    FOLD = 5;
elseif strcmp(DATA,'Cardiff-Original')
    FLOWDIR = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four Original\SIFTFlows\';
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four Original\SIFTFlows\' );
    addpath('Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\VideoCutsSmall');
    FOLD = 4;
    FLOWLIST{1,6} = [];
    FLOWLIST(find(ismember(FLOWLIST(:,3),'Fight')),6) = {1};
    FLOWLIST(find(ismember(FLOWLIST(:,3),'NotFight')),6) = {WINDOWSKIP};
elseif strcmp(DATA,'Cardiff')
    FLOWDIR ='Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\SIFTFlows\';
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\SIFTFlows\' );
    addpath('Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\VideoCutsSmall');
    % FLOWLIST = LoadDataSet('Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\OpticalFlows\'); % Optical Flow
    % FLOWDIR = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\OpticalFlows\';   
    FOLD = 4;
    FLOWLIST{1,6} = [];
    FLOWLIST(find(ismember(FLOWLIST(:,3),'Fight')),6) = {1};
    FLOWLIST(find(ismember(FLOWLIST(:,3),'NotFight')),6) = {WINDOWSKIP};
elseif strcmp(DATA,'ViFData')
    FLOWDIR ='Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\SIFTFlows\';
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\SIFTFlows\' );
    addpath(genpath('Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\Videos\'));
    %FLOWLIST = LoadDataSet('Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\OpticalFlows\'); % Optical Flow
    %FLOWDIR = 'Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\OpticalFlows\';
    FOLD = 5;
end

if ~exist(OUTPUT ,'dir')
    mkdir(OUTPUT);
end

% Extract TRRAJHOF Features
[ ALL_FEATURES, STRUCTURED_FEATURES ] = TEST_TRAJHOF_EXTRACT( FLOWLIST,FLOWDIR,FEATURES, WINDOW,WINDOWSKIP,PYRAMIDSTRUCT );

% Re-arrange the feature form and apply PCA
[ FINAL_ALL_FEATURES, FINAL_STRUCTURED_FEATURES, FINAL_ALL_CLASSES,FINAL_STRUCTURED_CLASSES,PCA_FINAL_ALL_FEATURES,PCA_FINAL_STRUCTURED_FEATURES ]...
    = TEST_TRAJHOF_PROCESS( ALL_FEATURES,...
    STRUCTURED_FEATURES ,...
    PCA,...
    0)
    %Set PCA data as main data
    FINAL_ALL_FEATURES = PCA_FINAL_ALL_FEATURES;
    FINAL_STRUCTURED_FEATURES = PCA_FINAL_STRUCTURED_FEATURES;

% Save all REsults    
subName = [DATA,'TRAJHOF'];
save(strcat(OUTPUT,'/',subName,'.mat'),...
    'FINAL_ALL_FEATURES',...
    'FINAL_STRUCTURED_FEATURES',...
    'FINAL_ALL_CLASSES',...
    'FINAL_STRUCTURED_CLASSES',...
    '-v7.3');

clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Motion Binary Patterns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OUTPUT = 'ALL DATA\Out';
%DATA = 'Cardiff-Original';
%DATA = 'Cardiff';
DATA = 'ViFData';
%DATA = 'Hockey';

PCA = true; % Perform PCA?
IMSIZE      = [100 100];    % Resize image dimensions
MATRIXSIZE  = 3;            % Matrix size for flow estimation
TIMESTEP    = [1 2];  % Temporal Steps
WINDOW      = 5;           % Sampling Window
THRESH      = 7;            % MOtion Threshold
FRAMEJUMP   = 40;           % Frames between samples
BASE        = 0;    % Can't Remember

% Set up data
if strcmp(DATA,'Hockey')
    FLOWDIR = 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\SIFTFlows\FLOWS\Cross\';
    
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\SIFTFlows\FLOWS\Cross\' );
    addpath(genpath('Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\Video\'));
    FOLD = 5;
    STIPOUT = 'HOCKEY2';
    VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\Video';
    addpath(genpath(VIDDIR))
elseif strcmp(DATA,'Cardiff-Original')
    FLOWDIR = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four Original\SIFTFlows\';
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four Original\SIFTFlows\' );
    VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\VideoCutsSmall';
    addpath(genpath(VIDDIR))
    FOLD = 4;
    STIPOUT = 'CARDIFF';
    FLOWLIST{1,6} = [];
    FLOWLIST(find(ismember(FLOWLIST(:,3),'Fight')),6) = {1};
    FLOWLIST(find(ismember(FLOWLIST(:,3),'NotFight')),6) = {FRAMEJUMP};
elseif strcmp(DATA,'Cardiff')
    FLOWDIR ='Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\SIFTFlows\';
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\SIFTFlows\' );
    VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\VideoCutsSmall';
    addpath(genpath(VIDDIR))
    FOLD = 4;
    STIPOUT = 'CARDIFF';
    
    FLOWLIST{1,6} = [];
    FLOWLIST(find(ismember(FLOWLIST(:,3),'Fight')),6) = {1};
    FLOWLIST(find(ismember(FLOWLIST(:,3),'NotFight')),6) = {FRAMEJUMP};
elseif strcmp(DATA,'ViFData')
    FLOWDIR ='Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\SIFTFlows\';
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\SIFTFlows\' );
    FOLD = 5;
    STIPOUT = 'VIFDATA';
    VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\Videos - Copy';
    addpath(genpath(VIDDIR))
    
end

if ~exist(OUTPUT ,'dir')
    mkdir(OUTPUT);
end

F = FLOWLIST; FLOWLIST(:,1) = FLOWLIST(:,5);
VidList = FLOWLIST; % Create a FLowList copy
fs = size(FLOWLIST); vs = size(VidList);
Descriptors = []; DescriptorsTags = []; MBPClasses = [];

disp('Starting MBP');

totalTime = 0;
for i = 1 : vs(1)
    tic;
    % Check if the sampling window offset is non-default
    if fs(2) >5
        FRAMEJUMP = FLOWLIST{i,6};
    end
    % Extract Features from a single video
    vidScene = RD_MBP( strcat(VidList{i,1},'.avi'),IMSIZE,MATRIXSIZE,TIMESTEP,THRESH,FRAMEJUMP,WINDOW,[FLOWDIR,F{i,1}])
    
    % Generate tags for each sampled window retured from a video file
    if length(vidScene) ~= 0 && ~isempty(vidScene);
        %DESC
        Descriptors = [Descriptors;vidScene];
        ds = size(vidScene);
        %CLASSES
        clear Tags
        [Tags{1:ds(1)}] = deal(VidList{i,3});
        DescriptorsTags = [DescriptorsTags;Tags'];
        %VIF DATA
        clear Tags
        [Tags{1:ds(1)}] = deal(VidList{i,4});
        MBPClasses = [MBPClasses;Tags'];
    end
    
    % Some Timey Whimey Stuff
    currentTime = toc; totalTime = totalTime + currentTime;
    disp(strcat(num2str(currentTime),'(',num2str(totalTime),')'));
end

% Remove any empty cells
emptyCells = cellfun(@isempty,Descriptors);
Descriptors(emptyCells) = [];
MBPClasses(emptyCells) = [];
DescriptorsTags(emptyCells) = [];

% Perform Principal Component Anlsysis to reduce Dimensionality
if PCA
    ElementsToKeepMin = 5;  % Minimum number of dimensions
    
    % Create Mat vectors
    yMatVect = zeros(length(Descriptors),1);
    for m = 1:length(Descriptors)
        subSize = size(Descriptors{m});
        yMatVect(m) = subSize(1);
    end
    
    % Exand all data held within cells representing sampled windows an put
    % thema all into one numberic array
    numericFlatData = cell2mat(Descriptors);
    
    %Perform PCA
    [~,PC, e] = princomp(numericFlatData);
    
    % Determine which features hold 90% of all information
    esum = sum(e);
    eperc = esum * 0.90;
    
    ElementsToKeep = 0;
    
    for i = 1: length(e)
        if sum(e(1:i)) >= eperc
            ElementsToKeep = i;
            break;
        end
    end
    
    if ElementsToKeep < ElementsToKeepMin
        ElementsToKeep = ElementsToKeepMin;
    end
    
    % Reconstruct Data from a numeric array back into cells
    numericFlatData = PC(:,1:ElementsToKeep);
    Descriptors = mat2cell(numericFlatData,yMatVect,ElementsToKeep);
    
end

MBPDescriptors = Descriptors;
MBPDescriptorsTags = DescriptorsTags;

subName = [DATA,'MBP'];
save(strcat(OUTPUT,'/',subName,'.mat'),...
    'MBPDescriptors',...
    'MBPDescriptorsTags',...
    'MBPClasses',...
    '-v7.3');

clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STIP HOG HOF
%
% This subsection does not extract STIP feaures, it merely reads them from
% files. See STIP/STIP_EXTRACT.m for feaure extaction
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
OUTPUT = 'ALL DATA\Out';
%DATA = 'Cardiff-Original';
%DATA = 'Cardiff';
DATA = 'ViFData';
%DATA = 'Hockey';
WINDOWSIZE = 5; 
WINDOWSKIP = 40;
PCA = true;

% Set up data

if strcmp(DATA,'Hockey')
    FLOWDIR = 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\SIFTFlows\FLOWS\Cross\';
    
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\SIFTFlows\FLOWS\Cross\' );
    addpath(genpath('Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\Video\'));
    FOLD = 5;
    STIPOUT = 'HOCKEY2';
    VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\Video';
    addpath(genpath(VIDDIR))
elseif strcmp(DATA,'Cardiff-Original')
    FLOWDIR = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four Original\SIFTFlows\';
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four Original\SIFTFlows\' );
    VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\VideoCutsSmall';
    addpath(genpath(VIDDIR))
    FOLD = 4;
    STIPOUT = 'CARDIFF';
    FLOWLIST{1,6} = [];
    FLOWLIST(find(ismember(FLOWLIST(:,3),'Fight')),6) = {1};
    FLOWLIST(find(ismember(FLOWLIST(:,3),'NotFight')),6) = {WINDOWSKIP};
elseif strcmp(DATA,'Cardiff')
    FLOWDIR ='Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\SIFTFlows\';
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\SIFTFlows\' );
    VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\VideoCutsSmall';
    addpath(genpath(VIDDIR))
    FOLD = 4;
    STIPOUT = 'CARDIFF';
    
    FLOWLIST{1,6} = [];
    FLOWLIST(find(ismember(FLOWLIST(:,3),'Fight')),6) = {1};
    FLOWLIST(find(ismember(FLOWLIST(:,3),'NotFight')),6) = {WINDOWSKIP};
elseif strcmp(DATA,'ViFData')
    FLOWDIR ='Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\SIFTFlows\';
    FLOWLIST  = LoadDataSet( 'Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\SIFTFlows\' );
    FOLD = 5;
    STIPOUT = 'VIFDATA';
    VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\Videos - Copy';
    addpath(genpath(VIDDIR))
    
end

% The directory that holds STIP feature files
STIPOUT = ['STIP/',STIPOUT];

fs = size(FLOWLIST); STIPFLOWLIST = []; STIPDescriptors = [];

for i = 1: fs(1)
    % Load Sample File
    [PATHSTR,NAME,EXT] = fileparts(FLOWLIST{i,1});
    [pos,val,dscr]=readstips_text([STIPOUT,'\', NAME ,'-STIP.txt']);
    
    % Obtain video length by looking at the number of optical files, the
    % reason for doing this is to ensure Optical and method and STIP output
    % the same number of video samples.
    dirInfo = dir(strcat(FLOWDIR,FLOWLIST{i,1},'\*.mat'));
    dirSize = size(dirInfo); Frames = dirSize(1);
    
    clear vidObj;
    
    % Check if the window offset has been overridden
    if fs(2) >5
        WINDOWSKIP = FLOWLIST{i,6};
    end
   
    % Create a list of indexex that state the start of each new sampling
    % window
    SaveIndex = [1:WINDOWSKIP:Frames - WINDOWSIZE];
    
    
    if ~isempty(SaveIndex)
        VideoSplit = cell(length(SaveIndex),1);
        for k = 1: length(SaveIndex)
            % Get all features in frames SaveIndex[k]to SaveIndex[k]+WINDOWSIZE;
            Lower = SaveIndex(k);
            Upper = SaveIndex(k) + WINDOWSIZE;
            
            KeepIndexLower = find(pos(:,3) + pos(:,5) >= Lower);
            KeepIndexUpper = find(pos(:,3) + pos(:,5) <= Upper);
            
            LowerUnique = unique(KeepIndexLower);
            FinalIndex = ismember(KeepIndexUpper,LowerUnique);
            FinalIndex = KeepIndexUpper(FinalIndex);
            
            VideoSplit{k} = dscr(FinalIndex,:);
            % VideoSplit{k} = dscr(FinalIndex,1:90); % HOG ONLY
            % VideoSplit{k} = dscr(FinalIndex,91:end); % HOF ONLY
            STIPFLOWLIST = [STIPFLOWLIST;FLOWLIST(i,:)];
            
            STIPDescriptors = [STIPDescriptors; {[]},{[]}, {VideoSplit{k}},{zeros(1,0)}];
        end
        disp(['Loading STIPS ',num2str(i)]);
    else
        disp(['SKIPPED STIPS ',num2str(i)]);
    end
    
    
    
end

PCADESC = [];
Descriptors = STIPDescriptors(:,3);
if PCA
    ElementsToKeepMin = 5;%;
    % Perform PCA on DATA
    pyrDataSize = size(Descriptors);
    %Fill in missing data
    
    %Create Mat vectors
    yMatVect = zeros(length(Descriptors),1);
    for m = 1:length(Descriptors)
        subSize = size(Descriptors{m});
        yMatVect(m) = subSize(1);
    end
    numericFlatData = cell2mat(Descriptors);
    %Perform Reduction
    [~,PC, e] = princomp(numericFlatData);
    
    esum = sum(e);
    eperc = esum * 0.90;
    % Keep 95% of eigen data
    ElementsToKeep = 0;
    for i = 1: length(e)
        if sum(e(1:i)) >= eperc
            ElementsToKeep = i;
            break;
        end
    end
    if ElementsToKeep < ElementsToKeepMin
        ElementsToKeep = ElementsToKeepMin;
    end
    
    %Reconstruct Data
    numericFlatData = PC(:,1:ElementsToKeep);
    Descriptors = mat2cell(numericFlatData,yMatVect,ElementsToKeep);
    
    STIPDescriptors(:,3) = Descriptors;
end


subName = [DATA,'STIP'];
save(strcat(OUTPUT,'/',subName,'.mat'),...
    'STIPDescriptors',...
    'STIPFLOWLIST',...
    '-v7.3');
clear all;
