function labels = getSegmentations(wavData, fs, targetWords)
configData;
[frames, centers] = framing(wavData, fs, winLen, winSpa);

sta.featureType = 'Onset';

[r, labels] = shortTimeAnalysis(frames, centers, sta);
diff = r(:)-[0; r(1:(length(r)-1))];
segments = labels.x(find(diff ~= 0));
labels = reshape(segments, 2, length(segments)/2);
labels = labels';
labels = round(labels / fs * 1000);
labels(:,2) = labels(:,2)-labels(:,1);
labels = trimSegmentation(labels, length(targetWords));
% throw away the extra ones by ranking of duration
labels = [targetWords(:), cell(length(targetWords), 1), num2cell(labels(1:length(targetWords),:))];

end

% trim label data according to the second column of duration
% keep the largest N  durations
function labels = trimSegmentation(labels, len)

if( isempty(labels) ) 
    err = MException('', ...
        'Attempt to trim empty array');
    throw(err);
end
duration = labels(:,2);
[dsorted, sortidx] = sort(duration);

sortidx = flipud(sortidx);
sortidx = sortidx(1:len);
sortidx = sort(sortidx);

labels = labels(sortidx,:);

end

