% This document assumes that the all vcabualries are pre-calculated and 
% loaded, see Compile_Standard_Methods.m for vocabulary compilation.

DATA = 'Cardiff'; FOLD = 4;
%DATA = 'ViFData'; FOLD = 5;
%DATA = 'Hockey'; FOLD = 5;


VIF = 'VIF';
STIP = 'STIP';
TRAJHOF = 'TRAJHOF';
MBP = 'MBP';
GLCM = 'GLCM';


% A list of different testing combinations to be executed
ALLMETHODS = {
    
   % { STIP,VIF,TRAJHOF,MBP,GLCM}
         

    %{ GLCM};
    %{ STIP};
    %{ MBP };
    %{ VIF };
    %{ TRAJHOF};

    
    %{ STIP,VIF,TRAJHOF,MBP}
    %{ STIP,VIF,TRAJHOF,GLCM}
    %{ STIP,VIF,GLCM,MBP}
    %{ STIP,GLCM,TRAJHOF,MBP}
    %{ GLCM,VIF,TRAJHOF,MBP}
     
    %{ STIP,VIF,TRAJHOF}   
    %%{ STIP,VIF,MBP};
    %{ STIP,TRAJHOF,MBP};
    %{ VIF,TRAJHOF,MBP};
    %{ STIP,VIF,GLCM}  
    %{ STIP,GLCM,TRAJHOF}   
    %{ GLCM,VIF,TRAJHOF}   
    %{ STIP,GLCM,MBP};
    %{ GLCM,VIF,MBP};
    %{ TRAJHOF,GLCM,MBP};
  
    %{ STIP,VIF};
    %{ STIP,TRAJHOF};
    %{ STIP,MBP};
    %{ VIF,TRAJHOF};
    %{ VIF,MBP};
    { TRAJHOF,MBP};
    %{ TRAJHOF,GLCM};
    %{ VIF,GLCM};
    %{ STIP,GLCM};
    %{ MBP,GLCM};
    

    };
% Final results array
ALLOUT = cell(length(ALLMETHODS),10);

for ATT = 1: length(ALLMETHODS)
METHODS = ALLMETHODS{ATT};

