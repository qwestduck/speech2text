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

% Collect take statistics including
% the number of repetitions per vocabulary word
% and the list of take files
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


