function [ CPerf,finalDecision,qq,accuracy,prob_estimates,svmModel,ROC ] = ML_TwoClassLibSVM( DATA,TESTIDX,TRAINIDX,G,GN )
%ML_MULTICLASSSVM Summary of this function goes here
%   Detailed explanation goes here
    CPerf = 0;
    %CPerf = classperf(G);    
    %% Input Data into a one on one svm
    pairwise = nchoosek(1:length(GN),2);            %# 1-vs-1 pairwise models
    svmModel = cell(size(pairwise,1),1);     
    ROC = cell(size(pairwise,1),3);   %# store binary-classifers
    predictions = zeros(sum(TESTIDX),numel(svmModel)); %# store binary predictions

    %# classify using one-against-one approach, SVM with 3rd degree poly kernel
    for k=1:numel(svmModel)
        disp(strcat(num2str(k),'-',num2str(numel(svmModel))));
        %# get only training instances belonging to this pair
        idx = TRAINIDX & any( bsxfun(@eq, G, pairwise(k,:)) , 2 );

        %# train
        opts = svmsmoset('Display','final','MaxIter',3000000,...
                                       'KernelCacheLimit',1000);
                                   

        %% Parameter Tweaking
        bestcv = 0;
        for log2c = -3:10
          for log2g = -3:10,
            cmd = ['-v 5 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
            cv = svmtrain( G(idx), sparse(DATA(idx,:)), cmd);
            if (cv >= bestcv),
              bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
            end
            fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
          end
        end

        %% Apply Parameters
        cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg)];
        % Train
        svmModel{k} = svmtrain( G(idx), sparse(DATA(idx,:)), cmd);
        
        idx = TESTIDX & any( bsxfun(@eq, G, pairwise(k,:)) , 2 );
        qq = G(idx);
        
        %Predict
        [predictions(:,k), accuracy, prob_estimates] =  svmpredict(G(idx), sparse(DATA(TESTIDX,:)), svmModel{k});
        
        %Format Output
         GG = G;
         fi = find(ismember(GN, 'Fight'));
         ni = find(ismember(GN, 'NotFight'));
         GG(find(G == ni )) = -1;%Set notFight to negative class 
         GG(find(G == fi )) = 1; % Set fight to positive class
         
         %idx = TRAINIDX & any( bsxfun(@eq, GG, pairwise(k,:)) , 2 );
       %  ROCModel = svmtrain( GG(idx), sparse(DATA(idx,:)), cmd);
         
         
        % idx = TESTIDX & any( bsxfun(@eq, GG, pairwise(k,:)) , 2 );
        % auc = plotroc(GG(idx), sparse(DATA(TESTIDX,:)),ROCModel);
         [X,Y,~,AUC] = perfcurve(GG(idx),prob_estimates,1);
         AUC
         ROC(k,:) = [{X},{Y},AUC];
    end
    finalDecision = mode(predictions,2);   %# votipredng: clasify as the class receiving most votes
       
    C = confusionmat(finalDecision, KK(TESTIDX))
    [Precision,NegativePredictiveValue,Sensitivty,Specificity,Accuracy,PLOT] = ...
        MISC_PlotConfusion(C,[1,2],0);
    accuracy = accuracy + Accuracy;
    %CPerf = classperf(CPerf, finalDecision, TESTIDX);
  

end




