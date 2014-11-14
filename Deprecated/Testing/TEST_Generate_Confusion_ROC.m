FOLD = 5; % The number of folds used in crossvalidation testing
FightIndex = 1; % The class IS associated with Fights
   
%% RBF-SVM
%Create ROC Plot
[X,Y,T,AUC] = perfcurve( cell2mat(reshape(LIBActualAnswer,FOLD,1)) ,  cell2mat(reshape(LIBProbability,FOLD,1)) ,FightIndex );
figure,plot(X,Y);
xlabel('False positive rate'); 
ylabel('True positive rate');
title(strcat('AUC: ',num2str(AUC)));

% Create Confusion Matrix
mat = confusionmat( cell2mat(reshape(LIBActualAnswer,FOLD,1)) - 1 ,cell2mat(reshape(LIBFinalDecision,FOLD,1)) - 1) 

[Precision,NegativePredictiveValue,Sensitivty,Specificity] = MISC_PlotConfusion(mat,DataSplit{1,5})

%% Random Forest
%Create ROC Plot
TreeProb = cell2mat(reshape(TREEProbability,FOLD,1));
TreeProb = TreeProb(:,1);
[X,Y,T,AUC] = perfcurve( cell2mat(reshape(TREEActualAnswer,FOLD,1)) , TreeProb,FightIndex );
figure,plot(X,Y);
xlabel('False positive rate'); 
ylabel('True positive rate');
title(strcat('AUC: ',num2str(AUC)));

% Create Confusion Matrix
mat = confusionmat( cell2mat(reshape(TREEActualAnswer,FOLD,1)) - 1 ,cell2mat(reshape(TREEFinalDecision,FOLD,1)) - 1) 

[Precision,NegativePredictiveValue,Sensitivty,Specificity] = MISC_PlotConfusion(mat,DataSplit{1,5})



%% Linear-SVM
%Create ROC Plot   
[X,Y,T,AUC] = perfcurve( cell2mat(reshape(LINActualAnswer,FOLD,1)) ,  cell2mat(reshape(LINProbability,FOLD,1)) ,FightIndex );
figure,plot(X,Y);
xlabel('False positive rate'); 
ylabel('True positive rate');
title(strcat('AUC: ',num2str(AUC)));

% Create Confusion Matrix
mat = confusionmat( cell2mat(reshape(LINActualAnswer,FOLD,1)) - 1 ,cell2mat(reshape(LINFinalDecision,FOLD,1)) - 1) 

[Precision,NegativePredictiveValue,Sensitivty,Specificity] = MISC_PlotConfusion(mat,DataSplit{1,5})

