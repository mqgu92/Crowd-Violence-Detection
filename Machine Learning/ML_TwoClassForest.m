function [ Confusion,...
    Accuracy,...
    Probablity_estimates,...
    Training_model,...
    Final_decision ,...
    Actual_answer  ]...
    = ML_TwoClassForest(DATA,TESTIDX,TRAINIDX,G,GN,...
    NUMBER_OF_TREES,...
    VERBOSE,...
    DETAILED_MODEL)
%ML_MULTICLASSSVM Summary of this function goes here
%   Detailed explanation goes here
%
%   DATA = vector features
%   TESTIDX = index of testing data
%   TRAINIDX = index of training data
%   GN = Class Tags
%   G = Class Tags Index
%%%
Probablity_estimates = 0;

pairwise = nchoosek(1:length(GN),2);
Training_model = cell(1,1);
predictions = zeros(sum(TESTIDX),numel(Training_model));

tic;
%options = statset('UseParallel', 'Always');
if VERBOSE
    nPrint = 1;
else
    nPrint = 0;
end

if DETAILED_MODEL
    Training_model{1} = TreeBagger(NUMBER_OF_TREES,...
        DATA(TRAINIDX,:),...
        G(TRAINIDX),...
        'Method', 'classification',...
        'OOBVarImp','on',...
        'OOBPred','on',...
        'NPrint',nPrint);
else
    Training_model{1} = TreeBagger(NUMBER_OF_TREES,...
        DATA(TRAINIDX,:),...
        G(TRAINIDX),...
        'Method', 'classification',...
        'NPrint',nPrint);
end

disp(['Built Forest in : ',num2str(toc)]);

[InitialPred,Probablity_estimates] =  Training_model{1}.predict(DATA(TESTIDX,:));

%Probablity_estimates = G(TESTIDX);

pred = zeros(length(InitialPred),1);
for i = 1 : length(pred)
    pred(i) = str2num(InitialPred{i});
end
predictions(:,1) = pred(:);

Final_decision = mode(predictions,2);   %# votipredng: clasify as the class receiving most votes
Actual_answer = G(TESTIDX) ;    %Gotta minus one to fit the confusion range

Confusion = confusionmat(Final_decision, Actual_answer);
[~,~,~,~,Accuracy,~] = ...
    MISC_PlotConfusion(Confusion,[1,2],0);

if VERBOSE
    disp(Confusion);
end
disp(['Accuracy : ',num2str(Accuracy * 100)]);


end




