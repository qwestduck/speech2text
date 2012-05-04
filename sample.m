% Copyright (c) 2012, William Panlener, wpanlener@gmail.com
% All rights reserved.
%
% Redistribution and use in source, with or without 
% modification, are permitted provided that the following conditions are 
% met:
%
%   * Redistributions of source code must retain the above copyright 
%     notice, this list of conditions and the following disclaimer.
%   * Redistributions in binary form must reproduce the above copyright 
%     notice, this list of conditions and the following disclaimer in 
%     the documentation and/or other materials provided with the distribution
%      
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

function sample()
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
one_hmm = load([config.modelFolder '/one.hmm.mat']);
two_hmm = load([config.modelFolder '/two.hmm.mat']);
three_hmm = load([config.modelFolder '/three.hmm.mat']);
four_hmm = load([config.modelFolder '/four.hmm.mat']);
while( isempty(value) )
  % value = input('', 's');
    if( ~config.DEBUG )
       disp('Recording...');
       recordblocking( r, 2 );
       disp('Done!');
       data = getaudiodata(r);
    else
       data = wavread([config.trainingFolder '/two-three-one-four.wav']);
       plot(data);
       pause(5);
    end
    
    % scale dataset for 8 khz sampling rate
    data = data .* 8;

    S = getSegmentations(data, 8000, {''});

    if( isempty(S) )
        disp('I couldn''t hear you!');
        continue;
    end    
      
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
    
    likelihoods = [-inf -inf -inf -inf];
    
    [alpha, likelihoods(1)] = one_hmm.hmm.forward(features);
    [alpha, likelihoods(2)] = two_hmm.hmm.forward(features);
    [alpha, likelihoods(3)] = three_hmm.hmm.forward(features);
    [alpha, likelihoods(4)] = four_hmm.hmm.forward(features);
    
    % if( config.DEBUG )
       disp(likelihoods);
    % end
    
    [C I] = max(likelihoods);
    if(C > THRESHHOLD)
      switch I
          case 1
              value = 'one';
          case 2
              value = 'two';
          case 3
              value = 'three';
          case 4
              value = 'four';
          otherwise
              continue;
       end
        
       disp(['You said ' value]);
       break;
    end
end
end
