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

function organizeObservationPerWord( trainingFolder, vocabulary, featureType, modelFolder )

[stat, takes, sampleLists] = takeManager(trainingFolder, vocabulary);

for i=1:length(vocabulary)
    observation = loadFeatures(sampleLists{i}, ['.' featureType '.mat'] );
    word = vocabulary{i};
    fn  = [modelFolder '/' vocabulary{i} '.observation.mat'];
    save( fn, 'observation', 'word');
    disp([ fn ' saved for word ' word]);
end


function featureList = loadFeatures(sampleList, featureSurfix)
Nsamples = size(sampleList, 1);
featureList = cell(1, Nsamples);
for i=1:Nsamples
    take = sampleList{i,1};
    startTime = sampleList{i,2};
    duration = sampleList{i,3};
    
    load( [take featureSurfix] );
    frameFreq = config.fs/1000 / config.winSpa;
    
    startFrame = ceil(startTime * frameFreq);
    stopFrame = floor(startFrame + duration * frameFreq);
    
    featureList{i} = features(:, startFrame:stopFrame);
end
