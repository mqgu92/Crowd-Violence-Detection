function [ Descriptor ] = MD_TrajectoryHOFwBinMap(  inputX, inputY, bMapList, mMapList  )
%% TrajectoryHOFDescriptorBin
%
%   Calculates the Histograms of Flows for an area surrounding
%   point (inputY,inputX) using Bin Maps
%
%   When performing HOF generation around a point many calculations are
%   done, due to windows nature many calculations are repeated and so a
%   seperate function that pre-calculates the HOF is executed. This allows
%   for simple addressing of these HOF, this is a bin map
%
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
    bMap = bMapList{i}; mMap = mMapList{i};
    x = inputX(i); y = inputY(i);
    %Get Flows Around point X,Y,Z
    l = N / 2;
    
    XRange = x - l : x + l;
    YRange = y - l : y + l;
    
    areaB = bMap(YRange , XRange);
    areaM = mMap(YRange , XRange);
    


    areaB = MISC_splitMat(areaB,Nq,Nq);
    areaM = MISC_splitMat(areaM,Nq,Nq);
    %% Split Data into Nq by Nq data
    %Calculate Histogram of Flows for each area
    
 
    for sy = 1: 4 
            
            %[ ~ , HOF] = UV2HOF(cv,cu,HOFThresh,bins );
            cb = areaB{sy};
            cm = areaM{sy};
            HOF = MD_MagBin2Hist(cb,cm,1,bins,0.1);
            flowAreas2D(sy,:,i) = HOF;
    end
    %% Calculate Histograms through the temporal space

end


    % Split Sequence into x areas
    group = round(SeqLength / Nt);
    Descriptor = cell(1 , Nt);
    ranges = [1,cumsum(diff(round(linspace(0,SeqLength,Nt+1))))];
    for p = 1 : Nt
        data = [];
        %ZRange = ((p - 1) * group + 1 :(p - 1) * group + group) ;
        ZRange = ranges(p) : ranges(p+1);
        for n = 1 : Nq * Nq
            d = sum(flowAreas2D(n,:,ZRange),3);
           data = [data,d];
        end
        Descriptor{1,p} = data;
    end
    
    Descriptor = cell2mat(Descriptor);
end



