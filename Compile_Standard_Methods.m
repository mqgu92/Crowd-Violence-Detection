vl_setup; %Set up VL_Feat

% Which dataset is being tested
%DATA = 'Cardiff-Original';FOLD = 4;
%DATA = 'Cardiff'; FOLD = 4;
DATA = 'ViFData'; FOLD = 5;
%DATA = 'Hockey'; FOLD = 5;

%Constant Declaration
VIF = 'VIF';    STIP = 'STIP';  TRAJHOF = 'TRAJHOF';  MBP = 'MBP';

%Which method shall be tested, supplying multiple will combine them
METHODS = { STIP,VIF,TRAJHOF,MBP};
%METHODS = { VIF};

%Output Directory
OUTPUT = ['Compiled\',DATA];

if ~exist(OUTPUT ,'dir')
    mkdir(OUTPUT);
end


% Create Output file name
TESTTYPE = '';
for q = 1: length(METHODS)
    Type = METHODS{q};
    TESTTYPE = [TESTTYPE,Type(1)];
end


% Words
VIFWORDS = 3000;
STIPWORDS = 3000;
TRAJHOFWORDS = 1000;
MBPWORDS = 3000;

VIFDataSplit = cell(FOLD,5);
STIPDataSplit = cell(FOLD,5);
TRAJHOFDataSplit = cell(FOLD,5);
MBPDataSplit = cell(FOLD,5);

TrainNum = 200000; % Number of features to use in clustering

VOCABS = cell(length(METHODS),FOLD + 1);
for l = 1 : length(METHODS)
    % Load pre-extracted data
    load(strcat('ALL DATA\',upper(DATA),'\',DATA,METHODS{l}));
    
    % For each method create FOLD number of vocabularies using each sets of
    % training data
    
    if isequal(METHODS{l},VIF)
        [G GN] = grp2idx(VIFDescriptorsTags);
        VOCABS{find(ismember(METHODS,VIF)),6} = VIF;
        for k = 1: FOLD
            disp(['Starting Test ',num2str(k)]);
            TRAINDIX = [];
            TESTIDX = [];
            testData = find(str2num([ViFClasses{:}]')== k);
            TESTIDX = false(length(ViFClasses),1);
            TESTIDX(testData) = true;
            TRAINDIX = ~TESTIDX;
            
            VIFDataSplit{k,1} = k;
            VIFDataSplit{k,2} = TRAINDIX;
            VIFDataSplit{k,3} = TESTIDX;
            VIFDataSplit{k,4} = G;
            VIFDataSplit{k,5} = GN;
            %% --------------------------------------------------------------------
            disp('Formatting Train Data' );
            TRAINDATA = cell2mat(VIFDescriptors(TRAINDIX));
            
            
            %% Limit the Data------------------------------------------------------
            if length(TRAINDATA) > TrainNum
                % rng(1043243); % seed
                randIndex = randperm(length(TRAINDATA));
                TRAINDATA = TRAINDATA(randIndex(1:TrainNum),:);
            end
            
            disp('Creating Vocab' );
            % Create Vocabulary
            VOCABS{find(ismember(METHODS,VIF)),k} = ML_VocabGeneration(TRAINDATA,VIFWORDS);
            
            clear TRAINDATA testData randIndex TESTIDX TRAINIDX testDATA;
            
        end
    end
       
    if isequal(METHODS{l},STIP)

        D = cell(length(STIPFLOWLIST),1);

        for i = 1 : length(STIPFLOWLIST)
            D{i} = [STIPFLOWLIST{i,3}];
        end
        [G GN] = grp2idx(D);
        VOCABS{find(ismember(METHODS,STIP)),6} = STIP;
        for k = 1: FOLD
            disp(['Starting Test ',num2str(k)]);
            testData = find(str2num([STIPFLOWLIST{:,4}]')== k);
            TESTIDX = false(length(STIPFLOWLIST),1);
            TESTIDX(testData) = true;
            TRAINDIX = ~TESTIDX;
            
            STIPDataSplit{k,1} = k;
            STIPDataSplit{k,2} = TRAINDIX;
            STIPDataSplit{k,3} = TESTIDX;
            STIPDataSplit{k,4} = G;
            STIPDataSplit{k,5} = GN;
            %% --------------------------------------------------------------------
            disp('Formatting Train Data' );
             TRAINDATA = cell2mat(STIPDescriptors(TRAINDIX,3));
            
            
            %% Limit the Data------------------------------------------------------
            if length(TRAINDATA) > TrainNum
                % rng(1043243); % seed
                randIndex = randperm(length(TRAINDATA));
                TRAINDATA = TRAINDATA(randIndex(1:TrainNum),:);
            end
            
            disp('Creating Vocab' );
            % Create Vocabulary
            VOCABS{find(ismember(METHODS,STIP)),k} = ML_VocabGeneration(TRAINDATA,STIPWORDS);
            
            clear TRAINDATA testData randIndex TESTIDX TRAINIDX testDATA;
            
        end
    end
   
    if isequal(METHODS{l},TRAJHOF)

        TRAJHOFDataSplit = ML_SplitViFData( FINAL_STRUCTURED_CLASSES );
        
        VOCABS{find(ismember(METHODS,TRAJHOF)),6} = TRAJHOF;
        for k = 1: FOLD
            disp(['Starting Test ',num2str(k)]);
            TestIDX = logical(TRAJHOFDataSplit{k,3});  % Testing IDX
            TrainIDX = logical(TRAJHOFDataSplit{k,2}); % Training IDX
            gn = TRAJHOFDataSplit{k,5};                % Class IDX
            g = TRAJHOFDataSplit{k,4};                 % Class Labels
            
            
            NumberOfFeatures = length(FINAL_ALL_CLASSES) / length(FINAL_STRUCTURED_CLASSES);
            ExpandedIDX = false(NumberOfFeatures,length(TrainIDX));
            
            %% --------------------------------------------------------------------
            for i = 1 : NumberOfFeatures
                ExpandedIDX(i,:) = TrainIDX;
            end
            
            ExpandedIDX = reshape(ExpandedIDX,numel(ExpandedIDX),1);

            TrainData = cell2mat(FINAL_ALL_FEATURES(ExpandedIDX,:));
            
            %% Do we use all the training data or just a subset?
            if (TrainNum <=0) || (TrainNum > length(TrainData))
                 VOCABS{find(ismember(METHODS,TRAJHOF)),k} = ML_VocabGeneration(TrainData,TRAJHOFWORDS);
            else
                %rng(123123);
                trainLimit = randperm(TrainNum);
                VOCABS{find(ismember(METHODS,TRAJHOF)),k} = ML_VocabGeneration(TrainData(trainLimit,:),TRAJHOFWORDS);
            end
            
            clear trainLimit TrainData ExpandedIDX NumberOfFeatures;
            
        end
    end
   
    if isequal(METHODS{l},MBP)
        [G GN] = grp2idx(MBPDescriptorsTags);

        VOCABS{find(ismember(METHODS,MBP)),6} = MBP;
        for k = 1: FOLD
            disp(['Starting Test ',num2str(k)]);
            testData = find(str2num([MBPClasses{:}]')== k);
            TESTIDX = false(length(MBPClasses),1);
            TESTIDX(testData) = true;
            TRAINDIX = ~TESTIDX;
            
            MBPDataSplit{k,1} = k;
            MBPDataSplit{k,2} = TRAINDIX;
            MBPDataSplit{k,3} = TESTIDX;
            MBPDataSplit{k,4} = G;
            MBPDataSplit{k,5} = GN;
            %% --------------------------------------------------------------------
            disp('Formatting Train Data' );
            TRAINDATA = cell2mat(MBPDescriptors(TRAINDIX));
            
            
            %% Limit the Data------------------------------------------------------
            if length(TRAINDATA) > TrainNum
                % rng(1043243); % seed
                randIndex = randperm(length(TRAINDATA));
                TRAINDATA = TRAINDATA(randIndex(1:TrainNum),:);
            end
            
            %% Generate Vocab------------------------------------------------------
            disp('Creating Vocab' );
            % Create Vocabulary
            %[Vocab,labels,mimdist]=kmeans(TRAINDATA,WORDS);
            VOCABS{find(ismember(METHODS,MBP)),k} = ML_VocabGeneration(TRAINDATA,MBPWORDS);
            
            clear TRAINDATA testData randIndex TESTIDX TRAINIDX testDATA;
            
        end
    end
   
    
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




%% Perform Cross Validation Testing
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
    
    

    % Merge all selected method types together.
    ALLDATA = [TRAJHOFDATA,VIFDATA,STIPDATA,MBPDATA];
    

    %Obtain Training and Testing ID from any of the datasplits
    % They should all be the same as the data is split the same way
    if sum(cellfun(@isempty,MBPDataSplit)) == 0
           TRAINIDX = MBPDataSplit{k,2};
           TESTIDX = MBPDataSplit{k,3};
           G = MBPDataSplit{k,4};
           GN = MBPDataSplit{k,5};
    elseif sum(cellfun(@isempty,VIFDataSplit)) == 0
           TRAINIDX = VIFDataSplit{k,2};
           TESTIDX = VIFDataSplit{k,3};
           G = VIFDataSplit{k,4};
           GN = VIFDataSplit{k,5};
    elseif sum(cellfun(@isempty,TRAJHOFDataSplit)) == 0
           TRAINIDX = TRAJHOFDataSplit{k,2};
           TESTIDX = TRAJHOFDataSplit{k,3};
           G = TRAJHOFDataSplit{k,4};
           GN = TRAJHOFDataSplit{k,5};
    else
           TRAINIDX = STIPDataSplit{k,2};
           TESTIDX = STIPDataSplit{k,3};
           G = STIPDataSplit{k,4};
           GN = STIPDataSplit{k,5};
    end

    
    

     
    %% TEST USING LIB SVM
%      [CPerf,finalDecision,Answer,accuracy,prob_estimates,trainingModel,subROC ]...
%         = ML_TwoClassLibSVM(ALLDATA ,TESTIDX',TRAINIDX',G,GN );
%     
%     LIBFinalDecision{k} = finalDecision;
%     LIBAccuracy{k} = accuracy;
%     LIBProbability{k} = prob_estimates;
%     LIBActualAnswer{k} = Answer;
%     LIBTrainingModel{k} = trainingModel;
%     LIBClassificationPerf{k} = CPerf;
%     LIBROC(k,:) = subROC;
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

% Save the output
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

if ~exist([OUTPUT,'\VOCABS\'] ,'dir')
    mkdir([OUTPUT,'\VOCABS\']);
end
% Save the Vocabularies for later use
save([OUTPUT,'\VOCABS\',TESTTYPE,'.mat'],'VOCABS',...
    'VIFDataSplit',...
    'STIPDataSplit',... 
    'TRAJHOFDataSplit',...
    'MBPDataSplit',...
    '-v7.3');
