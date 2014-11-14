function [ Descriptors,e ] = PerformPCA( Descriptors )
    % Perform Dimension Reduction
    Descriptors = mat2cell(Descriptors);
        ElementsToKeepMin = 2;%;
        %% Perform PCA on DATA
        pyrDataSize = size(Descriptors);
        %Fill in missing data
        
        %Create Mat vectors
        yMatVect = zeros(length(Descriptors),1);
        for m = 1:length(Descriptors)
            subSize = size(Descriptors{m});
            yMatVect(m) = subSize(1);
        end
        numericFlatData = cell2mat(Descriptors);
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
        Descriptors = mat2cell(numericFlatData,yMatVect,ElementsToKeep);
        
end

