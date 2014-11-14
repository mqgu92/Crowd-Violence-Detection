
List = [09 11;
    10 14;
    14 06;
    14 07;
    14 11;
    06 12;
    08 07;
    11 14]
Groups = {};

for i = 1: length(List)
    if isempty(List)
        return;
    end
    Current = List(1,:);
    
    [ OUT ] = IterativePath( List, Current )
    
    Groups = [Groups;OUT];
    %Remove Values that are now grouped
    out_PairsSize = size(OUT);
    
    for o = 1: out_PairsSize(1)
        List(ismember(List,OUT(o,:),'rows'),:) = [];
    end
end