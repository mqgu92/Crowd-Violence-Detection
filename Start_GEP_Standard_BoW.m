SetupVariables;

DATA_VIDEO_CHOSENSET = DATA_VIDEO_VF;

VideoList = FN_PopulateStandardList(DATA_VIDEO_CHOSENSET.dir,DATA_VIDEO_CHOSENSET.fold);

Param_GLCM = Param_GLCM_Default;

Param_GLCM = struct('baseoffsets', [1 0;-1 0;0 1;0 -1],...
    'graylevel',64,...
    'pyramid',[2 2],...
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
WindowSize = 24;
WindowSkip = 24;
WindowSplit = 4;
ImageResize = 1;

% Extract Descriptors
[unstructured_data]...
    = FN_GEPDescriptorNew(VideoList,...
    DATA_VIDEO_CHOSENSET,...
    Param_GLCM,...
    Param_EdgeCardinality,...
    Param_PixelDifference,...
    WindowSize,...
    WindowSkip,...
    WindowSplit,...
    ImageResize,...
    BACKGROUNDTYPE);

% Structure data for testing

% Perform Classification
[RANDOM_FOREST,LINEAR_SVM] = ...
    FN_CrossValidationTestingBoW( unstructured_data,...
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