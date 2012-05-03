function hmm = trainHmm( modelFolder, word, N, M )

ofile = [modelFolder '/' word '.observation.mat'];
load(ofile); % should load observation and word

hfile = [modelFolder '/' word '.hmm.mat'];

disp(['Start HMM training for word ' word]);

hmm = WordHmm( word, N, M);

hmm.initB(observation);

likelihood = hmm.emgm(observation);    
iter = 1;
for iter = 2: 10
    l = hmm.emgm(observation);
    if ( l < likelihood )
        likelihood = l;
    else
        break;
    end
    fprintf('likelihood = %8.3f\n', l);
end

fprintf('likelihood = %8.3f, iterations = %d\n', likelihood, iter);

save(hfile, 'hmm', 'likelihood');