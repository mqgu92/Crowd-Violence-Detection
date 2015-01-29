function gray=il_rgb2gray(rgb)

%
% gray=il_rgb2gray(rgb)
%
%   converts rgb image(s) into one channel
%   (gray) image(s) as gray=(r+g+b)/3
%

if ndims(rgb)<3
  gray=rgb;
else
  gray=sum(rgb,3)/size(rgb,3);
end
