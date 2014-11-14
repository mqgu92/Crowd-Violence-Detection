function [ ACC, CMAT ,PREDICTLIST,AUC,AAUC,X,Y,PROB] = ML_TestClassForest( DATA,RFMODELS,ACTUAL )
%ML_TESTCLASS Summary of this function goes here
%   Detailed explanation goes here

ACC = 0;
AAUC = 0;
%CMAT = zeros(2);
CMAT = cell(1,length(RFMODELS));
ds = size(DATA);
PREDICTLIST = cell(ds(1),length(RFMODELS));
AUC = cell(1,length(RFMODELS));
X = cell(1,length(RFMODELS));
Y = cell(1,length(RFMODELS));
PROB = cell(1,length(RFMODELS));
accuracy = 0;

for i =1 : length(RFMODELS)

    clear prob_estimates InitialPred;
    treeModel = RFMODELS{i};

    [InitialPred, prob_estimates] =  treeModel.predict(DATA);
    PREDICTLIST(:,i) = InitialPred;
    ACC = ACC + accuracy;
    CMAT{i} = confusionmat(ACTUAL,PREDICTLIST(:,i));
    PROB{i} = prob_estimates;

end
%CPerf = classperf(ACTUAL,PREDICTLIST(:,i));
%ACC = CPerf.CorrectRate / length(RFMODELS);
