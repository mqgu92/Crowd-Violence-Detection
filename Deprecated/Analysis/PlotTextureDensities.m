VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\Video\';
addpath('Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\')
VIDLIST  = vidListGenFNHockey( 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\SIFTFlows\FLOWS\Cross\' );
CLASS = 'Fight';
% 
VIDLIST  = vidListGenFNHockey('Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\SIFTFlows\' );
%VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\Videos\';
VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\Videos - Copy\';


% VIDLIST  = vidListGenFNHockey( 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\SIFTFlows\' );
% VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\VideoCutsSmall\';
addpath(VIDDIR);
% VIDLIST = VIDLIST(find(ismember(VIDLIST(:,3),CLASS)),:);
ENERGYStats = zeros(length(VIDLIST),2);
CONTRASTStats = zeros(length(VIDLIST),2);
CORRELATIONStats = zeros(length(VIDLIST),2);
HOMOGENEITYStats = zeros(length(VIDLIST),2);
 for v = 1 : length(VIDLIST)
     disp(num2str(v));
    [ PATHSTR, NAME, EXT ] = fileparts(VIDLIST{v,1});

    [ ENERGY, CONTRAST, CORRELATION,HOMOGENEITY ] = GetTextureMeasures( [VIDDIR,'\',NAME,'.avi'] )

    ENERGYStats(v,1) = ENERGY{2};
    ENERGYStats(v,2) = ENERGY{3};

    CONTRASTStats(v,1) = CONTRAST{2};
    CONTRASTStats(v,2) = CONTRAST{3};
    
    CORRELATIONStats(v,1) = CORRELATION{2};
    CORRELATIONStats(v,2) = CORRELATION{3};
    
    HOMOGENEITYStats(v,1) = HOMOGENEITY{2};
    HOMOGENEITYStats(v,2) = HOMOGENEITY{3};
    
 end
 
 METRIC = ENERGYStats(:,1);
 METRICVAR = ENERGYStats(:,2);
 FIGHTEND = 501;
 
 FM = zeros(FIGHTEND-1,1) + mean(METRIC(1:FIGHTEND - 1));
 NFM = zeros(length(METRIC(FIGHTEND:end)),1) + mean(METRIC(FIGHTEND:end));
 
 F = METRIC; F(FIGHTEND:end) = 0;
 NF = METRIC; NF(1:FIGHTEND - 1) = 0;
 figure,bar(F,'b'); hold on; bar(NF,'g','EdgeColor','g');hold on; plot([FM;NFM],'r')
 xlabel('Video Sample (Violence, Non-Violence)');
 ylabel('Energy');
 title('Average Frame Texture Energy');
  axis tight
 
 FM = zeros(FIGHTEND-1,1) + mean(sqrt(METRICVAR(1:FIGHTEND - 1)));
 NFM = zeros(length(METRICVAR(FIGHTEND:end)),1) + mean(sqrt(METRICVAR(FIGHTEND:end)));
 
 F = sqrt(METRICVAR); F(FIGHTEND:end) = 0;
 NF = sqrt(METRICVAR); NF(1:FIGHTEND - 1) = 0;
 figure,bar(F,'b'); hold on; bar(NF,'g','EdgeColor','g');hold on; plot([FM;NFM],'r')
 xlabel('Video Sample (Violence, Non-Violence)');
 ylabel('Energy');
 title('Texture Energy Variation Per Sample');
  axis tight
 
 
  % Other Null Tests
[ Significant,Normal, DATA ] = PerformSignificance( METRIC(FIGHTEND:end), METRIC(1:FIGHTEND - 1) );
[ Significant,Normal, DATA ] = PerformSignificance( METRICVAR(FIGHTEND:end), METRICVAR(1:FIGHTEND - 1) );
 
 
 
 
 
  
 METRIC = CONTRASTStats(:,1);
 METRICVAR = CONTRASTStats(:,2);
 
 FM = zeros(FIGHTEND-1,1) + mean(METRIC(1:FIGHTEND - 1));
 NFM = zeros(length(METRIC(FIGHTEND:end)),1) + mean(METRIC(FIGHTEND:end));
 
 F = METRIC; F(FIGHTEND:end) = 0;
 NF = METRIC; NF(1:FIGHTEND - 1) = 0;
 figure,bar(F,'b'); hold on; bar(NF,'g','EdgeColor','g');hold on; plot([FM;NFM],'r')
 xlabel('Video Sample (Violence, Non-Violence)');
 ylabel('Contrast');
 title('Average Texture Contrast Per Sample');
  axis tight
 
 FM = zeros(FIGHTEND-1,1) + mean(sqrt(METRICVAR(1:FIGHTEND - 1)));
 NFM = zeros(length(METRICVAR(FIGHTEND:end)),1) + mean(sqrt(METRICVAR(FIGHTEND:end)));
 
 F = sqrt(METRICVAR); F(FIGHTEND:end) = 0;
 NF = sqrt(METRICVAR); NF(1:FIGHTEND - 1) = 0;
 figure,bar(F,'b'); hold on; bar(NF,'g','EdgeColor','g');hold on; plot([FM;NFM],'r')
 xlabel('Video Sample (Violence, Non-Violence)');
 ylabel('Contrast');
 title('Texture Contrast Variance Per Sample');
  axis tight
 
 
  % Other Null Tests
[ Significant,Normal, DATA ] = PerformSignificance( METRIC(FIGHTEND:end), METRIC(1:FIGHTEND - 1) );
[ Significant,Normal, DATA ] = PerformSignificance( METRICVAR(FIGHTEND:end), METRICVAR(1:FIGHTEND - 1) );
 
 
 
 
 
%   METRIC = ENERGYStats(:,1);
%  METRICVAR = ENERGYStats(:,2);
%  
%  FIGHTEND = 501
%  
%  HFM = zeros(FIGHTEND-1,1) + mean(sqrt(METRICVAR(1:FIGHTEND - 1)));
%  HNFM = zeros(length(METRICVAR(FIGHTEND:end)),1) + mean(sqrt(METRICVAR(FIGHTEND:end)));
%  
%  HF = sqrt(METRICVAR(FIGHTEND:end)); 
%  HNF = sqrt(METRICVAR(1:FIGHTEND - 1));
%  figure,bar(F,'b'); hold on; bar(NF,'m','EdgeColor','m');hold on; plot([FM;NFM],'r')
%  xlabel('Video Sample (Violence, Non-Violence)');
%  ylabel('Energy');
%  title('Texture Energy Variation Per Sample');
%  
 
 
 