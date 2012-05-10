function sample2()
configData;
value = '';
r = audiorecorder(8000, 16, 1);
m_hmm = load([config.modelFolder '/m.hmm.mat']);
f_hmm = load([config.modelFolder '/f.hmm.mat']);
while( isempty(value) )
  % value = input('', 's');
    if( ~config.DEBUG )
       disp('Recording...');
       recordblocking( r, 2 );
       disp('Done!');
       data = getaudiodata(r);
    else
       data = wavread([config.trainingFolder '/sample_f3.wav']);
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
    
    % config.M = config.featureSize;
    
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
       disp(m_hmm.hmm);
    end
    
    likelihoods = [-inf -inf];
    
    [alpha, likelihoods(1)] = m_hmm.hmm.forward(features);
    [alpha, likelihoods(2)] = f_hmm.hmm.forward(features);
    
    if( config.DEBUG )
      disp(likelihoods);
    end
    
    [C I] = max(likelihoods);
    if(C > THRESHHOLD)
      switch I
          case 1
              value = 'Male';
          case 2
              value = 'Female';
          otherwise
              continue;
       end
        
       disp(['You are ' value]);
       break;
    end
end
end

