% Clears up memory
% persistent variables in functions:
clear grad2Dm; 
clear DoFlowT1;

if strcmpi(kindOfMovie,'file')
    delete(vid);   
elseif strcmpi(kindOfMovie,'camera')
  if vid.bUseCam ==2
      vi_stop_device(vid.camIn, vid.camID-1);
      vi_delete(vid.camIn);
  else
      delete(vid.camIn); 
  end
end 
