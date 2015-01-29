function showgrey( Image, res, zmin, zmax)
%  SHOWGREY(IMAGE, RESOLUTION, ZMIN, ZMAX)
%    displays the real matrix IMAGE as a gray-level image on the screen.
%
%  Arguments:
%    If RESOLUTION is a scalar value, RESOLUTION distinct gray-levels,
%    equidistantly spaced between 0 (black) and 1 (white), are used.
%    If RESOLUTION is a vector, its elements (which should lie in the 
%    interval [ 0, 1]) are used as gray-levels (colormap).
%
%    The (matrix element) values ZMIN and ZMAX are mapped to black and
%    white respectively. For a quantized image, it is often advisable 
%    to set ZMAX to the first quantization level outside actual range.
%    Values in ] ZMIN, ZMAX[ are mapped by linear interpolation, whereas
%    values outside this interval are mapped to either black or white by
%    truncation.
%
%    If ZMIN and ZMAX are omitted, they are set to the true max
%    and min values of the elements of IMAGE.
%
%    If RESOLUTION is also omitted, it is assumed to be 64.
%    If ZMIN = ZMAX, the displayed image is thresholded at ZMAX.

if (nargin < 1)
  error( 'Wrong number of input arguments.')
  return
end
if (nargin <= 1)
  res = 64;
end
if (nargin <= 3)
  zmin = min( Image( :));
  zmax = max( Image( :));
end

rsize = size( res);

if isempty( Image)
  error( 'Bad argument: arg #1 (Image) must not be empty.')
  return
elseif all( rsize ~= 1)
  error( 'Bad argument: arg #2 (res) must be a vector (or scalar).')
  return
elseif any( size( zmax) ~= 1)
  error( 'Bad argument: arg #3 (zmax) must be scalar.')
  return
elseif any( size( zmin) ~= 1)
  error( 'Bad argument: arg #3 (zmin) must be scalar.')
  return
end

if all( rsize == 1)
  col = linspace( 0, 1, res)';

  if res <= 1
    error( 'Bad argument: scalar arg #2 (res) < 2 .')
    return
  end
else
  if rsize( 1) == 1
    col = res';
  else
    col = res;
  end

  res = length( col);
end

range = zmax - zmin;

if ~range
  range = eps;
end

image( 1 + res / range * ( Image - zmin));
colormap( [ col col col]);

axis image
axis off


