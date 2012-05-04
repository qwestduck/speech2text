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

% configuration file for the HMM training parameters
% Edit this file before you run the applications
% @author Jianxia Xue
% @version 0.20120410

% directory configurations
trainingFolder = 'project/training';
testingFolder = 'project/testing';
modelFolder = 'project/models';

% feature extraction configurations
fs = 8000;
winLen = 256;
winSpa = 128;
winType = 'hamming';
Nfft = 512;

featureSize = 13;
featureType = 'MFCC';

% backend modeling configurations
% note that silence model will be added by default
vocabulary = {'one', 'two', 'three', 'four'};
NhiddenStates = 3;
MgaussianMixtures = 3;

config.DEBUG = true;

config.trainingFolder = trainingFolder;
config.testingFolder = testingFolder;
config.modelFolder = modelFolder;

config.window = hamming(winLen);

config.fs = fs;
config.winLen = winLen;
config.winSpa = winSpa;
config.winType = winType;
config.Nfft = Nfft;

config.featureSize = featureSize;
config.featureType = featureType;

config.vocabulary = vocabulary;
config.NhiddenStates = NhiddenStates;
config.MgaussianMixtures = MgaussianMixtures;
