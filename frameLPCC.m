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