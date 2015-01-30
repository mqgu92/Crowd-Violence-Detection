function [unstructured_data_all]...
    = FN_GEPDescriptorNew(VideoList,DATA_VIDEO_CHOSENSET,Param_GLCM,Param_Edge,Param_PixelDifference,WINDOWSIZE,WINDOWSKIP,WINDOWSPLIT,IMRESIZE,SUBTRACT)
% GEP Descriptor is comprised of GLCM Co-Occurannce features/ Edge
% Cardinality and Inter-frame pixel difference between adjacent frames

%
EDGEDETECTOR = Param_Edge.type;

PDJUMP = Param_PixelDifference.framejump;

BASEOFFSET = Param_GLCM.baseoffsets;
LEVELS = Param_GLCM.graylevel;
PYRAMID = Param_GLCM.pyramid;
RANGE = Param_GLCM.range;
SYMMETRY = false;   %ALWAYS FALSE

FRAMERESIZE = IMRESIZE;
%Determine the number of FOLDS as dictated by the video list
FOLD = max([VideoList{:,5}]);
% Determine Output Folder Name
FolderExtension = ['o',sprintf('%d',reshape(BASEOFFSET,1,numel(BASEOFFSET))),...
    'l',sprintf('%d',LEVELS),...
    'i',num2str(IMRESIZE),...
    'p',num2str(reshape(PYRAMID,1,numel(PYRAMID))),...
    'r',num2str(RANGE),...
    's',sprintf('%d',SYMMETRY)];
FolderExtension(FolderExtension == ' ') = '';
FolderExtension(FolderExtension == '.') = '_';


FolderLocation = fullfile('ALLDATAMEX',DATA_VIDEO_CHOSENSET.name,...
    ['WS',num2str(WINDOWSKIP),...
    'W',num2str(WINDOWSIZE),...
    'WSL', num2str(WINDOWSPLIT),...
    'F',num2str(FOLD),...
    'B',num2str(SUBTRACT),...
    FolderExtension]);

OUTPUT = FolderLocation;

% Create the Output Folder
if ~exist(OUTPUT ,'dir')
    mkdir(OUTPUT);
else
    % Check if the files exist
    if exist(strcat(OUTPUT,'/TestOutput','.mat'),'file')
        load(strcat(OUTPUT,'/TestOutput','.mat'));
        return;
    end
end

% Variable Declaration
totalTime = 0;
SourceVideoCount = size(VideoList);

unstructured_data_all = cell(SourceVideoCount(1),1);

for i = 1 : SourceVideoCount(1)
    tic;
    % Select the current Item Being Tested
    VideoListItem = VideoList(i,:);
    
    if SourceVideoCount(2) > 5 % Does the data use a custom window skip value?
        if ~isempty(VideoListItem{6})
            WS = VideoList{i,6};
        else
            WS =  WINDOWSKIP;
        end
    else
        WS =  WINDOWSKIP;
    end
    
    py = PYRAMID;
    
    % Load Video
    EntireVideo = RD_LoadVideo(VideoListItem,FRAMERESIZE);
    [M,N,T] = size(EntireVideo);
    % Compute Interest Points
    points = EXP_generate_global_points( N,M,T - WINDOWSIZE,WINDOWSIZE,[py(1), py(2) ,(T - WINDOWSIZE)/WS] );
    sub_volume_indices = EXP_determine_sub_volumes(N,M,T, points);
    % GLCM Experiments
    OFFSETS = GLCM_CalculateNeighbourhood(BASEOFFSET,RANGE);
    scaled_volume = GLCM_Scale_Intenities( EntireVideo,LEVELS);
    
    [V,~] = size(sub_volume_indices); % Number of Extracted Interest Points
    
    %GLCM Feature Set
    glcm_feature_set = cell(V,1);
    for v = 1: V
        p = sub_volume_indices{v};
        sub_volume = scaled_volume(p(2):p(5),p(1):p(4),p(3):p(6));
        glcm  = RD_ComputeGLCMSetPoint( sub_volume, OFFSETS,LEVELS );
        % Compute Statistics
        [ ~, glcm_feature_set{v} ] = RD_ComputeGLCMFeatures( glcm, WINDOWSPLIT );
    end
    
    unstructured_data = cell(V,5);
    unstructured_data(:,1) = glcm_feature_set;
    unstructured_data(:,2) = num2cell(points,2);
    unstructured_data(:,3) = {deal(VideoList{i,1})};% Which Class?
    unstructured_data(:,4) = {deal(VideoList{i,3})};% Which sample?
    unstructured_data(:,5) = {deal(VideoList{i,5})};% Which Fold? This needs to change to a dynamic fold assignment

    unstructured_data_all{i} = unstructured_data;
    currentTime = toc; totalTime = totalTime + currentTime;
    %disp(strcat(num2str(currentTime),'(',num2str(totalTime),')',...
    %    num2str(currentTime/ExtractedSceneCount)));
end

unstructured_data_all = unstructured_data_all(~cellfun('isempty',unstructured_data_all)); % Remove Empty  
unstructured_data_all = cat(1,unstructured_data_all{:}); % Expand all descriptors into a single format

save(strcat(OUTPUT,'/TestOutput','.mat'),...
    'unstructured_data_all',...
    '-v7.3');

save(strcat(OUTPUT,'/Settings','.mat'),...
    'Param_Edge',...
    'Param_GLCM',...
    'Param_PixelDifference',...
    'WINDOWSIZE',...
    'WINDOWSKIP',...
    'IMRESIZE',...
    '-v7.3');
end
    
    % Order all features into temporal groups
%     t_list = points(:,3);
%     samples = unique(t_list);
%     ExtractedVideoFeatures = [];
%     for v = 1:length(samples)
%         t = samples(v);
%         index = find(t_list == t);
%        ExtractedVideoFeatures = [ExtractedVideoFeatures;cell2mat(glcm_feature_set(index)')];
%         
%     end
%     
