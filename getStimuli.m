%randomly produce word or word combinations from
% a vocabulary
% @param[in] vocab the vocabulary words in cell array
% @return stimuli the randomly generated stimuli words in cell array
% @author Jianxia Xue
% @version 0.20120410

function stimuli = getStimuli(vocab)
% produce 2 to 5 words 
l = randi(4)+1;

N = length(vocab);

stimuli = cell(l, 1);
for i=1:l
    idx = randi(N);
    stimuli(i) = vocab(idx);
end
