switch method
    case 'edge'
    %setup graphics based on edgeIm
      if ~checkEdgeOutput(edgeIm); %sanity check of DoEdgeStrength function
        break;end
      figH = figure('NumberTitle','off'); set(figH, 'Name',method);
      subplot(1,2,1); hImObjEdge = imagesc(edgeIm);
      axis off;axis image;colormap gray(256); title(gca,'Edge Image');
      
      subplot(1,2,2); hImObj = imagesc( curIm,[0,250]); 
      axis off;axis image;colormap gray(256);title(gca,'original sequence');
    case 'flow1full'
          figH = figure; set(figH, 'Name',method);
          hImObj = image(zeros([size(curIm), 3]));
          axis off;axis image; title(gca,'flow1, dedicated function, full resolution Image');
    case 'gradient'
   % setup graphics based on dx, dy and dt
      figH = figure('NumberTitle','off'); set(figH,'Name','3D gradient');
      plotRange = max(max(sqrt(dx.^2+dy.^2)))+0.001;
    
      subplot(2,2,1); hImObjDx = imagesc(dx,[-plotRange,plotRange]); 
      axis off;axis image;colormap gray(256);title(gca,'dx');

      subplot(2,2,2); hImObjDy = imagesc(dy,[-plotRange,plotRange]); 
      axis off;axis image;colormap gray(256);title(gca,'dy');

      subplot(2,2,3); hImObjDt = imagesc(dt,[-plotRange,plotRange]); 
      axis off;axis image;colormap gray(256);title(gca,'dt');

	  subplot(2,2,4); hImObj = imagesc( curIm,[0,255]); 
      axis off;axis image;colormap gray(256);title(gca,'original sequence'); 
    otherwise %setup based on flow field U1, V1
       if ~checkFlowOutput(U1, V1)%sanity check of DoFlow function
        break;end        
      flowRes = max(size(U1));
      [hImObj,hQvObjLines] =  myGraphicsSetup(vid,kindOfMovie,flowRes);
      title(gca,['current image. Flow vectors are scaled by ' num2str(sc) ':1' ]);
      figH = gcf; set(figH, 'Name',method);
end
g.figH = figH;
%if synthetic video, also setup keyboard callback
if strcmpi(kindOfMovie, 'synthetic')
    set(figH, 'Name',[get(figH, 'Name') ' -- use keys (q,a,w,s,e,d) for lag time and pattern speed --' ],...
              'WindowKeyPressFcn',@myKeypress,'WindowKeyReleaseFcn',@myKeyrelease);
end
 