function [OUTPUT] = RD_MBP( VIDEODIR,IMSIZE,MATRIXSIZE,TIMESTEP,THRESH,FRAMEJUMP,WINDOW,FLOWDIR )
%RD_MBP 
%
% STEP 1: Create Binary Maps between frames where 1 = p(f - 1) > p(f) else 0
% STEP 2: Split into 3x3 or 5x5 or 7x7 frames
% STEP 3: For each frame compute XOR of b(j) and b(k), where k = j + [1,2,3,4]
% STEP 4: If the sum of the resultant split is greather than thresh then 1
% else 0


% STEP pre-req: Load Videos data

    SPLIT = 10; %% Split data into IMSIZE/10 blocks as words
    OUTPUT =[];
    
    if iscell(VIDEODIR)
        VIDEODIR = VIDEODIR{:};
    end

    vidObj = VideoReader(VIDEODIR);
    %numFrames = get(vidObj, 'NumberOfFrames');

    dirInfo = dir(strcat(FLOWDIR,'\*.mat'));
    dirSize = size(dirInfo);
    numFrames = dirSize(1);
    
    getIndex = 1:FRAMEJUMP:(numFrames - WINDOW ) ;
    saveNumber = length(getIndex);
    
    FinalOut = cell(length(getIndex),length(TIMESTEP));
    
    for q = 1: length(TIMESTEP)
    
        % Full Frame Binary Maps
        FFBMaps = false(IMSIZE(2),IMSIZE(1),numFrames - 1);
        XORMaps = false(IMSIZE(2),IMSIZE(1),numFrames - 1);
        % STEP 1: Create Binary Maps
        for i = 1 : numFrames - (TIMESTEP(q))
            f1 = rgb2gray(read(vidObj,i));
            f1 = imresize(f1, IMSIZE);
            
            f2 = rgb2gray(read(vidObj,i+TIMESTEP(q)));
            %Resize video into factor of matrix size
            f2 = imresize(f2, IMSIZE);
            
            FFBMaps(:,:,i) = f1 > f2;
            
            %f1 = f2;
        end
        
        FFBSize = size(FFBMaps);
        
        
       
        for i = 1 : saveNumber;
            j = getIndex(i);
            SUBHISTOGRAM = [];
            for s = j : j + WINDOW - (TIMESTEP(q)) - 1
                
                ind = s;
                XORMaps(:,:,ind) = xor(FFBMaps(:,:,ind),FFBMaps(:,:,ind + TIMESTEP(q)));
                
                XORMaps(:,:,ind) = uint8(XORMaps(:,:,ind));
                
                SplitXORMap = cell(IMSIZE);
                Range = (MATRIXSIZE-1)/2;
                for x = 1 + Range : IMSIZE(1) - Range;
                    for y = 1 + Range : IMSIZE(2) - Range;
                        SplitXORMap{y,x} = XORMaps(x - Range :x + Range ,y -Range:y+Range,ind);
                    end
                end
                
                SplitXORMap = cellfun(@sum,cellfun(@sum,SplitXORMap,'UniformOutput',false));
                
                HISTNUM = SplitXORMap > THRESH;

                if isempty(SUBHISTOGRAM)
                    SUBHISTOGRAM =HISTNUM;
                else
                    SUBHISTOGRAM = SUBHISTOGRAM + HISTNUM;
                end
                
               
            end
            FinalOut{i,q} = SUBHISTOGRAM;
            
        end
        %OUTPUT = [OUTPUT,SUB];
     
    end
    
    BEFORESPLIT =  cell(length(getIndex),1);
    
    for qq = 1: saveNumber
        BEFORESPLIT{qq} = zeros(size(FinalOut{1,1}));
        for qqq = 1: length(TIMESTEP)
        BEFORESPLIT{qq} = BEFORESPLIT{qq}  +(FinalOut{qq,qqq});
        end
    end
    
    %% Split Each SEgment Descriptor into parts
    
    FINALDESC = cell(length(getIndex),1);

    for qq = 1: saveNumber
        SPLIT = MISC_splitMat(BEFORESPLIT{qq},4,4);
        
        for k = 1: numel(SPLIT)
            SPLIT{k} = reshape(SPLIT{k},1,numel(SPLIT{k}));
        end
        FINALDESC{qq} = cell2mat(reshape(SPLIT,numel(SPLIT),1));
    end
    
    OUTPUT = FINALDESC;
end

