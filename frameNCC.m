% function [r, lagIndex] = frameNCC(frame)
%   compute the normalized cross-correlation feature
%     of a given frame
% @param[in] frame        - the given frame in time
% @param[out] r             - the resulting NCC in half length as the input frame
% @param[out] lagIndex  - the resulting NCC lag indexes, starting from 0
%
% @author Jianxia Xue
% @version 0.20120229
%
function [r, lagIndex] = frameNCC(frame)
frame=frame(:);

M = ceil(length(frame)/2);
lagIndex = 0:(M-1);

r = zeros(M,1);
for i=lagIndex
    a = frame(1+lagIndex);
    b = frame(i+1+lagIndex);
    r(1+i) = a'*b / sqrt(a'*a * (b'*b));
end