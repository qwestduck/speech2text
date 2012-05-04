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

% function [a, h] = frameLPCC(frame, p, N)
%   compute the LPC coefficients and the corresponding
%   frequency spectrum with a fixed 
% @param[in] frame - the given frame in time
% @param[in] N        - the number of LPCC coefficents
% @param[in] p        - the number of LPC coeffecients, 
%                               default value is 14
% @param[out] result - the resulting LPCC coeffecients
% @param[out] a       - the resulting LPC coeffecients
% @param[out] h       - the resulting LPC frequency response in dB
%
% @author Jianxia Xue
% @version 0.20120229

function [result, a, h] = frameLPCC(frame, N, p)
if (nargin<3)
    p = 14;
end
[a, h] = frameLPC(frame, p);
a = a(:);
G = sum(frame.*frame);

result = zeros(N,1);
result(1) = G;
for i=2:N
    idx = max(1,i-p) : (i-1);
    f = frame(idx) .* idx(:)/i;    
    
    aidx = idx - idx(1) + 1;
    result(i) = sum(f.*a(flipud(aidx)));
    if (i<p)
        result(i) = result(i)+a(i+1);
    end
end
    
end
