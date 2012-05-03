% function [result, fbanks, f] = frameMFCC(frame, M)
%   compute the MFCC coefficients and the corresponding
%   filtered frequency spectrum 
% @param[in] frame - the given frame in time
% @param[in] fs       - the sample frequency of the given frame
% @param[in] Nfft    - the number frequency samples in FFT
% @param[in] M        - the number of MFCC coefficents, 
%                                default value is 13
% @param[out] result  - the resulting MFCC coeffecients
% @param[out] fbanks - the Mel-frequency filter banks
% @param[out] f          - the filtered frequency spectrum in dB
%
% @author Jianxia Xue
% @version 0.20120229

function [result, fbanks, f] = frameMFCC(frame, fs, Nfft, M)
if (nargin<4)
    M = 13;
end

fbanks = mfcc_filterbank(M, fs, Nfft);
fftmag = abs(fft(frame, Nfft));

f = zeros(M,1);
for i=1:M
    k = fbanks{i,1};
    h = fbanks{i,2};
    f(i) = (sum(fftmag(k) .* h(:)));
end

f = log(f);

result = abs(ifft(f, M));
end

function filterbank = mfcc_filterbank(M, fs, Nfft)
% compute the filterbank for mfcc computation
% @param M - the number of filters in the filterbank
% @param fs - the sample rate of the speech samples
% @param Nfft - the number of frequency samples in FFT
% 
b = getMFCCboundaries( M, fs, Nfft );
filterbank = cell(M, 2);
for i=1:M
    [k, h] = getTriangleWindow(i, b);
    filterbank(i,1) = {k};
    filterbank(i,2) = {h};
end
end

function [k, h] = getTriangleWindow( m, b )
k1 = b(m):b(m+1);
k2 = (b(m+1)+1):b(m+2);

g1 = 2 / ((b(m+2)-b(m))*(b(m+1)-b(m)));
g2 = 2 / ((b(m+2)-b(m))*(b(m+2)-b(m+1)));

h1 = g1 * (k1-b(m));
h2 = g2 *(b(m+2)-k2);

k = [k1, k2];
h = [h1, h2];
end

function result = getMFCCboundaries( M, fs, Nfft )
m = 0:(M+1);

fboundaries = [20, fs/2];
mel_boundaries = 2410 * log10(fboundaries/1600+1);

mel_scale = mel_boundaries(1) + m * (mel_boundaries(2)-mel_boundaries(1))/(M+1);

mel_frequencies = (10.^(mel_scale/2410)-1)*1600;

result = round(mel_frequencies * Nfft / fs);
if (result(1) == 0)
    result(1) = 1;
end
end