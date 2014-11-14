function outIm= vi_setup_deviceProper(VI, device_id, width, height, fps)

bVerbose = 0;
autoFlag = false;

if bVerbose 
    disp(['asked for width=' num2str(width) ' and height=' num2str(height)]);end
for its = 0:5:100
    vi_set_video_setting(VI, device_id, 5, 1, autoFlag );
    vi_setup_device(VI, device_id, width+its, height+its, fps);
    vi_is_frame_new(VI, 0);
    outIm = vi_get_pixels(VI, 0);
    [H,W, ~] = size(outIm);
    if bVerbose 
        disp(['H: ' num2str(H) 'W: ' num2str(W)]);end
    if (H >height) && (W >width)
%         disp(['H: ' num2str(H) 'W: ' num2str(W)])
        break;
    else
        vi_stop_device(VI, device_id);
    end
end




vi_set_video_setting(VI, device_id, 5, 1, autoFlag );