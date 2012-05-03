% parsing the lab file 
%
% @param[in] labfile the label file name
%
% @return label a cell array of 4 columns
%   column 1: the word 
%   column 2: the take location, useful for take statistic
%   column 3: the word starting time in milliseconds
%   column 4: the word during time in milliseconds
%
% @author Jianxia Xue
% @version 0.20120410
%
function label = parselab(labfile)
[word, startTime, duration] = textread(labfile, '%s%f%f%*[^\n]');
take = strrep(labfile, '.lab', '');

N = length(word);
label = cell(N,4);
label(:,1) = word;
label(:,2) = {take};
label(:,3) = mat2cell(startTime, ones(N,1), 1);
label(:,4) = mat2cell(duration, ones(N,1), 1);
