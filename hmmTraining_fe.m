% Copyright (c) 2012, Jianxia Xue, jxue@cs.olemiss.edu
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

% feature extraction of all wav files in a folder
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
