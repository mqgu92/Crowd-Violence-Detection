function [ Confusion,...
    Accuracy,...
    Probablity_estimates,...
    Training_model,...
    Final_decision ,...
    Actual_answer  ]...
    = ML_TwoClassLibSVM( DATA,TESTIDX,TRAINIDX,G,~,VERBOSE )




Training_model = cell(1,1);
predictions = zeros(sum(TESTIDX),numel(Training_model)); %# store binary predictions


Training_model{1} = train( G(TRAINIDX), sparse(DATA(TRAINIDX,:)),'-q');
[predictions(:,1), accuracy, Probablity_estimates] =  predict(G(TESTIDX), sparse(DATA(TESTIDX,:)), Training_model{1},'-q');
Accuracy = accuracy(1);



%[~,~,~,AUC] = perfcurve(GG(TESTIDX),Probablity_estimates,1);

Final_decision = mode(predictions,2);   %# votipredng: clasify as the class receiving most votes
Actual_answer = G(TESTIDX);
Confusion = confusionmat(Final_decision, Actual_answer);
[~,~,~,~,Accuracy,~] = ...
    MISC_PlotConfusion(Confusion,[1,2],0);

if VERBOSE
    %disp(['AUC : ',num2str(AUC)]);
    disp(Confusion);
end
disp(['Accuracy : ',num2str(Accuracy * 100)]);

end




