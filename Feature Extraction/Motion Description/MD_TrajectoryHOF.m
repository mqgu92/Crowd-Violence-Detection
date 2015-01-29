function [ Descriptor ] = MD_TrajectoryHOF( inputX, inputY, vList, uList  )
%% TrajectoryHOFDescriptorBin
%
%   Calculates the Histograms of Flows for an area surrounding
%   point (inputY,inputX) without using bin maps
%   Direction Bins are calculated within this function
%
bins = 8;
HOFThresh = 0.1;
 N = 32;
 Nq = 2;
 Nt = 3;

SeqLength = length(inputX);

flowAreas2D = zeros(Nq .* Nq, bins + 1 , SeqLength );

for i = 1 : SeqLength
    
    %v = vList(:,:,i); u = uList(:,:,i);
    v = vList{i}; u = uList{i};
    x = inputX(i); y = inputY(i);
    %Get Flows Around point X,Y,Z
    l = N / 2;
    
    XRange = x - l : x + l;
    YRange = y - l : y + l;
    
    areaV = v(YRange , XRange);
    areaU = u(YRange , XRange);
    
    %Calculate Histogram of Flows for each area
    
    sA = N / Nq;
    for sy = 1: Nq 
        for sx = 1: Nq

            cv = areaV((sy - 1) * sA + 1  : (sy - 1) * sA + sA + 1,...
                (sx - 1) * sA + 1 : (sx - 1) * sA + sA + 1 );
            cu = areaU((sy - 1) * sA + 1 : (sy - 1) * sA + sA + 1,...
                (sx - 1) * sA  + 1 : (sx - 1) * sA + sA + 1);
            
            [ ~ , HOF] = MD_UV2HOF(cv,cu,HOFThresh,bins );
            
            flowAreas2D(sub2ind([Nq , Nq] ,sy,sx),:,i) = HOF;
            
        end
    end

    %% Calculate Histograms through the temporal space

end


    % Split Sequence into x segments
    group = round(SeqLength / Nt);
    Descriptor = cell(1 , Nt);
    for p = 1 : Nt %Nt temporal segments
        data = [];
        ZRange = ((p - 1) * group + 1 :(p - 1) * group + group) ;
        for n = 1 : Nq * Nq %Nq by Nq spatial segments
           d = sum(flowAreas2D(n,:,ZRange),3);
           data = [data,d];
        end
        Descriptor{1,p} = data;
    end
    
    Descriptor = cell2mat(Descriptor);
end

