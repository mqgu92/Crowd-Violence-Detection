function [ CPerf,finalDecision,qq,accuracy,prob_estimates,svmModel ] = ML_TwoClassMatSVM( DATA,TESTIDX,TRAINIDX,G,GN )
%ML_MULTICLASSSVM Summary of this function goes here
%   Detailed explanation goes here
%
%   DATA = vector features
%   TESTIDX = index of testing data
%   TRAINIDX = index of training data
%   GN = Class Tags
%   G = Class Tags Index
%%%
prob_estimates = 0;
accuracy = 0;
    CPerf = classperf(G);    
    %% Input Data into a one on one svm
    pairwise = nchoosek(1:length(GN),2);            %# 1-vs-1 pairwise models
    svmModel = cell(size(pairwise,1),1);            %# store binary-classifers
    predictions = zeros(sum(TESTIDX),numel(svmModel)); %# store binary predictions

    %# classify using one-against-one approach, SVM with 3rd degree poly kernel
    for k=1:numel(svmModel)
        disp(strcat(num2str(k),'-',num2str(numel(svmModel))));
        %# get only training instances belonging to this pair
        idx = TRAINIDX & any( bsxfun(@eq, G, pairwise(k,:)) , 2 );

        %# train
opts = svmsmoset('Display','final','MaxIter',3000000,...
                                       'KernelCacheLimit',1000);
                                   
        %svmModel{k} = train( G(idx), sparse(DATA(idx,:)));
        svmModel{k} = svmtrain(DATA(idx,:), G(idx),'SMO_OPTS',opts);
        %svmModel{k} = svmtrain(Histograms(idx,:), g(idx),'kernel_function','rbf');
        %svmModel{k} = svmtrain(Histograms(idx,:), g(idx),...
        %    'BoxConstraint',2e-1, 'Kernel_Function','polynomial', 'Polyorder',3);
        %# test
        idx = TESTIDX & any( bsxfun(@eq, G, pairwise(k,:)) , 2 );
        qq = G(idx);
       
        predictions(:,k) = svmclassify(svmModel{k}, DATA(TESTIDX,:));
        
       % [predictions(:,k), accuracy, prob_estimates] =  predict(G(idx), sparse(DATA(TESTIDX,:)), svmModel{k});
    end
    finalDecision = mode(predictions,2);   %# votipredng: clasify as the class receiving most votes
    
    CPerf = classperf(CPerf, finalDecision, TESTIDX);
  

end




