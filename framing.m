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
