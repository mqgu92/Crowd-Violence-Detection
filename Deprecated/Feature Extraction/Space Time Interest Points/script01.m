% script01.m
%
% this script demonstrates
%   - detection of space-time interest points on two example image sequences
%   - construction of k-means visual dictionary
%   - assignment of feature labels according to the visual dictionary
%

stippath='stip/data';
datapath='data';

%%%%%%%%%% TODO
%%%%%%%%%%
%%%%%%%%%% run space-time interest point detector 'stipdet' in 'stip' directory
%%%%%%%%%% for two sequences 'walk-simple.avi' and 'walk-complex.avi':
%%%%%%%%%%
%%%%%%%%%% bin\stipdet.exe -f data\walk-simple.avi -o data\walk-simple-stip.txt
%%%%%%%%%% bin\stipdet.exe -f data\walk-complex.avi -o data\walk-complex-stip.txt
%%%%%%%%%%
%%%%%%%%%% 'stipdet' code is also available from 
%%%%%%%%%% http://www.irisa.fr/vista/Equipe/People/Laptev/download.html#stip


if 1 % read image sequences
  if 0
    % from avi videos 
    f1=read_image_sequence([stippath '/walk-simple.avi'],'',1,110,0,1);
    f2=read_image_sequence([stippath '/walk-complex.avi'],'',1,100,0,1);
    save([datapath '/samplevids.mat'],'f1','f2');
  else
    % from pre-saved matlab file
    load([datapath '/samplevids.mat'],'f1','f2');
  end
  
  % display videos
  fprintf('Displaying the first sequence...\n')
  show_xyt(f1)
  fprintf('Displaying the second sequence...\n')
  show_xyt(f2)
  fprintf('Press a key...\n\n'), pause
end

if 1 % load and display features
  [pos1,val1,dscr1]=readstips_text([stippath '/walk-simple-stip.txt']);
  [pos2,val2,dscr2]=readstips_text([stippath '/walk-complex-stip.txt']);
  fprintf('Displaying features from the first sequence...\n')
  showcirclefeatures_xyt(f1,pos1);
  fprintf('Displaying features from the second sequence...\n')
  showcirclefeatures_xyt(f2,pos2);
  fprintf('Press a key...\n\n'), pause
end

if 1 % k-means clustering of descriptors
  
  % k-means clustering of descriptors 'dscr1' obtained for the of the first sequence
  [centers1,labels1,mimdist1]=kmeans(dscr1,50);
  
  % visualization of features belonging to the two largest clusters
  ind1=find(labels1<=2);
  fprintf('Displaying feature clusters for the first (training) sequence...\n')
  showcirclefeatures_xyt(f1,pos1(ind1,:),labels1(ind1));
end

if 1  % assign points to cluster centers
  
  %%%%%%%%%%% TODO 
  %%%%%%%%%%%
  %%%%%%%%%%% Assignment of descriptors 'dscr2' of the second sequence
  %%%%%%%%%%% to the vocabulary obtained with k-means on the first sequence
  %%%%%%%%%%% Hint: used 'eucliddist' and 'min' functions
  
  % labels for features in the second sequence
  %labels2=...
  
   % k-means clustering of descriptors 'dscr1' obtained for the of the first sequence
  [centers2,labels2,mimdist2]=kmeans(dscr2,50);
  
  
  ind2=find(labels2<=2);
  fprintf('Displaying feature clusters for the second (test) sequence...\n')
  showcirclefeatures_xyt(f2,pos2(ind2,:),labels2(ind2));
end
