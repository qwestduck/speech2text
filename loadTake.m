function [fs, wav, label] = loadTake(wavfile, labfile)
[wav, fs] = wavread(wavfile);
label = parselab(labfile);

