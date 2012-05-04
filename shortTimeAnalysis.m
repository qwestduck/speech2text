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

% Short time analysis of speech frames
% @param[in] frames  the windowed speech samples, one frame per row
% @param[in] centers the center sample index in the original wav file
% @param[in] param extra parameters for specifies the analysis
% @return r the resulting feature vector or matrix
% @return labels the per frame label value, and per feature dimension label
% value if r is two-dimensional
% @author Jianxia Xue
% @version 0.20120208
function [r, labels] = shortTimeAnalysis(frames, centers, param)
r = 0;
labels = struct;
nFrames = size(frames,2);
switch (upper(param.featureType))
    case 'ENERGY' % Energy
        r = zeros(nFrames,1);
        for i=1:nFrames
            r(i) = frameEnergy(frames(:,i));
        end
        labels.x = centers;
        return
    case 'Z' % zero-crossing rate
        r = zeros(nFrames,1);
        for i=1:nFrames
            r(i) = frameZ(frames(:,i));
        end
        labels.x = centers;
        return
    case 'ONSET' % onset
        r = zeros(nFrames,1);
        for i=1:nFrames
            r(i) = frameIsSpeech(frames(:,i));
        end
        silence = r(1:min(20, length(r)/5));
        threshold = mean(silence)+10*std(silence);
        r = r > threshold;
        labels.x = centers;
        return
    case 'NCC' % NCC
        r = zeros(ceil(param.winLen/2), nFrames);
        for i=1:nFrames
            r(:,i) = frameNCC(frames(:,i));
        end
        labels.x = centers;
        labels.y = 0:(size(r,1)-1);
        return;
    case 'FFT' % FFT
        half = floor(param.Nfft/2);
        r = zeros(half, nFrames);
        win = param.window;
        for i=1:nFrames
            f = fft(frames(:,i).*win, param.Nfft);
            r(:,i) = abs(f(1:half) );
        end
        r = log(r);
        labels.x = centers;
        labels.y = linspace(0, (param.fs/2), size(r,1));
        return;
    case 'LPC' % LPC
        p = param.p;
        half = floor(param.Nfft/2);
        r = zeros(half, nFrames);
        for i=1:nFrames
            a = lpc(frames(:,i), p);
            h = freqz(1, a, half);
            r(:,i) = abs(h);
        end
        r = log(r);
        labels.x = centers;
        labels.y = linspace(0, (param.fs/2), size(r,1));
        return
    case 'LPCC' % LPCC
        p = param.p;
        M = param.M;
        r = zeros(M, nFrames);
        for i=1:nFrames
            c = frameLPCC(frames(:, i), M, p);
            r(:, i) = c(:);
        end
        labels.x = centers;
        labels.y = 1:M;
        return
    case 'MFCC' % MFCC
        M = param.M;
        fs = param.fs;
        Nfft = param.Nfft;
        win = param.window;
        r = zeros(M, nFrames);
        for i=1:nFrames
            c = frameMFCC(frames(:, i).*win, fs, Nfft, M);
            r(:, i) = c(:);
        end
        labels.x = centers;
        labels.y = 1:M;
        return
    case 'CEPSTRUM' % Cepstrum
        r = zeros(size(frames,1), nFrames);
        for i=1:nFrames
            c = cceps(frames(:, i));
            r(:, i) = log(abs(c(:)));
        end
        labels.x = centers;
        labels.y = 1:size(frames,1);
        return
    otherwise
        warning(['The feature ' param.featureType ' is not supported']);
end
        
