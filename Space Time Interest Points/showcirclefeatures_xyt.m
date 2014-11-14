function showcirclefeatures_xyt(f0,features,labels,stepflag,i1,i2,linewidth,outputpath)

%
% M=showcirclefeatures_xyt(f0,features,fcol,stepflag,i1,i2)
%
%   displays image sequence f0 with spatio-temporal
%   features=[x,y,t,sx,st] drawn by circles with colours
%   fcol=[r,g,b];
%

if nargin<3 labels=ones(1,size(features,1)); end
  
ccol=hsv(length(unique(labels)));
fcol=ccol(labels(:),:);
  
if (ndims(f0)>2)

  if nargin<4 stepflag=0; end
  if nargin<6 i1=1; i2=size(f0,3); end
  if i1<0 | i2<0 i1=1; i2=size(f0,3); end
  if nargin<7; linewidth=3; end

  
  
  mingray=min(f0(:));
  maxgray=max(f0(:));
  for i=i1:i2 %[i1*ones(1,20) i1:i2]
    %i
    clf
    showgrey(f0(:,:,i),256,mingray,maxgray);
    hold on
    showcirclefeaturesframe_xyt(i,features,fcol,linewidth)
    title(sprintf('frame %d of %d',i,size(f0,3)))
    pause(0.01)
    if stepflag
      pause;
    end
  
    if nargin>7 % save sigle frames to 'outputpath'
      fh=figure(gcf);
      printed_size = 100; % centimeters
      %set(fh,'PaperPosition', [0 0 6 6], ...
%	     'PaperPositionMode', 'manual', ...
%	     'PaperSize', [printed_size printed_size], ...
%	     'PaperUnits', 'centimeters');
%      set(fh,'PaperPosition', [0 0 6 6], ...
%	     'PaperPositionMode', 'manual', ...
%	     'PaperSize', [printed_size printed_size], ...
%	     'PaperUnits', 'centimeters');
      set(gca,'Position',[0 0 1 1])
      set(gcf,'PaperSize',[4 4]);
      title('')
      imgfname=sprintf('%s/frame_%03d.bmp',outputpath,i);
      fprintf('%s\n',imgfname);
      print('-dbmp',imgfname)
      eval(['!convert -crop 0x0 ' imgfname ' ' imgfname]);
    end
  end
end
