
BASEOFFSETS = {[1 1; 0 1; 1 0; 1 -1; -1 1;-1 -1; 0 -1; -1 0],...
    [0 1; 1 0; 0 -1; -1 0]};

SYMMETRYS = {false,true};
LEVELS = {16,8};
IMRESIZE = 0.5;
PYRAMID = [1 1; 2 2;3 3;4 4;5 5;6 6];
RANGES = {1,1:2,1:3,1:4,1:5,1:2:4,1:2:6,1:2:8,1:2:10};


for r = 1: length(RANGES)
    RANGE = RANGES{r};
    for b = 1: length(BASEOFFSETS)
        BASEOFFSET = BASEOFFSETS{b};
        for s = 1: length(SYMMETRYS)
            SYMMETRY = SYMMETRYS{s};
            for l = 1: length(LEVELS)
                LEVEL = LEVELS{l};
                GLCM_GenerateMatricesToFile( BASEOFFSET,SYMMETRY,LEVEL,IMRESIZE,PYRAMID,RANGE );
            end
        end
    end
end



