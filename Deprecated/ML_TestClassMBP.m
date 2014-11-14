function [ ACC, CMAT ,PREDICTLIST,AUC,AAUC,X,Y,PROB] = ML_TestClassMBP( DATA,SVMMODELS,ACTUAL )
%ML_TESTCLASS Summary of this function goes here
%   Detailed explanation goes here

ACC = 0;
AAUC = 0;
%CMAT = zeros(2);
CMAT = cell(1,length(SVMMODELS));
dataSize = size(DATA);
PREDICTLIST = zeros(dataSize(1),length(SVMMODELS));
AUC = cell(1,length(SVMMODELS));
X = cell(1,length(SVMMODELS));
Y = cell(1,length(SVMMODELS));
PROB = cell(1,length(SVMMODELS));

for i =1 : length(SVMMODELS)

    sModel = SVMMODELS{i};
    [PREDICTLIST(:,i), accuracy, prob_estimates] =  predict(ACTUAL', sparse(DATA), sModel{1});
    ACC = ACC + accuracy(1);
    CMAT{i} = confusionmat(ACTUAL,PREDICTLIST(:,i));
    PROB{i} = prob_estimates;
    %CMAT = CMAT + confusionmat(ACTUAL,PREDICTLIST(:,i));
   %[X(i),Y(u),~,AUC(i)] = perfcurve(ACTUAL,PREDICTLIST(:,i),1)
   %AAUC = AAUC + AUC(i);
end

%AAUC = AAUC /length(VOCABS); 
ACC = ACC / length(SVMMODELS);
