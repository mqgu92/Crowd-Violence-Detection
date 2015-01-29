function [OUTPUT] =  GLCME_DesiredBaseMaps( PYRAMID ,MAXVALUE )
% Using a spatial pyramid stucture determine the factors for each number
% and location any common factors amoungst them

Values = unique(reshape(PYRAMID,1,numel(PYRAMID)));

Factors = cell(MAXVALUE,1);
% Find a number that has all the values in value as a factor

% Step 1, is it possible, find all factors within a range and then check
% they exist in Values

for f = 1: MAXVALUE
    Factors{f} = [1,factor(f),f];
    
    if sum(ismember(Values, Factors{f})) == length( Values)
        disp('A simple solutione exists');
         OUTPUT = zeros(1,2);
            OUTPUT(1,1) = f;
            OUTPUT(1,2) = f;
       
        return;
    end
end

% okay, No one solution exists, check is solution exists across multiple
% numbers
AllFactors = [Factors{:}];

if sum(ismember(Values, AllFactors)) == length( Values)
    disp('A solution exists, it may take a while to find the best representation');
else
    disp('A Solution does not exist within the search window');
end

% Iteratively Remove The Grid that removes most numbers from the factor
% list
list = [];

while true
    GreatestSum = 0;
    GreatestIndex = 0;
    for f = 1 : MAXVALUE
        CurrentSum = sum(ismember(Values, unique(Factors{f})));
        if CurrentSum > GreatestSum
            GreatestSum = CurrentSum;
            GreatestIndex = f;
        end
    end
    
    list = [list,GreatestIndex];
    Values(ismember(Values, Factors{GreatestIndex})) = [];
    if length(Values) <= 0
        OUTPUT = zeros(length(list),2);
        for  i = 1: length(list)
            OUTPUT(i,1) = list(i);
            OUTPUT(i,2) = list(i);
        end
        return;
    end
end

end

