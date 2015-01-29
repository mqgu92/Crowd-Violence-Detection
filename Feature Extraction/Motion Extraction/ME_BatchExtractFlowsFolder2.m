function ME_BatchExtractFlowsFolder2( MAINDIR )
%%
%
%   READ CSV file
%
%%

%Extract directories in main dir

dirInfo = dir(strcat(MAINDIR,'\*.avi'));
Extract = {dirInfo(:).name}';

for i = 1 : length(Extract)

    Clas = 'AllVideo';
    found = false;   
  
    VName = strcat(MAINDIR,'\',Extract{i});
    
    if exist(VName, 'file')
        ME_ExtractOpticalFlows( VName,Clas,false );
        disp(strcat('Video Extracted: ',VName));
        found =  true;
    end

    if ~found
        disp(strcat('Not Found: ',VName));
    end
    
end
    


end

