% function r = frameZ(frame)
%   compute the zero-crossing rate of a given frame
% @param[in] frame        - the given frame in time
% @param[out] r             - the resulting zero-crossing rate
%
% @author Jianxia Xue
% @version 0.20120229
%
function r = frameZ(frame)
signs = sign(frame);
winLen = length(frame);
r = sum(abs(signs(2:winLen)-signs(1:(winLen-1))))/winLen;
