function loop2()
    global giveInstruction;

    giveInstruction = true;
    state = 0;

    while( true )
        if(giveInstruction && ~strcmp(state, 's_exit') ) 
            instruction(); 
            giveInstruction = false;
        end    

        state = t_x( state );

        if( state == -1 ) 
            break; 
        end
    end
end

% Collapsed transitions
function state = t_x( s )
  global giveInstruction;
  
  change = s-25;
  if(change < 0)
      change = 0;
  end
  
  disp(['Current: ' num2str(s)]);
  disp(['Change: '  num2str(change)]);
  
  if( s >= 0 && s < 25 )
    giveInstruction = true;
    T = speech2text();
    switch T
        case 'four'
            state = s + 25;
        case 'three'
            state = s + 10;
        case 'two'
            state = s + 5;
        case 'one'
            state = -1;
        otherwise
            state = s;
    end
  elseif( s == 25 ) 
    giveInstruction = true;
    disp 'Have a coke!';

    state = 0;
  elseif( s >= 25 && s <=50 )
    giveInstruction = false;
    state = 25;
  else
    state = -1;
  end 
end

function instruction()
  disp '1: Exit'
  disp '2: Insert a Nickel';
  disp '3: Insert a Dime';
  disp '4: Insert a Quarter';
end

function value = speech2text()
configData;
value = '';
r = audiorecorder(8000, 16, 1);
one_hmm = load('project/model/one.hmm.mat');
two_hmm = load('project/model/two.hmm.mat');
three_hmm = load('project/model/three.hmm.mat');
four_hmm = load('project/model/four.hmm.mat');
while( isempty(value) )
  % value = input('', 's');
    disp('Recording...');
    recordblocking( r, 2 );
    disp('Done!');
    data = getaudiodata(r);
    
    if( config.DEBUG )
        plot(data); 
    end
    
    % scale dataset for 8 khz sampling rate
    data = data .* 8;

    S = getSegmentations(data, 8000, {''});

    % grab the start and end-times of the first segment
    S_array = cell2mat(S(3:4));
    
    config.M = config.featureSize;
    
    initial = S_array(1);
    duration = initial + S_array(2);

    data_subset = data(initial : duration);

    [frames, centers] = framing(data_subset, 8000, config.winLen, config.winSpa);
    [features, labels] = shortTimeAnalysis(frames, centers, config);
    
    THRESHHOLD = -inf;
    
    if( config.DEBUG)
       disp('DEBUG: frames');
       disp(frames);
       disp('DEBUG: centers');
       disp(centers);
       disp('DEBUG: features');
       disp(features);
       disp('DEBUG: Hmm');
       disp(one_hmm.hmm);
    end
    
    likelihoods = [-inf -inf -inf -inf]
    
    [alpha, likelihoods(1)] = one_hmm.hmm.forward(features);
    [alpha, likelihood(2)] = two_hmm.hmm.forward(features);
    [alpha, likelihood(3)] = three_hmm.hmm.forward(features);
    [alpha, likelihood(4)] = four_hmm.hmm.forward(features);
    
    values = ['one' 'two' 'three' 'four'];
    
    [C I] = max(likelihoods)
    if(C > THRESHHOLD)
       value = values(I);
       break;
    end
end
end
