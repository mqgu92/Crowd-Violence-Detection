function [ MIN, MAX, AVG, VAR,SERIES ] = GetDifferenceDensities( VIDDIR, NORM )
 vidObj = VideoReader(VIDDIR);
 numFrames = get(vidObj, 'NumberOfFrames');
 
 SERIES = zeros(1,numFrames);
 
 Area = vidObj.Height * vidObj.Width;
 MaximumDifference = Area * 255; % All pixels change state fully
 
 f1 = rgb2gray(read(vidObj,1));
 for f = 2: numFrames
     
     f2 = rgb2gray(read(vidObj,f)); % Read the Frame
  
     SERIES(f) = sum(sum(f1-f2)); % Sum of the intensity change
     
     if NORM
        SERIES(f) =  SERIES(f) / MaximumDifference;
     end
     
     f1 = f2;
 end
 
 SERIES = SERIES(2:end);    %The first value is always zero
 MIN = min(SERIES);
 MAX = max(SERIES);
 AVG = mean(SERIES);
 VAR = var(SERIES);
end

