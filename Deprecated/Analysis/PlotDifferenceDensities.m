 VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\Video\';
addpath('Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\')
 VIDLIST  = vidListGenFNHockey( 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\SIFTFlows\FLOWS\Cross\' );
 CLASS = 'Fight';
 
 VIDLIST  = vidListGenFNHockey( 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\SIFTFlows\' );
   VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\VideoCutsSmall\';
      % VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\Videos - Copy';
     addpath(VIDDIR);
% VIDLIST = VIDLIST(find(ismember(VIDLIST(:,3),CLASS)),:);
 MinCol = zeros(length(VIDLIST),1) * 99999999;
 MaxCol = zeros(length(VIDLIST),1);
 AvgCol = zeros(length(VIDLIST),1);
 VarCol = zeros(length(VIDLIST),1);
 SeriesCol = cell(length(VIDLIST),1);
 for v = 1 : length(VIDLIST)
        [PATHSTR,NAME,EXT] = fileparts(VIDLIST{v,1});
        [ MinCol(v), MaxCol(v), AvgCol(v),  VarCol(v),SeriesCol{v} ] = GetDifferenceDensities( [VIDDIR,'\',NAME,'.avi'],true );
 end
 
 disp(['Min: ',num2str(mean(MinCol))]);
disp (['Max: ',num2str(mean(MaxCol))]);
 disp(['Mean: ',num2str(mean(AvgCol))]);
  disp(['Var: ',num2str(mean(VarCol))]);
  
  
  
  FIGHTEND = 119;
  
  FM = zeros(FIGHTEND-1,1) + mean(AvgCol(1:FIGHTEND - 1));
  NFM = zeros(length(AvgCol(FIGHTEND:end))-1,1) + mean(AvgCol(FIGHTEND:end));
  
  F = AvgCol; F(FIGHTEND:end) = 0;
  NF = AvgCol; NF(1:FIGHTEND - 1) = 0;
 figure,bar(F,'b'); hold on; bar(NF,'g','EdgeColor','g');hold on; plot([FM;NFM],'r')
  xlabel('Video Sample (Violence, Non-Violence)');
  ylabel('Pixel Difference');
  title('Average Pixel Difference Per Video');
  axis tight
  FM = zeros(FIGHTEND-1,1) + mean(sqrt(VarCol(1:FIGHTEND - 1)));
  NFM = zeros(length(AvgCol(FIGHTEND:end)),1) + mean(sqrt(VarCol(FIGHTEND:end)));
  
  F = sqrt(VarCol); F(FIGHTEND:end) = 0;
  NF = sqrt(VarCol); NF(1:FIGHTEND - 1) = 0;
 figure,bar(F,'b'); hold on; bar(NF,'g','EdgeColor','g');hold on; plot([FM;NFM],'r')
  xlabel('Video Sample (Violence, Non-Violence)');
  ylabel('Pixel Difference');
  title('Pixel Difference Variance Per Video');
    axis tight
 
  % Other Null Tests
[ Significant,Normal, DATA ] = PerformSignificance( AvgCol(FIGHTEND:end), AvgCol(1:FIGHTEND - 1) );
[ Significant,Normal, DATA ] = PerformSignificance( VarCol(FIGHTEND:end), VarCol(1:FIGHTEND - 1) );