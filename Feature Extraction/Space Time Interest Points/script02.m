% script02.m
%
% this script demonstrates Nearest-Neighbour and SVM classification
% on a subset of two classes of Hollywood-2 human actions dataset 
% http://www.irisa.fr/vista/actions/hollywood2
%



datapath='data/hollywood2_samples';

stippath='stip/data';
f2=read_image_sequence([stippath '/walk-complex.avi'],'',1,100,0,1);

 if 1 % display features for a sample video
   samplename='actioncliptrain00182';
   fprintf('Displaying STIP features for a short episode of Casablanca\n')
   fprintf('(If you cannot execute this part due Matlab video-read problems,\n')
   fprintf(' just continue to the next step. This step has the purpose \n')
   fprintf(' of visualizing features only.\n')
 %  f=read_image_sequence(['data/' samplename '.avi'],'',1,120);


   stips=load([datapath '/' samplename '.txt']);
   showcirclefeatures_xyt(f,stips(:,5:9));
   fprintf('Press a key...\n\n'), pause
 end


%%%%%%%%%%%% TODO
%%%%%%%%%%%%
%%%%%%%%%%%% set the target class by commenting/uncommenting one of the following two lines
%%%%%%%%%%%%

%action='HugPerson';
action='SitDown';


% load training and test annotation
trainfname=[datapath '/' action '_train_sel.txt'];
testfname=[datapath '/' action '_test_sel.txt'];
[trainids,traingt]=textread(trainfname,'%s%d');
[testids,testgt]=textread(testfname,'%s%d');
fprintf('read annotation for %d training samples with %d samples of class %s\n',length(traingt),length(find(traingt==1)),action)
fprintf('read annotation for %d test samples with %d samples of class %s\n',length(testgt),length(find(testgt==1)),action)


%%%%%%%%%%%% TODO
%%%%%%%%%%%%
%%%%%%%%%%%% uncomment the following two lines to simulate performance of a random classifier
%%%%%%%%%%%% by randomly permuting training and test labels
%%%%%%%%%%%%

%traingt=traingt(randperm(length(traingt)));
%testgt=testgt(randperm(length(testgt)));


if 1 % compute BOF histograms for training and test samples
  
  n=4000; % the size of visual vocabulary
  
  % training samples
  trainbof=zeros(length(trainids),n); % pre-allocate memory;
  fprintf('compute BOF histograms for %d training samples...\n',length(trainids))
  for i=1:length(trainids)
    samplename=[datapath '/' trainids{i} '.txt'];
    qstip=load(samplename);
    stiplabels=qstip(:,end);
    
    %%%%%%%% TODO
    %%%%%%%%
    %%%%%%%% compute visual word histograms from 'stiplabels'
    %%%%%%%% hint: use 'histc' function

    % histogram of stip labels
    h= histc(stiplabels,4000);
    
    % normalize to l2-norm
    trainbof(i,:)=transpose(h(:)/sqrt(h'*h));
  end

  % test samples
  testbof=zeros(length(testids),n); % pre-allocate memory;
  fprintf('compute BOF histograms for %d test samples...\n',length(testids))
  for i=1:length(testids)
    samplename=[datapath '/' testids{i} '.txt'];
    qstip=load(samplename);
    stiplabels=qstip(:,end);
    
    
    %%%%%%%% TODO
    %%%%%%%%
    %%%%%%%% compute visual word histograms from 'stiplabels'
    %%%%%%%% (same as above)

    % histogram of stip labels (THE SAME AS ABOVE!)

    h = histc(stiplabels,4000);
    testbof(i,:)=transpose(h(:)/sqrt(h'*h));
  end
  fprintf('Press a key...\n\n'), pause
end


if 1 % Nearest-Neighbour classification
  
  fprintf('running Nearest-Neighbour classifier...\n')
  dmat=eucliddist(testbof,trainbof);
  [mv,mi]=min(dmat,[],2);
  conf=-mv;
  
  % plot precision-recall curve
  figure(1), clf


end

  
if 1 % SVM classification using SVM-light package http://svmlight.joachims.org/
  
  fprintf('running SVM classifier...\n')
  addpath('svm_mex601')
  addpath('svm_mex601/bin')
  addpath('svm_mex601/matlab')

  
  %%%%%%%%% TODO
  %%%%%%%%%
  %%%%%%%%% try SVM classifiers with different C and gamma parameters
  %%%%%%%%% 
  
  x=trainbof;
  y=traingt;
  model = svmtrain(y,x);
  
  xtest=testbof;
  ytest=testgt;

  [predictions, accuracy, prob_estimates] =  predict(ytest, xtest, model)

  % draw precision-recall curve
  figure(2), clf

end

