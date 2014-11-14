function [ EDGES, ORIENT] = GetEdgeDensities( VIDDIR , NORM, BINS )
 vidObj = VideoReader(VIDDIR);
 numFrames = get(vidObj, 'NumberOfFrames');

 EDGES = cell(1,4);
 ORIENT = cell(1,4);
 
 EDGESseries = zeros(numFrames,2);
 ORIENTSeries = zeros(numFrames,BINS);
 MaximumDifference = vidObj.Height * vidObj.Width; 
 for f = 1: numFrames
     I = rgb2gray(read(vidObj,f));

     
     [BW] = edge(I,'canny');
    % EDGESseries(f,1) = sum(sum(BW)); 
    
    [GradientX,GradientY] = gradient(double(I));

    A = ((atan2(GradientY,GradientX)+pi)*180)/pi; A = round(A);
    A = mod(round((A .* BINS) ./360),BINS);
    B = zeros(size(A)); B(BW==1) = A(BW ==1);
    OritentationHist = hist(B(BW~=0),BINS)  ; 
   
     if NORM
        EDGESseries(f,1) = sum(sum(BW)) / MaximumDifference;
        ORIENTSeries(f,1:8) = OritentationHist ./ numel(A);
     else
        EDGESseries(f,1) = sum(sum(BW));
        ORIENTSeries(f,1:8) = OritentationHist;
     end
     
     
 end
 
     EDGES{1} = EDGESseries;
     EDGES{2} = mean(EDGESseries(:,1));
     EDGES{3} = var(EDGESseries(:,1));
    
     ORIENT{1} = ORIENTSeries;
     ORIENT{2} = mean(ORIENTSeries);
     ORIENT{3} = var(ORIENTSeries);
end

