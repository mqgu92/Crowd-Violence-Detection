global RANDOM_FOREST_VERBOSE;
    RANDOM_FOREST_VERBOSE = true;
global RANDOM_FOREST_TREES;
    RANDOM_FOREST_TREES = 15;
global RANDOM_FOREST_VERBOSE_MODEL;
    RANDOM_FOREST_VERBOSE_MODEL = false;
global LINEAR_SVM_VERBOSE;
    LINEAR_SVM_VERBOSE = true;
global DIR_STIP;
    DIR_STIP = fullfile(pwd,'Space Time Interest Points');

VIDEOSET = 'C:\Users\c1112308\Documents\Datasets\Video';    
DATA_GLCM = 'F:\DATA\DATA-GLCMMEX';

DATA_VIDEO_UCF = struct('dir',[VIDEOSET,'\UCF Modified\Normal_Abnormal_Crowd Converted'],...
    'name','UCFS Modified2','fold', 2);

%NXN is the 3 by 3 video display
DATA_VIDEO_NXN = struct('dir',[VIDEOSET,'\NXN'],...
    'name','XNX','fold', 2);

DATA_VIDEO_UMN = struct('dir',[VIDEOSET,'\UMN\Crowd-Activity']...
    ,'name','UMN','fold', 2);
DATA_VIDEO_UMN_TEN = struct('dir',[VIDEOSET,'\UMN\Crowd-Activity']...
    ,'name','UMNTen','fold', 2);

DATA_VIDEO_CVD = struct('dir',[VIDEOSET,'\CVD']...
    ,'name','CVD','fold', 4);

DATA_VIDEO_CVDS = struct('dir',[VIDEOSET,'\CVD']...
    ,'name','CVDS','fold', 4);
DATA_VIDEO_CVDALL = struct('dir',[VIDEOSET,'\CVD All']...
    ,'name','CVDALL','fold', 4);

DATA_VIDEO_CVDMULTI = struct('dir',[VIDEOSET,'\CVD MultiClass']...
    ,'name','CVDMULTI','fold', 4);

DATA_VIDEO_HOCKEY = struct('dir',[VIDEOSET,'\Hockey']...
    ,'name','HOCKEY','fold', 5);

DATA_VIDEO_KTH = struct('dir',[VIDEOSET,'\KTH']...
    ,'name','KTH','fold', 10);

DATA_VIDEO_KTHVTT = struct('dir',[VIDEOSET,'\KTH VTT']...
    ,'name','KTH','fold', 0); % The same descriptors, just different tags

DATA_VIDEO_VF = struct('dir',[VIDEOSET,'\Violent Flows Ver']...
    ,'name','VF','fold', 5);

DATA_VIDEO_UMNSCENE1 = struct('dir','F:\Videos\UMN Scene 1',...
    'name','UMN_SCENE1','fold', 2);
DATA_VIDEO_UMNSCENE2 = struct('dir','F:\Videos\UMN Scene 2',...
    'name','UMN_SCENE2','fold', 2);
DATA_VIDEO_UMNSCENE3 = struct('dir','F:\Videos\UMN Scene 3',...
    'name','UMN_SCENE3','fold', 2);
DATA_VIDEO_UMNMULTI = struct('dir','F:\Videos\UMN MultiClass',...
    'name','UMN_MULTI','fold', 2);




% Default GLCM parameters
Param_GLCM_Default = struct('baseoffsets',[1 0; -1 0; 0 1;0 -1],...
    'graylevel',64,...
    'pyramid',[1 1],...
    'range',[1 2 3 4]);

Param_EdgeCardinality_Default = struct('type','log');

Param_PixelDifference_Default = struct('framejump',[1]);