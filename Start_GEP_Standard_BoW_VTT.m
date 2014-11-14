SetupVariables;

DATA_VIDEO_CHOSENSET = DATA_VIDEO_KTHVTT;

VideoList = FN_PopulateVTTList(DATA_VIDEO_CHOSENSET.dir);

Param_GLCM = Param_GLCM_Default;

Param_GLCM = struct('baseoffsets',[1 0; -1 0; 0 1;0 -1],...
    'graylevel',32,...
    'pyramid',[1,1;],...
    'range',[1:10]);

% Param_GLCM = struct('baseoffsets', [1,1;0,1;1,0;1,-1;-1,1;-1,-1;0,-1;-1,0],...
%     'graylevel',32,...
%     'pyramid',[1 1; 4 4;8 8],...
%     'range',[1 2 4 8]);

Param_EdgeCardinality = Param_EdgeCardinality_Default;

Param_PixelDifference=  Param_PixelDifference_Default;

SUBSET_SIZE = 500000;
WORDS = 2000;

WindowSize = 100;
WindowSkip = 1;
ImageResize = 0.5;

% Extract Descriptors
[GEPNonPCADescriptors,~,GEPTags,GEPFlowList,GEPGroup]...
    = FN_GEPDescriptor(VideoList,...
    DATA_VIDEO_CHOSENSET,...
    Param_GLCM,...
    Param_EdgeCardinality,...
    Param_PixelDifference,...
    WindowSize,...
    WindowSkip,...
    ImageResize);

%NewGroup =FN_GEPGroup2VTT(VideoList,GEPFlowList,GEPGroup);

% Perform Classification
[RANDOM_FOREST,LINEAR_SVM] = ...
    FN_VTTBoW( GEPNonPCADescriptors,...
    GEPGroup,...
    GEPTags,...
    true,...
    true,...
    Param_GLCM,2000,SUBSET_SIZE);


% Get ROC Curve
AnswersNumeric = cell2mat(RANDOM_FOREST{6});
Classes =  RANDOM_FOREST{7};
Answers = cell(length(AnswersNumeric),1);
Answers(AnswersNumeric == 1) = Classes(1); 
Answers(AnswersNumeric == 2) = Classes(2); 

TreeProb = cell2mat(RANDOM_FOREST{3}); TreeProb = TreeProb(:,1);
[RF_X,RF_Y,~,RF_AUC] = perfcurve( Answers , TreeProb ,'Abnormal');

figure, plot(RF_X,RF_Y);
title('ROC before and after feature selection');
legend(['Random Forest : ',num2str(RF_AUC)]);


% 
% GEPNonPCADescriptors = FN_ReformalizeDescriptorFromStructure( GEPNonPCADescriptors, Param_GLCM.pyramid,8 );
% 
% % Pick a subset
% SubsetInd = randperm(length(GEPNonPCADescriptors));
% SubsetInd = SubsetInd(1:Subset);
% 
% VOCAB = ML_VocabGeneration( GEPNonPCADescriptors(SubsetInd,:), WORDS );
% 
% WordRepresentation = ML_NearestWord( GEPNonPCADescriptors, VOCAB,WORDS );
% 
% % Reformalulate back into a Structure
% GEPNonPCADescriptors = FN_ReformalizeDescriptorToStructure( WordRepresentation, Param_GLCM.pyramid,WORDS );
% 
