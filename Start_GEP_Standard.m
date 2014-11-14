SetupVariables;

DATA_VIDEO_CHOSENSET = DATA_VIDEO_VF;

VideoList = FN_PopulateStandardList(DATA_VIDEO_CHOSENSET.dir,DATA_VIDEO_CHOSENSET.fold);

Param_GLCM = Param_GLCM_Default;

Param_GLCM = struct('baseoffsets',[1 0; -1 0; 0 1;0 -1],...
    'graylevel',64,...
    'pyramid',[1 1 ],...
    'range',[1 2]);

% Param_GLCM = struct('baseoffsets', [1,1;0,1;1,0;1,-1;-1,1;-1,-1;0,-1;-1,0],...
%     'graylevel',54,...
%     'pyramid',[1 1],...
%     'range',[1 2 4 8]);

Param_EdgeCardinality = Param_EdgeCardinality_Default;

Param_PixelDifference=  Param_PixelDifference_Default;

WindowSize = 48;
WindowSkip = 1;
ImageResize = 0.5;

% Extract Descriptors
[GEPNonPCADescriptors,GEPDescriptors,GEPTags,GEPFlowList,GEPGroup]...
    = FN_GEPDescriptor(VideoList,...
    DATA_VIDEO_CHOSENSET,...
    Param_GLCM,...
    Param_EdgeCardinality,...
    Param_PixelDifference,...
    WindowSize,...
    WindowSkip,...
    ImageResize);

% Perform Classification
[RAND_FOREST,LINEAR_SVM] = ...
    FN_CrossValidationTesting( GEPDescriptors,GEPGroup,GEPTags,true,true );


AnswersNumeric = cell2mat(RAND_FOREST{6});
Classes =  RAND_FOREST{7};
Answers = cell(length(AnswersNumeric),1);
Answers(AnswersNumeric == 1) = Classes(1); 
Answers(AnswersNumeric == 2) = Classes(2); 

TreeProb = cell2mat(RAND_FOREST{3}); TreeProb = TreeProb(:,1);
[RF_X,RF_Y,~,RF_AUC] = perfcurve( Answers , TreeProb ,'Abnormal');

figure, plot(RF_X,RF_Y);
title('ROC before and after feature selection');
legend(['Random Forest : ',num2str(RF_AUC)]);

[X,Y,T,LINAUC] = perfcurve(Answers ,  cell2mat(LINEAR_SVM{3}) ,'Abnormal' );
    figure, plot(X,Y);
title('ROC before and after feature selection');
legend(['Linear SVM : ',num2str(LINAUC)]);    