for l = 1 : length(METHODS)
    load(strcat('ALL DATA\',upper(DATA),'\',DATA,METHODS{l}));
end

DataSplit = [];

TESTTYPE = '';

for q = 1: length(METHODS)
    Type = METHODS{q};
    TESTTYPE = [TESTTYPE,Type(1)];
end

disp(TESTTYPE);

OUTPUT = ['ALLCompiled\',DATA];

if ~exist(OUTPUT ,'dir')
    mkdir(OUTPUT);
end

%% LIBSVM DATA
LIBClassificationPerf = cell(1,FOLD);
LIBFinalDecision = cell(1,FOLD);
LIBAccuracy = cell(1,FOLD);
LIBProbability = cell(1,FOLD);
LIBActualAnswer = cell(1,FOLD);
LIBVocab = cell(1,FOLD);
LIBTrainingModel = cell(1,FOLD);
LIBROC = cell(FOLD,3);
%% LINEAR SVM DATA
LINClassificationPerf = cell(1,FOLD);
LINFinalDecision = cell(1,FOLD);
LINAccuracy = cell(1,FOLD);
LINProbability = cell(1,FOLD);
LINActualAnswer = cell(1,FOLD);
LINVocab = cell(1,FOLD);
LINTrainingModel = cell(1,FOLD);
LINROC = cell(FOLD,3);
%% TREE DATA
TREEClassificationPerf = cell(1,FOLD);
TREEFinalDecision = cell(1,FOLD);
TREEAccuracy = cell(1,FOLD);
TREEProbability = cell(1,FOLD);
TREEActualAnswer = cell(1,FOLD);
TREEVocab = cell(1,FOLD);
TREETrainingModel = cell(1,FOLD);
TREEROC = cell(FOLD,3);




%% Perform Cross Validation
for k = 1: FOLD
    VIFDATA = [];
    if sum(ismember(METHODS,VIF)) > 0% Change features to words

        disp('Obtaining VIF Words ');
        for i = 1: length(ViFClasses)
            %disp(['Nearest Words ',num2str(i)]);
            n = ML_NearestWord(  {VIFDescriptors{i}},  VOCABS{find(ismember(VOCABS(:,6),VIF)),k}, VIFWORDS );
            VIFDATA = [VIFDATA;n];
        end
    
    end
    
    STIPDATA = [];
    if sum(ismember(METHODS,STIP)) > 0
         disp('Obtaining STIP Words ');
        for i = 1: length(STIPFLOWLIST)
            %disp(['Nearest Words ',num2str(i)]);
            s = ML_NearestWord(  {STIPDescriptors{i,3}},VOCABS{ find(ismember(VOCABS(:,6),STIP)),k},STIPWORDS );
            STIPDATA = [STIPDATA;s];
        end
    end
   
    TRAJHOFDATA = [];
    if  sum(ismember(METHODS,TRAJHOF)) > 0
         disp('Obtaining TRAJHOF Words ');
        FPs = size(FINAL_STRUCTURED_FEATURES); %Size of structured features
        for i = 1 :FPs(1)
            D = FINAL_STRUCTURED_FEATURES(i,:); %All Cells per row
            PYRDATA = [];
            for m = 1: length(D)    %For each pyramid section
                if ~isempty(D{m})
                    subData = ML_NearestWord(D(m),VOCABS{find(ismember(VOCABS(:,6),TRAJHOF)),k},TRAJHOFWORDS);
                    PYRDATA = [PYRDATA,subData];
                else
                    PYRDATA = [PYRDATA,zeros(1,TRAJHOFWORDS)]; %No data, pad with zeros
                end
            end
            TRAJHOFDATA = [TRAJHOFDATA;PYRDATA];
        end
    end
   
    MBPDATA = [];
    if sum(ismember(METHODS,MBP)) > 0
        disp('Obtaining MBP Words ');
        for i = 1: length(MBPClasses)
            %disp(['Nearest Words ',num2str(i)]);
            n = ML_NearestWord(  {MBPDescriptors{i}}, VOCABS{find(ismember(VOCABS(:,6),MBP)),k},MBPWORDS );
            MBPDATA = [MBPDATA;n];
        end
    end
    
    GLCMDATA= [];
    if sum(ismember(METHODS,GLCM)) > 0
        disp('Obtaining GLCM DATA ');
        GLCMDATA = cell2mat(GLCMDescriptors);
    end


    
    
    ALLDATA = [TRAJHOFDATA,VIFDATA,STIPDATA,MBPDATA,GLCMDATA];
    
    
    %Obtain Training and Testing ID from any of the datasplits
    % They should all be the same as the data is split the same way
    if sum(cellfun(@isempty,MBPDataSplit)) == 0
           TRAINIDX = MBPDataSplit{k,2};
           TESTIDX = MBPDataSplit{k,3};
           G = MBPDataSplit{k,4};
           GN = MBPDataSplit{k,5};
           DataSplit = MBPDataSplit;
    elseif sum(cellfun(@isempty,VIFDataSplit)) == 0
           TRAINIDX = VIFDataSplit{k,2};
           TESTIDX = VIFDataSplit{k,3};
           G = VIFDataSplit{k,4};
           GN = VIFDataSplit{k,5};
           DataSplit = VIFDataSplit;
    elseif sum(cellfun(@isempty,TRAJHOFDataSplit)) == 0
           TRAINIDX = TRAJHOFDataSplit{k,2};
           TESTIDX = TRAJHOFDataSplit{k,3};
           G = TRAJHOFDataSplit{k,4};
           GN = TRAJHOFDataSplit{k,5};
           DataSplit = TRAJHOFDataSplit;
    else
           TRAINIDX = STIPDataSplit{k,2};
           TESTIDX = STIPDataSplit{k,3};
           G = STIPDataSplit{k,4};
           GN = STIPDataSplit{k,5};
           DataSplit = STIPDataSplit;
    end


    %% TEST USING LINEAR SVM
    [CPerf,finalDecision,Answer,accuracy,prob_estimates,trainingModel,subROC ]...
        = ML_TwoClassLibLinearSVM(ALLDATA ,TESTIDX,TRAINIDX,G,GN );
    
    LINFinalDecision{k} = finalDecision;
    LINAccuracy{k} = accuracy;
    LINProbability{k} = prob_estimates;
    LINActualAnswer{k} = Answer;
    LINTrainingModel{k} = trainingModel;
    LINClassificationPerf{k} = CPerf;
    LINROC(k,:) = subROC;
        %% TEST USING LIB SVM
%      [CPerf,finalDecision,Answer,accuracy,prob_estimates,trainingModel,subROC ]...
%         = ML_TwoClassLibSVM(ALLDATA ,TESTIDX,TRAINIDX,G,GN );
%     
    LIBFinalDecision{k} = finalDecision;
    LIBAccuracy{k} = accuracy;
    LIBProbability{k} = prob_estimates;
    LIBActualAnswer{k} = Answer;
    LIBTrainingModel{k} = trainingModel;
    LIBClassificationPerf{k} = CPerf;
    LIBROC(k,:) = subROC;
%     %% TEST USING TREE
     [ r,finalDecision,Answer,accuracy,prob_estimates,svmMo ] = ML_TwoClassForest(ALLDATA ,TESTIDX,TRAINIDX,G,GN );
     disp('Built Forest');
     TREEFinalDecision{k} = finalDecision;
     TREEAccuracy{k} = accuracy;
     TREEProbability{k} = prob_estimates;
     TREEActualAnswer{k} = Answer;
     TREETrainingModel{k} = svmMo{:};
     TREEClassificationPerf{k} = r;
    
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Geneatere Performance measures for each classifier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ALLOUT{ATT,1} = TESTTYPE;

FightIndex = 1
mat = confusionmat( cell2mat(reshape(TREEActualAnswer,FOLD,1)) - 1 ,cell2mat(reshape(TREEFinalDecision,FOLD,1)) - 1) 
[Precision,NegativePredictiveValue,Sensitivty,Specificity] = MISC_PlotConfusion(mat,DataSplit{1,5});

TreeProb = cell2mat(reshape(TREEProbability,FOLD,1)); TreeProb = TreeProb(:,1);
[X,Y,T,AUC] = perfcurve( cell2mat(reshape(TREEActualAnswer,FOLD,1)) , TreeProb,FightIndex );

ALLOUT{ATT,2} = Precision;
ALLOUT{ATT,3} = NegativePredictiveValue;
ALLOUT{ATT,4} = AUC;



mat = confusionmat( cell2mat(reshape(LIBActualAnswer,FOLD,1)) - 1 ,cell2mat(reshape(LIBFinalDecision,FOLD,1)) - 1) 
[Precision,NegativePredictiveValue,Sensitivty,Specificity] = MISC_PlotConfusion(mat,DataSplit{1,5});
[X,Y,T,AUC] = perfcurve( cell2mat(reshape(LIBActualAnswer,FOLD,1)) ,  cell2mat(reshape(LIBProbability,FOLD,1)) ,FightIndex );

ALLOUT{ATT,5} = Precision;
ALLOUT{ATT,6} = NegativePredictiveValue;
ALLOUT{ATT,7} = AUC;


mat = confusionmat( cell2mat(reshape(LINActualAnswer,FOLD,1)) - 1 ,cell2mat(reshape(LINFinalDecision,FOLD,1)) - 1) 
[Precision,NegativePredictiveValue,Sensitivty,Specificity] = MISC_PlotConfusion(mat,DataSplit{1,5});
[X,Y,T,AUC] = perfcurve( cell2mat(reshape(LINActualAnswer,FOLD,1)) ,  cell2mat(reshape(LINProbability,FOLD,1)) ,FightIndex );

ALLOUT{ATT,8} = Precision;
ALLOUT{ATT,9} = NegativePredictiveValue;
ALLOUT{ATT,10} = AUC;

% Save Test Results
save([OUTPUT,'\',TESTTYPE,'.mat'],'TREEFinalDecision',...
    'TREEAccuracy',...
    'TREEProbability',...
    'TREEActualAnswer',...
    'TREETrainingModel',...
    'TREEClassificationPerf',...
    'LINROC',...
    'LINClassificationPerf',...
    'LINTrainingModel',...
    'LINActualAnswer',...
    'LINProbability',...
    'LINAccuracy',...
    'LINFinalDecision',...
    'LIBFinalDecision',...
    'LIBAccuracy',...
    'LIBProbability',...
    'LIBActualAnswer',...
    'LIBTrainingModel',...
    'LIBClassificationPerf',...
    'LIBROC',...
    'VIFDataSplit',...
    'STIPDataSplit',... 
    'TRAJHOFDataSplit',...
    'MBPDataSplit',...
    'METHODS',...
    '-v7.3');

end