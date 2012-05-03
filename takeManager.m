% Collect take statistics including
%  the number of repetitions per vocabulary word
%  and the list of take files
%
% @param[in] folder the folder that holds .wav and .lab files of recorded
% takes
% @param[in] vocab the vocabulary words in a cell array
%
% @return stat a numeric array of two columns: 
%   column 1 the repetition count per vocabulary word
%   column 2 the total duration in milliseconds per vocabulary word
% @return takes a cell array of two columns:
%   column 1 the wav file information in struct
%   column 2 the lab file information in struct
%
% @author Jianxia Xue
% @version 0.20120410

function [stat, takes, sampleList] = takeManager(folder, vocab)
takes = getTakes(folder);
[stat, sampleList] = getTakeStat(takes, vocab);
        
function takes = getTakes(folder)
files = dir([folder '/*.wav'] );
takes = cell(size(files,1),2);
for i=1:length(files)
    wavfile = files(i);
    wavfile.name = [folder '/' wavfile.name];
    takes{i,1} = wavfile;
    lab = strrep(wavfile.name, '.wav', '.lab');
    labfile = dir(lab);    
    if length(labfile) == 1
        labfile.name = [folder '/' labfile.name];
        takes{i,2} = labfile;
    end
end

function [stat, sampleList] = getTakeStat(takes, vocab)
stat = zeros(length(vocab), 2);
sampleList = cell(length(vocab), 1);
% loop over takes
for i=1:size(takes,1)
    labfile = takes{i,2};
    labels = parselab(labfile.name);
    
    % loop over segments within one take
    for j = 1:size(labels,1)
        
        word = labels{j,1};
        duration = labels{j,4};

        for k=1:length(vocab)
            if (strcmp(vocab{k}, word) == 1)
                stat(k,1) = stat(k,1)+1;
                stat(k,2) = stat(k,2)+duration;
                sampleList{k} = [sampleList{k}; labels(j,2:4)];
                break;
            end
        end
    end
end


