% function [a, h] = frameLPC(frame, p, N)
%   compute the LPC coefficients and the corresponding
%   frequency spectrum with a fixed 
% @param[in] frame - the given frame in time
% @param[in] p        - the number of LPC coeffecients
% @param[in] N        - the number of frequency samples
%                               of the frequency response of LPC
%                               default = 512
% @param[out] a       - the resulting LPC coeffecients
% @param[out] h       - the resulting LPC frequency response in dB
%
% @author Jianxia Xue
% @version 0.20120229

function [a, h] = frameLPC(frame, p, N)
a = lpc(frame, p);
if (nargin < 3)
    N = 512;
end
h = 20*log10(abs(freqz(1, a, N)));
end