function [ FINAL_ALL_FEATURES, FINAL_STRUCTURED_FEATURES, FINAL_ALL_CLASSES,FINAL_STRUCTURED_CLASSES,...
     PCA_FINAL_ALL_FEATURES, PCA_FINAL_STRUCTURED_FEATURES...
     ] =TEST_TRAJHOF_PROCESS( ALL_FEATURES, STRUCTURED_FEATURES , PERFORMPCA,PCAEOVERRIDE )
%%
%   Arrange Data into a different form
%   Perform PCA analysis plot
%   Perform PCA
%
%%



%% Step 2: Process Flows
%   Merge Data into single descriptor
    FinalSceneClasses =[];          % Class Information
    FINAL_ALL_FEATURES = [];     % Features without pyramid information
    FINAL_STRUCTURED_FEATURES = [];              % Features with Pyramid Information
    FINAL_ALL_CLASSES = [];
    FINAL_STRUCTURED_CLASSES = [];
    
    
    ds = size(ALL_FEATURES);
%   Expand all scenes so that we get a column of features
    for i = 1 :ds(1)  
        scene = ALL_FEATURES{i,2};
        for k = 1 : length(scene)
            SceneDescriptor = scene{k};
            FINAL_ALL_FEATURES = [ FINAL_ALL_FEATURES;{SceneDescriptor}]; 
            FINAL_ALL_CLASSES = [ FINAL_ALL_CLASSES;ALL_FEATURES{i,1}];
        end
        disp(strcat('FINAL_ALL_FEATURES Video:', num2str(i)));
    end
    
    
    ds = size(STRUCTURED_FEATURES);
    for i = 1 :ds(1)
               
        pyrScene = STRUCTURED_FEATURES{i,2}; % Features from a SCENE
        
        levelData = [];
        for j = 1: length(pyrScene)
            subLevel = pyrScene{j};
            levelData = [levelData,subLevel];
            disp(strcat('FINAL_STRUCTURED_FEATURES Structing Pyramid:', num2str(j)));
        end
        FINAL_STRUCTURED_FEATURES = [FINAL_STRUCTURED_FEATURES;levelData];
        
        % Create tags that describe the now expanded descriptor set
        ls = size(levelData);
        for q = 1 : ls(1)
            FINAL_STRUCTURED_CLASSES =[FINAL_STRUCTURED_CLASSES;STRUCTURED_FEATURES{i,1}];
            disp(strcat('FINAL_STRUCTURED_FEATURES Perparing Classes:', num2str(q)));
        end

       disp(strcat('FINAL_STRUCTURED_FEATURES Video:', num2str(i)));
    end
    
    
    if PERFORMPCA
    
        

    
        
        ElementsToKeepMin = 3;
        
        if PCAEOVERRIDE > 0
            ElementsToKeepMin = PCAEOVERRIDE;
        end
        %% Perform PCA on DATA
        pyrDataSize = size(FINAL_STRUCTURED_FEATURES);
        flatData = reshape(FINAL_STRUCTURED_FEATURES,numel(FINAL_STRUCTURED_FEATURES),1);
        %Fill in missing data
        %emptyCells = cellfun(@isempty,flatData);
        %flatData(emptyCells) = ];
        %Create Mat vectors
        yMatVect = zeros(length(flatData),1);
        for m = 1:length(flatData)
            subSize = size(flatData{m});
            yMatVect(m) = subSize(1);
        end
        numericFlatData = cell2mat(flatData);
        %Perform Reduction
        [~,PC, e] = princomp(numericFlatData);
        
         esum = sum(e);
        eperc = esum * 0.90;
        % Keep 95% of eigen data
        ElementsToKeep = 0;
        for i = 1: length(e)
            if sum(e(1:i)) >= eperc
                ElementsToKeep = i;
                break;
            end
        end
        if ElementsToKeep < ElementsToKeepMin
            ElementsToKeep = ElementsToKeepMin;
        end
        
        % Reconstruct Data
        numericFlatData = PC(:,1:ElementsToKeep);
        flatData = mat2cell(numericFlatData,yMatVect,ElementsToKeep);
        %flatData(emptyCells) = cell(1,1);
        PCA_FINAL_STRUCTURED_FEATURES = reshape(flatData,pyrDataSize);
        
        %% Perform PCA on the non-Pyramid Data
        numericData = cell2mat(FINAL_ALL_FEATURES);
        [~,PC, e] = princomp(numericData);
        numericData = PC(:,1:ElementsToKeep);
        PCA_FINAL_ALL_FEATURES = mat2cell(numericData,ones(length(numericData),1),ElementsToKeep);
    end
        
  



end

