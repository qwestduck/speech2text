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
