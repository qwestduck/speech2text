% function r = frameIsSpeech(frame)
%   Use the zero-crossing and energy features of the frame
%    to determine whether the current frame is a speech sample
%    or a background noise
% @param[in] frame        - the given frame in time
% @param[in] threshold   - the threshold of the cost function, optional
% @param[out] cost        - the cost function result to combine the frame
%                                     energy and zero-crossing rate
% @param[out] r             - true if the current frame is a speech sample
%                                     or false if the current frame is a
%                                     background noise
%
% @author Jianxia Xue
% @version 0.20120229
%
function [cost, r] = frameIsSpeech(frame, threshold)
cost = frameEnergy(frame)*frameZ(frame);
if (nargin > 1)  
    if (cost > threshold)
        r = true;
    else
        r = false;
    end
end
end