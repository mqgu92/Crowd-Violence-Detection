%modified interface to VI-library, author Stefan Karlsson

function img = vi_get_pixelsProper(VI, device_id, width, height)

img = vi_get_pixels(VI, device_id);

img = fliplr(uint8(sum(img(1:height,1:width,:),3)/3));

