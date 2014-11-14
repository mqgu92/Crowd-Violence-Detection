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
PCA = true;
%OUTPUT = 'ALL DATA\CARDIFFSMALL'; % Set Output Folder

DATA = 'ViFData';   % {Cardiff-Original | ViFData | Hockey}
OUTPUT = ['ALLDATA\',DATA];
PYR = [1 1];        % How to split the frame into [X,Y] cells
TEXTURE = [4];      % GLCM NEighbourhood radius
WINDOWSKIP = 39;    % Window between sample extraction
WINDOW = 39;        % Length of temporal window for descriptor extraction

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

% Create the Output Folder
if ~exist(OUTPUT ,'dir')
    mkdir(OUTPUT);
end

% Some Variable Declaration
F = FLOWLIST;
FLOWLIST(:,1) = FLOWLIST(:,5);
totalTime = 0;
VidList = FLOWLIST; fs = size(FLOWLIST); vs = size(VidList);
Descriptors = []; DescriptorsTags = []; DescriptorGroup = [];

for i = 1 : vs(1)
    tic;    
    
    disp(VidList{i,1}); % Output current video being processed
    
    if fs(2) >5 % Does the data use a custom window skip value?
        WINDOWSKIP = FLOWLIST{i,6}; 
    end
    
    % Peform feature extraction
    vidScene = RD_TextureEdgeMeasure( strcat(VidList{i,1},'.avi'),WINDOW,WINDOWSKIP,PYR,TEXTURE,[FLOWDIR,F{i,1}]);
    vidScene = cell2mat(vidScene);
    if length(vidScene) ~= 0 && ~isempty(vidScene);
        % Add features to a global list
        Descriptors = [Descriptors;vidScene];
        ds = size(vidScene);
        % assign class tags to each feature
        clear Tags
        [Tags{1:ds(1)}] = deal(VidList{i,3});
        DescriptorsTags = [DescriptorsTags;Tags'];
        % Assign the feature a group within the K-folds
        clear Tags
        [Tags{1:ds(1)}] = deal(VidList{i,4});
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

%Descriptors = cell2mat(Descriptors);


GLCMDescriptors = Descriptors;
GLCMTags = DescriptorsTags;
GLCMFlowList = FLOWLIST;
GLCMGroup = DescriptorGroup;
subName = [DATA,'GLCM'];
save(strcat(OUTPUT,'/',subName,'.mat'),...
    'GLCMDescriptors',...
    'GLCMTags',...
    'GLCMGroup',...
    'GLCMFlowList',...    
    '-v7.3');


[G GN] = grp2idx(DescriptorsTags);  % Reduce character tags to numeric grouping

for k = 1: FOLD
    disp(['Starting Test ',num2str(k)]);
    % Split data into two groups (Fight.NotFight) based on DescriptorGroup
    % number
    testData = find(str2num([DescriptorGroup{:}]')== k);
    TESTIDX = false(length(DescriptorGroup),1);
    TESTIDX(testData) = true;
    TRAINIDX = ~TESTIDX;
    
    % Save group assignments into a
    DataSplit{k,1} = k;
    DataSplit{k,2} = TRAINIDX;
    DataSplit{k,3} = TESTIDX;
    DataSplit{k,4} = G;
    DataSplit{k,5} = GN;
   
    
    %% TEST USING NON-LINEAR SVM
    FinalDescriptor = cell2mat(Descriptors)
    [CPerf,finalDecision,Answer,accuracy,prob_estimates,trainingModel,subROC ]...
        = ML_TwoClassLibSVM(FinalDescriptor ,TESTIDX,TRAINIDX,G,GN );
    
    LIBFinalDecision{k} = finalDecision;
    LIBAccuracy{k} = accuracy;
    LIBProbability{k} = prob_estimates;
    LIBActualAnswer{k} = Answer;
    LIBTrainingModel{k} = trainingModel;
    LIBClassificationPerf{k} = CPerf;
    LIBROC(k,:) = subROC;
    %% TEST USING LINEAR SVM
    [CPerf,finalDecision,Answer,accuracy,prob_estimates,trainingModel,subROC ]...
        = ML_TwoClassLibLinearSVM(FinalDescriptor ,TESTIDX,TRAINIDX,G,GN );
    
    LINFinalDecision{k} = finalDecision;
    LINAccuracy{k} = accuracy;
    LINProbability{k} = prob_estimates;
    LINActualAnswer{k} = Answer;
    LINTrainingModel{k} = trainingModel;
    LINClassificationPerf{k} = CPerf;
    LINROC(k,:) = subROC;
    
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
save([OUTPUT,'\',TESTTYPE,'.mat'],'TREEFinalDecision',...
    'TREEAccuracy',...
    'TREEProbability',...
    'TREEActualAnswer',...
    'TREETrainingModel',...
    'TREEClassificationPerf',...
    'LINROC',...
    'LINClassificationPerf',...
    'LINTrainingModel',...
    'LINActualAnswer',...
    'LINProbability',...
    'LINAccuracy',...
    'LINFinalDecision',...
    'LIBFinalDecision',...
    'LIBAccuracy',...
    'LIBProbability',...
    'LIBActualAnswer',...
    'LIBTrainingModel',...
    'LIBClassificationPerf',...
    'LIBROC',...
    'VIFDataSplit',...
    'STIPDataSplit',... 
    'TRAJHOFDataSplit',...
    'MBPDataSplit',...
    'METHODS',...
    '-v7.3');
  
    