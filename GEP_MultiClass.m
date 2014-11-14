%%
%
%   BASIC TEXTURE DESCRIPTOR START
%   
%   Loads and partitions data into K folds of test/train data and applies
%   a basic global descriptor. This method does not use a Bag of Words
%   model.
%
%   Descriptor:
%       GCLM Energy + Variance
%       GLCM Contrast + Variance
%       Pixel Difference + Variance
%       Edge Count + Variance
%
%% 
SetupVariables;

%% CHOOSE DATASET
DATA_VIDEO_CHOSENSET = DATA_VIDEO_KTH;

PCA = true;
DATA = DATA_VIDEO_CHOSENSET.name;   % {Cardiff-Original | ViFData | Hockey}


 BASEOFFSET = [1 1; 0 1; 1 0; 1 -1; -1 1;-1 -1; 0 -1; -1 0]; % 8 Directions
%BASEOFFSET = [0 1; 1 0; 0 -1; -1 0]; % 4 Directions

SYMMETRY = false;
LEVELS = 16;
IMRESIZE = 1;
PYRAMID = [ 1 1];
PYRSIZE = size(PYRAMID);
RANGE = [1 2 3 ];

WINDOWSKIP = 1;    % Window between sample extraction
WINDOWSIZE = 50;        % Length of temporal window for descriptor extraction
FRAMERESIZE = IMRESIZE;
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
    'F',num2str(FOLD),...
    FolderExtension]);

OUTPUT = FolderLocation;

% Create the Output Folder
if ~exist(OUTPUT ,'dir')
    mkdir(OUTPUT);
end

%Determine the number of FOLDS as dictated by the video list


% Variable Declaration
VideoListExtended = {}; totalTime = 0;
SourceVideoCount = size(VideoList);
Descriptors = []; DescriptorsTags = []; DescriptorGroup = [];

