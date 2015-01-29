function [ Confusion,Accuracy,Probablity_estimates,Training_model,Final_decision ,Actual_answer  ]...
    = ML_MultiClassLibLinearSVM( DATA,TESTIDX,TRAINIDX,G,GN,VERBOSE )
%% ML_MultiClassLibLinearSVM
% Performs linear binary classification between each combination of pairwise
% classes. Final results are determined by apply the MODE function to the
% classification output from each and every generated model.

% Output:
%   Confusion   : Confusion Matrix
%   Accuracy    : Overall Classification Accuracy
%   Probablity_estimates    : Strength of Classification
%   Traning Model   : Collection of each trained model
%   Final_Decision  : Output Classification
%   Actual_answer   : True Class 

% How many pairwise combinations between classes exist?
 pairwise = nchoosek(1:length(GN),2);           
 Training_model = cell(size(pairwise,1),1);  
 Probablity_estimates = zeros(sum(TESTIDX),numel(Training_model));   
 predictions = zeros(sum(TESTIDX),numel(Training_model)); %# store binary predictions

for k=1:numel(Training_model)
    idx = TRAINIDX & any( bsxfun(@eq, G, pairwise(k,:)) , 2 );
    Training_model{k} = train( G(idx), sparse(DATA(idx,:)),'-q');
    [predictions(:,k), accuracy, Probablity_estimates(:,k)] =  predict(G(TESTIDX), sparse(DATA(TESTIDX,:)), Training_model{k},'-q');
    Accuracy = accuracy(1);
    %[~,~,~,AUC] = perfcurve(GG(TESTIDX),Probablity_estimates,1);
end
 
Final_decision = mode(predictions,2);   

Actual_answer = G(TESTIDX);

if VERBOSE
    %disp(['AUC : ',num2str(AUC)]);
    Confusion = confusionmat(Final_decision, Actual_answer);
    disp(Confusion);
end
disp(['Accuracy : ',num2str(Accuracy * 100)]);

end




