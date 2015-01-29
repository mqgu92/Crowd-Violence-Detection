function outputImage = imresizeNN(inputImage, newSize)
%%%%%%% imresizeNN(inputImage, newSize) is identical to built in 
%%%%%%% imresize(inputImage, newSize, 'nearest'), but is much faster
oldSize = size(inputImage);  
scale = newSize./oldSize;    

% Compute a resampled set of indices:
rowIndex = min(round(((1:newSize(1))-0.5)./scale(1)+0.5),oldSize(1));
colIndex = min(round(((1:newSize(2))-0.5)./scale(2)+0.5),oldSize(2));

outputImage = inputImage(rowIndex,colIndex);
