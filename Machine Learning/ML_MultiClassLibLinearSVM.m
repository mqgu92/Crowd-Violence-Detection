function [ Confusion,...
    Accuracy,...
    Probablity_estimates,...
    Training_model,...
    Final_decision ,...
    Actual_answer  ]...
    = ML_TwoClassLibSVM( DATA,TESTIDX,TRAINIDX,G,GN,VERBOSE )

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
 
Final_decision = mode(predictions,2);   %# votipredng: clasify as the class receiving most votes
Actual_answer = G(TESTIDX);
Confusion = confusionmat(Final_decision, Actual_answer);
%[~,~,~,~,Accuracy,~] = ...
%    MISC_PlotConfusion(Confusion,[1,2],0);

if VERBOSE
    %disp(['AUC : ',num2str(AUC)]);
    disp(Confusion);
end
disp(['Accuracy : ',num2str(Accuracy * 100)]);

end




