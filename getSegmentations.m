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

function labels = getSegmentations(wavData, fs, targetWords)
configData;
[frames, centers] = framing(wavData, fs, winLen, winSpa);

sta.featureType = 'Onset';

[r, labels] = shortTimeAnalysis(frames, centers, sta);
diff = r(:)-[0; r(1:(length(r)-1))];
segments = labels.x(find(diff ~= 0));
labels = reshape(segments, 2, length(segments)/2);
labels = labels';
labels = round(labels / fs * 1000);
labels(:,2) = labels(:,2)-labels(:,1);
labels = trimSegmentation(labels, length(targetWords));
if( ~isempty(labels) )
  % throw away the extra ones by ranking of duration
  labels = [targetWords(:), cell(length(targetWords), 1), num2cell(labels(1:length(targetWords),:))];
end
end

% trim label data according to the second column of duration
% keep the largest N  durations
function labels = trimSegmentation(labels, len)

if( isempty(labels) ) 
    % err = MException('', ...
    %    'Attempt to trim empty array');
    % throw(err);
else
   duration = labels(:,2);
   [dsorted, sortidx] = sort(duration);

   sortidx = flipud(sortidx);
   sortidx = sortidx(1:len);
   sortidx = sort(sortidx);

   labels = labels(sortidx,:);
end
end

