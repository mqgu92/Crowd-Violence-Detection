SetupVariables;

DATA_VIDEO_CHOSENSET = DATA_VIDEO_CVDMULTI;

VideoList = FN_PopulateStandardList(DATA_VIDEO_CHOSENSET.dir,DATA_VIDEO_CHOSENSET.fold);

Param_GLCM = Param_GLCM_Default;

Param_GLCM = struct('baseoffsets', [1 0;-1 0;0 1;0 -1],...
    'graylevel',64,...
    'pyramid',[1 1; 2 2],...
    'range',[1 2] );
%    'pyramid',[1 1; 1 2; 2 1; 2 2; 3 3; 1 3; 2 3; 3 1; 3 2; 4 4],...
% Param_GLCM = struct('baseoffsets', [1,1;0,1;1,0;1,-1;-1,1;-1,-1;0,-1;-1,0],...
%     'graylevel',32,...
%     'pyramid',[1 1; 4 4;8 8],...
%     'range',[1 2 4 8]);

Param_EdgeCardinality = Param_EdgeCardinality_Default;

Param_PixelDifference=  Param_PixelDifference_Default;

SUBSET_SIZE = 500000;
WORDS = 4000;
BACKGROUNDTYPE = 1;
WindowSize = 12;
WindowSkip = 18;
WindowSplit = 3;
ImageResize = 1;

% Extract Descriptors
[GEPNonPCADescriptors,~,GEPTags,GEPFlowList,GEPGroup]...
    = FN_GEPDescriptor(VideoList,...
    DATA_VIDEO_CHOSENSET,...
    Param_GLCM,...
    Param_EdgeCardinality,...
    Param_PixelDifference,...
    WindowSize,...
    WindowSkip,...
    WindowSplit,...
    ImageResize,...
    BACKGROUNDTYPE);

% Perform Classification
[RANDOM_FOREST,LINEAR_SVM] = ...
    FN_CrossValidationTestingBoW( GEPNonPCADescriptors,...
    GEPGroup,...
    GEPTags,...
    true,...
    true,...
    Param_GLCM,WORDS,SUBSET_SIZE,WindowSplit);


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
mean(RANDOM_FOREST{2})

[X,Y,T,LINAUC] = perfcurve(Answers ,  cell2mat(LINEAR_SVM{3}) ,'Abnormal' );
    figure, plot(X,Y);
title('ROC before and after feature selection');
legend(['Linear SVM : ',num2str(LINAUC)]);    
mean(LINEAR_SVM{2})
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
