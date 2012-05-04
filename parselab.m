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

% parsing the lab file 
%
% @param[in] labfile the label file name
%
% @return label a cell array of 4 columns
%   column 1: the word 
%   column 2: the take location, useful for take statistic
%   column 3: the word starting time in milliseconds
%   column 4: the word during time in milliseconds
%
% @author Jianxia Xue
% @version 0.20120410
%
function label = parselab(labfile)
[word, startTime, duration] = textread(labfile, '%s%f%f%*[^\n]');
take = strrep(labfile, '.lab', '');

N = length(word);
label = cell(N,4);
label(:,1) = word;
label(:,2) = {take};
label(:,3) = mat2cell(startTime, ones(N,1), 1);
label(:,4) = mat2cell(duration, ones(N,1), 1);