for i = 1 : SourceVideoCount(1)
    tic;    
    % Select the current Item Being Tested 
    VideoListItem = VideoList(i,:);
    
    if SourceVideoCount(2) >5 % Does the data use a custom window skip value?
        if ~isempty(VideoList{i,6})
        WINDOWSKIP = VideoList{i,6}; 
        end
    end
    
    % Peform feature extraction
    ExtractedVideoFeatures = RD_TextureEdgeMeasure( VideoListItem,WINDOWSIZE,...
    WINDOWSKIP,PYRAMID,RANGE, FRAMERESIZE,DATA_VIDEO_CHOSENSET,...
    SYMMETRY,LEVELS,BASEOFFSET);
    % Formate the entire Scene, Each Row is a different Window/Scene
    ExtractedVideoFeatures = cell2mat(ExtractedVideoFeatures);
    
    ExtractedSceneCount = size(ExtractedVideoFeatures); 
    ExtractedSceneCount = ExtractedSceneCount(1); % Scene count is vertical
    
    % Append Number of Samples Taken from the sample
    VideoListExtended = [VideoListExtended;VideoList(1,:),ExtractedSceneCount];
    
    if ExtractedSceneCount ~= 0 && ~isempty(ExtractedVideoFeatures);
        % Add features to a global list
        Descriptors = [Descriptors;ExtractedVideoFeatures];
        % assign class tags to each feature
        clear Tags
        [Tags{1:ExtractedSceneCount}] = deal(VideoList{i,1});
        DescriptorsTags = [DescriptorsTags;Tags'];
        % Assign the feature a group within the K-folds
        clear Tags
        [Tags{1:ExtractedSceneCount}] = deal(VideoList{i,5});
        DescriptorGroup = [DescriptorGroup;Tags'];
        
    end
    % Output Process Time
    currentTime = toc; totalTime = totalTime + currentTime;
    disp(strcat(num2str(currentTime),'(',num2str(totalTime),')'));
end


%% LIBSVM DATA
LIBClassificationPerf = cell(1,FOLD);
LIBFinalDecision = cell(1,FOLD);
LIBAccuracy = cell(1,FOLD);
LIBProbability = cell(1,FOLD);
LIBActualAnswer = cell(1,FOLD);
LIBVocab = cell(1,FOLD);
LIBTrainingModel = cell(1,FOLD);
LIBROC = cell(FOLD,3);
%% LINEAR SVM DATA
LINClassificationPerf = cell(1,FOLD);
LINFinalDecision = cell(1,FOLD);
LINAccuracy = cell(1,FOLD);
LINProbability = cell(1,FOLD);
LINActualAnswer = cell(1,FOLD);
LINVocab = cell(1,FOLD);
LINTrainingModel = cell(1,FOLD);
LINROC = cell(FOLD,3);
%% TREE DATA
TREEClassificationPerf = cell(1,FOLD);
TREEFinalDecision = cell(1,FOLD);
TREEAccuracy = cell(1,FOLD);
TREEProbability = cell(1,FOLD);
TREEActualAnswer = cell(1,FOLD);
TREEVocab = cell(1,FOLD);
TREETrainingModel = cell(1,FOLD);
TREEROC = cell(FOLD,3);

DescriptorsCopy = Descriptors;

% Perform Dimension Reduction
Descriptors = mat2cell(Descriptors);
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

GLCMNonPCADescriptors = DescriptorsCopy;
GLCMDescriptors = Descriptors;
GLCMTags = DescriptorsTags;
GLCMFlowList = VideoList;
GLCMGroup = DescriptorGroup;
subName = [DATA,'GLCM'];
save(strcat(OUTPUT,'/TestOutput','.mat'),...
    'GLCMDescriptors',...
    'GLCMTags',...
    'GLCMGroup',...
    'GLCMFlowList',...   
    'GLCMNonPCADescriptors',...
    '-v7.3');


[G GN] = grp2idx(GLCMTags);  % Reduce character tags to numeric grouping
  FinalDescriptor = cell2mat(GLCMDescriptors);
for k = 1: max(cell2mat(GLCMGroup)) %Number of Folds
    %disp(['Starting Test ',num2str(k)]);
    % Split data into two groups (Fight.NotFight) based on DescriptorGroup
    % number
   % testData = find(str2num([DescriptorGroup{:}]')== k);
    testData = find([GLCMGroup{:}]'== k);
    TESTIDX = false(length(GLCMGroup),1);
    TESTIDX(testData) = true;
    TRAINIDX = ~TESTIDX;
    
    % Save group assignments into a
    DataSplit{k,1} = k;
    DataSplit{k,2} = TRAINIDX;
    DataSplit{k,3} = TESTIDX;
    DataSplit{k,4} = G;
    DataSplit{k,5} = GN;
   
    
    %% TEST USING NON-LINEAR SVM
  
    %FinalDescriptor = GLCMNonPCADescriptors;
    
    %% TEST RANDOM FOREST
    [ r,finalDecision,Answer,accuracy,prob_estimates,svmMo ]...
        = ML_TwoClassForest(FinalDescriptor ,TESTIDX,TRAINIDX,G,GN );
    
    TREEFinalDecision{k} = finalDecision;
    TREEAccuracy{k} = accuracy;
    TREEProbability{k} = prob_estimates;
    TREEActualAnswer{k} = Answer;
    TREETrainingModel{k} = svmMo{:};
    TREEClassificationPerf{k} = r;
    
end

FightIndex = 1;
TreeProb = cell2mat(reshape(TREEProbability,FOLD,1));
TreeProb = TreeProb(:,1);
[X,Y,T,AUC] = perfcurve( cell2mat(reshape(TREEActualAnswer,FOLD,1)) , TreeProb,FightIndex );
figure,plot(X,Y);
xlabel('False positive rate'); 
ylabel('True positive rate');
title(strcat('AUC: ',num2str(AUC)));
