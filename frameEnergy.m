% function r = frameZ(frame)
%   compute the total energy of a given frame
% @param[in] frame        - the given frame in time
% @param[out] r             - the resulting frame energy
%
% @author Jianxia Xue
% @version 0.20120229
%
function r = frameEnergy(frame)
r = sum(frame.^2);
end