
%%%%CALLBACK FUNCTION FOR KEYBOARD PRESS %%%%%
function myKeypress(~,evnt)
    global g;
    bUpdateText = 1;

    switch evnt.Key,
	  case 'q'
          g.lagTime = g.lagTime + 0.05;
      case 'a'
          g.lagTime = max(0,g.lagTime - 0.05);
      case 'w'
          g.spdFactor(1) = g.spdFactor(1) + 0.5;
      case 's'
          g.spdFactor(1) = max(0,g.spdFactor(1) - 0.5);
      case {'e', 'pagedown'}
          g.spdFactor(2) = g.spdFactor(2) + 0.5;
      case {'d','pageup'}
          g.spdFactor(2) = g.spdFactor(2) - 0.5;
      case 'uparrow'
          g.arrowKey(2) = 1;          
      case 'downarrow'
          g.arrowKey(2) = -1;
      case 'rightarrow'
          g.arrowKey(1) = -1;
	  case 'leftarrow'
          g.arrowKey(1) = 1;
      otherwise
          bUpdateText = 0;
%             disp(['Currently no binding for: ' evnt.Key]);
    end
    
    if evnt.Key == 'p'
        g.bPause = ~g.bPause;
    else
        g.bPause = 0;
    end

    if bUpdateText
        set(g.figH, 'Name',['[q,a]Lagtime: ' num2str(g.lagTime,'%1.2f') ',  [w,s]Speed: ' num2str(g.spdFactor(1),'%2.1f')  ',  [e,d]Rotation: ' num2str(g.spdFactor(2),'%2.1f') ]);end
  