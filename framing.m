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

% function [frames, centers] = framing(data, winSpa)
%   Converts a vector of data samples into a 2D short time frames
%     with each column represents a frame
% data:       speech samples
% winSpa:   number of samples between adjacent windows
%
% @author Jianxia Xue
% @version 0.20120208
%
function [frames, centers] = framing(data, fs, winLen, winSpa)

nSamples = length(data);
nWindows = floor( nSamples / winSpa);

frames = zeros(winLen, nWindows);
centers = zeros(nWindows, 1);

for i=1:nWindows
    start = (i-1)*winSpa+1;
    stop = start+winLen-1;
    frame = zeros(winLen,1);
    if ( stop > nSamples)
        frame(1:(nSamples+1-start)) = data(start:nSamples);
    else
        frame = data(start: stop );
    end 
    frames(:,i) = frame;
    centers(i) = (start+stop)/2;
end

function r = normalizeSpectrum(spectrum)
mi = min(spectrum(:));
ma = max(spectrum(:));
if ((ma-mi)<0.000001)
    r = spectrum-mi;
else
    r = (spectrum-mi) / (ma-mi);
end
