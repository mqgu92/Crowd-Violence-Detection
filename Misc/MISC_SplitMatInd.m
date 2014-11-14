function [ XRange,YRange ] = MISC_SplitMatInd( DATA,Q,P,Y,X )
%   Suppose we split a mat in Q by P cells, rather than return the contents
%   of these cells this function returns the X,Y indexes ranges that
%   correspond to a particular cell X,Y
%
[M N] = size(DATA);
XIntervals = diff(round(linspace(0,N,P+1)));
YIntervals = diff(round(linspace(0,M,Q+1)));

XRange = (sum(XIntervals(1:(X-1))) + 1: sum(XIntervals(1:(X))));
YRange = (sum(YIntervals(1:(Y-1))) + 1: sum(YIntervals(1:(Y))));

end

