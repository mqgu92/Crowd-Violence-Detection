function [ ENERGY, CONTRAST, CORRELATION,HOMOGENEITY ] = GetTextureMeasures( VIDDIR )
 vidObj = VideoReader(VIDDIR);
 numFrames = get(vidObj, 'NumberOfFrames');

 ENERGY = cell(1,4);
 CONTRAST = cell(1,4);
 CORRELATION = cell(1,4);
 HOMOGENEITY = cell(1,4);
 ENERGYseries = zeros(numFrames,2);
 CONTRASTseries = zeros(numFrames,2);
 CORRELATIONseries = zeros(numFrames,2);
 HOMOGENEITYseries = zeros(numFrames,2);
 
 offsets = [1 1; 0 1; 1 0; 1 -1; -1 1;-1 -1; 0 -1; -1 0];
 range = 5;
 offsets = offsets .* range;
 
 for f = 1: numFrames
     I = rgb2gray(read(vidObj,f));

     GLCM2 = graycomatrix(I,'Offset',offsets,'NumLevels',8);
     statss = graycoprops(GLCM2,{'all'});
     ENERGYseries(f,1) = mean(statss.Energy);
     ENERGYseries(f,2) = var(statss.Energy);
     
     CORRELATIONseries(f,1) = mean(statss.Correlation);
     CORRELATIONseries(f,2) = var(statss.Correlation);
     
     HOMOGENEITYseries(f,1) = mean(statss.Homogeneity);
     HOMOGENEITYseries(f,2) = var(statss.Homogeneity);
     
     CONTRASTseries(f,1) = mean(statss.Contrast);
     CONTRASTseries(f,2) = var(statss.Contrast);
     
     disp(f);
 end
 
     ENERGY{1} = ENERGYseries;
     ENERGY{2} = mean(ENERGYseries(:,1));
     ENERGY{3} = var(ENERGYseries(:,1));
     
     CONTRAST{1} = CONTRASTseries;
     CONTRAST{2} = mean(CONTRASTseries(:,1));
     CONTRAST{3} = var(CONTRASTseries(:,1));
     
     CORRELATION{1} = CORRELATIONseries;
     CORRELATION{2} = mean(CORRELATIONseries(:,1));
     CORRELATION{3} = var(CORRELATIONseries(:,1));
     
     HOMOGENEITY{1} = HOMOGENEITYseries;
     HOMOGENEITY{2} = mean(HOMOGENEITYseries(:,1));
     HOMOGENEITY{3} = var(HOMOGENEITYseries(:,1));
      
end

