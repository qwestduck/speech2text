% feature extraction of all wav files in a folder
%
function hmmTraining_fe(folder, config)

if (nargin < 2)
    config.fs = 8000;
    config.winType = 'hamming';
    config.winLen = 256;
    config.winSpa = 128;

    config.Nfft = 512;

    config.featureType = 'mfcc';
    config.featureSize = 13;        
end

config.window = hamming(config.winLen);

files = dir([folder '/*.wav'] );

for i=1:length(files)
    wavfile = files(i);
    wavfile.name = [folder '/' wavfile.name];
    
    featureFile = strrep(wavfile.name, '.wav', ['.' config.featureType]);
    
    [data, fs] = wavread(wavfile.name);
    config.M = config.featureSize;
    [frames, centers] = framing(data, fs, config.winLen, config.winSpa);
    
    [features, labels] = shortTimeAnalysis(frames, centers, config);
    
    save([featureFile '.mat'], 'config', 'features', 'labels');
    disp(['done ' featureFile]);
end