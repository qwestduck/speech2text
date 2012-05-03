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