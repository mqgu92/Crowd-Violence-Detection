MeanSet = [GLOBALOUTPUT{:,2}];
LEVELS = [GLOBALOUTPUT{:,8}];
PYRAMID = GLOBALOUTPUT(:,9);
RANGE = GLOBALOUTPUT(:,10);
OFFSET = GLOBALOUTPUT(:,7);



% Reduce Data to easy Values
KnownPyr = {};
PYRAMID2 = [];
for p = 1: length(PYRAMID)
    known = false;
    for k = 1: length(KnownPyr)
        if isequal(PYRAMID{p}, KnownPyr{k})
            known = true;
            PYRAMID2 = [PYRAMID2;k];
        end
    end
    if ~known
        KnownPyr = [KnownPyr; PYRAMID{p}];
        PYRAMID2 = [PYRAMID2;length(KnownPyr)];
    end
end


% Reduce Data to easy Values
KnownPyr = {};
OFFSET2 = [];
for p = 1: length(OFFSET)
    known = false;
    for k = 1: length(KnownPyr)
        if isequal(OFFSET{p}, KnownPyr{k})
            known = true;
            OFFSET2 = [OFFSET2;k];
        end
    end
    if ~known
        KnownPyr = [KnownPyr; OFFSET{p}];
        OFFSET2 = [OFFSET2;length(KnownPyr)];
    end
end

KnownPyr = {};
RANGE2 = [];
for p = 1: length(RANGE)
    known = false;
    for k = 1: length(KnownPyr)
        if isequal(RANGE{p}, KnownPyr{k})
            known = true;
            RANGE2 = [RANGE2;k];
        end
    end
    if ~known
        KnownPyr = [KnownPyr; RANGE{p}];
        RANGE2 = [RANGE2;length(KnownPyr)];
    end
end

LABELS = {'Grey Level','Pyramid Structure','GLCM Offset','GLCM Range'};
p = anovan(MeanSet,{LEVELS,PYRAMID2,OFFSET2,RANGE2},'model','interaction',...
    'varnames',LABELS);