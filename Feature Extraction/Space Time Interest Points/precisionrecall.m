function [rec,prec,ap,sortind]=precisionrecall(conf,labels,drawflag,nfalseneg)

if nargin<3 drawflag=1; end
if nargin<4 nfalseneg=0; end

[so,sortind]=sort(-conf);
tp=labels(sortind)==1;
fp=labels(sortind)~=1;
npos=length(find(labels==1))+nfalseneg;

% compute precision/recall
fp=cumsum(fp);
tp=cumsum(tp);
rec=tp/npos;
prec=tp./(fp+tp);

% compute average precision

ap=0;
for t=0:0.1:1
    p=max(prec(rec>=t));
    if isempty(p)
        p=0;
    end
    ap=ap+p/11;
end


if drawflag
    % plot precision/recall
    plot(rec,prec,'-');
    grid;
    xlabel 'recall'
    ylabel 'precision'
    title(sprintf('AP = %.3f',ap));
    axis([0 1 0 1])
end
