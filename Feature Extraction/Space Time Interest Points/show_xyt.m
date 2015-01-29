function show_xyt(f0,step_flag,minv,maxv)

set(get(gca,'Parent'),'DoubleBuffer','on')

if (ndims(f0)>2)
  clf
  if nargin<3 minv=min(f0(:)); end
  if nargin<4 maxv=max(f0(:)); end
  for i=1:size(f0,ndims(f0))
    if ndims(f0)==3 showgrey(f0(:,:,i),128,minv,maxv);
    else showimage(f0(:,:,:,i));
    end
    title(sprintf('frame %d of %d',i,size(f0,ndims(f0))))
    if (nargin>1) pause
    else drawnow; % pause(0.1)
    end
  end
end
