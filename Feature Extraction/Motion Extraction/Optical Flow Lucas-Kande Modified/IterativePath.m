function [ OUT ] = IterativePath( Pairs, Current )

% Make Sure Current isn't in Pairs
Pairs(ismember(Pairs,Current,'rows'),:) = [];
OUT = Current;
% Add Current to the List
if isempty(Pairs)
    return;
end



PairSize = size(Pairs);


% For Each Pair in pairs
for p = 1: PairSize(1)
    % Forward Checking
    nextVal = Pairs(:,1) == Current(2);
    
    [~,nextInd] = max(nextVal);
    
    if sum(nextVal) >= 1
        out_Pairs = IterativePath(Pairs,Pairs(nextInd,:));
        OUT = [OUT;out_Pairs];
        
        out_PairsSize =  size(out_Pairs);
        
        for o = 1: out_PairsSize(1)
            Pairs(ismember(Pairs,out_Pairs(o,:),'rows'),:) = [];
        end
    end
    
    % Back Checking
    nextVal = Pairs(:,2) == Current(1);
    
        [~,nextInd] = max(nextVal);
    
    if sum(nextVal) >= 1
        out_Pairs = IterativePath(Pairs,Pairs(nextInd,:));
        OUT = [OUT;out_Pairs];
        
        out_PairsSize =  size(out_Pairs);
        
        for o = 1: out_PairsSize(1)
            Pairs(ismember(Pairs,out_Pairs(o,:),'rows'),:) = [];
        end
    end
    
    
end

end

