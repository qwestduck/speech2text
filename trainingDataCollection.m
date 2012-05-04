% Copyright (c) 2012, Jianxia Xue, jxue@cs.olemiss.edu
% All rights reserved.
%
% Redistribution and use in source, with or without 
% modification, are permitted provided that the following conditions are 
% met:
%
%   * Redistributions of source code must retain the above copyright 
%     notice, this list of conditions and the following disclaimer.
%   * Redistributions in binary form must reproduce the above copyright 
%     notice, this list of conditions and the following disclaimer in 
%     the documentation and/or other materials provided with the distribution
%      
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

% A GUI for collecting training purpose audio and labeling data
% The script depends on the configData.m file to locate the training data
% folder and vocabulary.
%
% To start each new recording, click the record button.
%    the interface randomly generates a sequence of 2
%    to 5 words from the vocabulary, user utters the words following the order
%    of the stimuli
% When user finishes uttering, click the stop button. The system will
%    automatically detect end points per word
% Click each of the segmentation bar, it will move horizontally following
%    the followup mouse click, the take segmentation table will be updated
% Click play button to listen to the acoustic samples within the
%    segmentations to monitor the segmentation quality
% Click load button to open existing takes in the training folder
% Click save button to store the current active take to a designated take
%
% @author Jianxia Xue
% @version 0.20120410
%
function varargout = trainingDataCollection(varargin)
% TRAININGDATACOLLECTION MATLAB code for trainingDataCollection.fig
%      TRAININGDATACOLLECTION, by itself, creates a new TRAININGDATACOLLECTION or raises the existing
%      singleton*.
%
%      H = TRAININGDATACOLLECTION returns the handle to a new TRAININGDATACOLLECTION or the handle to
%      the existing singleton*.
%
%      TRAININGDATACOLLECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRAININGDATACOLLECTION.M with the given input arguments.
%
%      TRAININGDATACOLLECTION('Property','Value',...) creates a new TRAININGDATACOLLECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trainingDataCollection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trainingDataCollection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trainingDataCollection

% Last Modified by GUIDE v2.5 09-Apr-2012 20:29:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trainingDataCollection_OpeningFcn, ...
                   'gui_OutputFcn',  @trainingDataCollection_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before trainingDataCollection is made visible.
function trainingDataCollection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trainingDataCollection (see VARARGIN)

% Choose default command line output for trainingDataCollection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% initialize audio recorder object
fs = getFs(handles);
r = audiorecorder(fs, 16, 1);
setappdata(handles.recordButton, 'audiorecorder', r);

clearAxes(handles);

% load configuration data
configData;

h=gcf;
setappdata(h, 'activeBar', -1);

setappdata(handles.cache, 'vocabulary', vocabulary);
setappdata(handles.cache, 'trainingFolder', trainingFolder);
setappdata(handles.cache, 'takeName', '');

% update training data statistics
updateTrainingStat( handles);

%%%%%%%%%
% need to check for existance of a default take
takeName = getappdata(handles.cache, 'lastTake');
if (length(takeName) > 0)
    takeName = strrep(takeName, '.wav', '');

    [data, fs, label] = loadActiveTake( '', takeName);
    cacheActiveTake(handles, takeName, data, fs);
    plotActiveTake(takeName, data, fs, label, handles);
end

function updateTrainingStat( handles)
trainingFolder = getappdata(handles.cache, 'trainingFolder');
vocabulary = getappdata(handles.cache, 'vocabulary');
[stat, takes] = takeManager(trainingFolder, vocabulary);
stat = num2cell(stat);
set(handles.trainingDataStat, 'RowName', vocabulary);
set(handles.trainingDataStat, 'Data', stat);
if (size(takes,1)>1)
    lastTake = takes{size(takes,1),1};
    lastTake = lastTake.name;
    lastTake = strrep(lastTake, '.wav', '');
    setappdata(handles.cache, 'lastTake', lastTake);
else
    setappdata(handles.cache, 'lastTake', '');
end

function fs = getFs(handles)
fs = get(handles.fsEdit, 'String');
fs = str2double(fs)*1000;

function maxDuration = getMaxDuration(handles)
maxDuration = get(handles.maxDurationEdit, 'String');
maxDuration = str2double(maxDuration);

% UIWAIT makes trainingDataCollection wait for user response (see UIRESUME)
% uiwait(handles.figure1);
function clearAxes(handles) 
fs = getFs(handles);
maxDur = getMaxDuration(handles);
axesNames = {'timeDomainAxes', 'freqDomainAxes'};
oneTake = zeros(fs*maxDur, 1);
for i=1:length(axesNames)
    eval(['ax = handles.' axesNames{i} ';']);
    cla(ax);
    plot(ax, oneTake);
    hold(ax, 'on');
    line = plot(ax, [1 1], [-1 1], 'r', 'linewidth', 2);
    setappdata(ax, 'line', line);
    set(ax, 'buttondownfcn', @axes_ButtonDownFcn);
end


% --- Executes on mouse press over axes background.
function axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = gcf;
activeBar = getappdata(h, 'activeBar');
if (activeBar > 0)
    id = getappdata(h, 'activeBarId');
    barType = getappdata(h, 'barType');
    pos = get(hObject, 'CurrentPoint');
    xpos = pos(1);
    xData = get(activeBar, 'XData');
    xData = ones(size(xData)) * xpos;
    
    timeDomainBars = getappdata(h, 'timeDomainBars');
    freqDomainBars = getappdata(h, 'freqDomainBars');
    
    set(timeDomainBars(id, barType), 'XData', xData);
    set(freqDomainBars(id, barType), 'XData', xData);
    
    if (barType == 1)
        textPos = get(timeDomainBars(id, 3), 'Position'); 
        textPos(1) = xpos;
        set(timeDomainBars(id, 3), 'Position', textPos);
        set(freqDomainBars(id, 3), 'Position', textPos);
    end
    
    xpos = round(xpos);
    oldLabelData = get(handles.currentLabel, 'Data');
    if (iscell(oldLabelData))
        oldLabelData = cell2mat(oldLabelData);
    end
    newLabelData = oldLabelData;
    if (barType == 1)
        newLabelData(id,1) = xpos;
        newLabelData(id,2) = oldLabelData(id,2)+oldLabelData(id,1)-newLabelData(id,1);
    else
        newLabelData(id,2) = xpos - newLabelData(id,1);
    end
    set(handles.currentLabel, 'Data', newLabelData);
    
    setappdata(h, 'activeBar', -1);
end


% --- Outputs from this function are returned to the command line.
function varargout = trainingDataCollection_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in recordButton.
function recordButton_Callback(hObject, eventdata, handles)
% hObject    handle to recordButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of recordButton
toggleState = get(hObject, 'Value');

if ( toggleState == 1 )
    % start recording  
    vocab = getappdata(handles.cache,  'vocabulary');
    stimuli = getStimuli( vocab );
    set(handles.currentLabel, 'RowName', stimuli);
    set(handles.currentLabel, 'Data', zeros(length(stimuli),2));
    set(hObject, 'String', 'Stop Recording');
    r = getappdata(handles.recordButton, 'audiorecorder');
    record(r);
else
    % stop recording
    set(hObject, 'String', 'Record');
    r = getappdata(handles.recordButton, 'audiorecorder');
    stop(r);
    data = getaudiodata(r, 'double');
    
    fs = r.SampleRate;
    labels = getSegmentations(data, fs, get(handles.currentLabel, 'RowName'));
    
    takeName = [getappdata(handles.cache, 'trainingFolder') '/unsaved'];
    cacheActiveTake(handles, takeName, data, fs);
    plotActiveTake(takeName, data, fs, labels, handles);
    
end

    

function maxDurationEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxDurationEdit as text
%        str2double(get(hObject,'String')) returns contents of maxDurationEdit as a double


% --- Executes during object creation, after setting all properties.
function maxDurationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxDurationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function filters = getTakeFileFilters(handles)
takeName = getappdata(handles.cache, 'takeName');
if (length(takeName)<1)
    takeName = getappdata(handles.cache, 'lastTake');
end
labPat = [takeName '.lab'];
filters =  labPat;



% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadButton
defaultFile = getTakeFileFilters(handles);
[filename, pathname] = uigetfile( defaultFile, ['Load Take default = ' defaultFile]);
if filename == 0
    return;
end

[pathstr, takeName] = fileparts(filename);

[data, fs, label] = loadActiveTake( pathname, takeName );

cacheActiveTake( handles, [pathname '/' takeName], data, fs );

set(handles.takePanel, 'Title', ['Active Take ' takeName]);

plotActiveTake( takeName, data, fs, label, handles);

function cacheActiveTake( handles, takeName, data, fs ) 
setappdata(handles.cache, 'takeName', takeName);
setappdata(handles.cache, 'data', data);
setappdata(handles.cache, 'fs', fs);


function [data, fs, label] = loadActiveTake( pathname, takeName )
if ( ~isempty(pathname) )
    pathname = [pathname '/'];
end
wavfile = [ pathname takeName '.wav']
labfile =  [ pathname takeName '.lab']

[data, fs] = wavread(wavfile);
label = parselab(labfile);

%scaling start and during from time in msec to samples
%timings = cell2mat(label(:, [3 4]));
%timings = timings * fs;
%label(:, [3 4]) = mat2cell(timings, ones(size(label, 1),1), ones(1,2));

function plotActiveTake( takeName, data, fs, label, handles )

ax = handles.timeDomainAxes;
hold(ax, 'off');
x = 1:length(data);
x = x/fs*1000;
plot(ax, x, data);
axis(ax, 'tight');
set(ax, 'buttondownfcn', {@axes_ButtonDownFcn, handles});
if size(label,1)>1
    hold(ax, 'on');
    segHandles = plotSegmentations(ax, label, [min(data), max(data)]);
    h = gcf;
    setappdata(h, 'timeDomainBars', segHandles);

    set(handles.currentLabel, 'RowName', label(:,1));
    set(handles.currentLabel, 'Data', label(:, [3 4]));
end

[features, labels] = getSpectrogram(data, fs);

ax = handles.freqDomainAxes;
cla(ax);
hold(ax, 'off');
yRange = [labels.y(end), labels.y(1)];
labels.x = labels.x / fs *1000;
imagesc([labels.x(1), labels.x(end)], yRange, features, 'parent', ax);
set(ax, 'buttondownfcn', {@axes_ButtonDownFcn, handles});

xlabel(ax, 'time (msec)');
yl = get(ax, 'yticklabel');
set(ax, 'yticklabel', flipud(yl));
set(ax, 'buttondownfcn', @axes_ButtonDownFcn);
if size(label,1)>1
    hold(ax, 'on');    
    segHandles = plotSegmentations(ax, label, yRange);
    h = gcf;
    setappdata(h, 'freqDomainBars', segHandles);
end



function segHandles = plotSegmentations(ax, labels, y) 
style = {'r', 'k'};

segHandles = zeros(size(labels,1), 3);

for i=1:size(labels,1)
    start = labels{i, 3};
    stop = start+labels{i, 4};
    word = labels{i,1};
    
    hstart = plot(ax, [start start], y, style{1}, 'linewidth', 2);
    setappdata(hstart, 'id', i);
    hstop = plot(ax, [stop stop], y, style{2}, 'linewidth', 4);
    setappdata(hstop, 'id', i);
    
    set(hstart, 'ButtonDownFcn',  @startBar_Callback);
    set(hstop, 'ButtonDownFcn',  @stopBar_Callback);
    axis(ax);
    hlabel = text(start, y(2)-150, word, 'fontsize', 16, 'color', 'r', 'fontweight', 'bold');
    
    segHandles(i,:) = [hstart, hstop, hlabel];
end

function startBar_Callback(hObject, eventdata)
h = gcf;
setappdata(h, 'activeBar', hObject);
id = getappdata(hObject, 'id');
setappdata(h, 'activeBarId', id);
setappdata(h, 'barType', 1);

function stopBar_Callback(hObject, eventdata)
h = gcf;
setappdata(h, 'activeBar', hObject);
id = getappdata(hObject, 'id')
setappdata(h, 'activeBarId', id);
setappdata(h, 'barType', 2);

function [r, labels] = getSpectrogram(wavData, fs)
configData;
[frames, centers] = framing(wavData, fs, winLen, winSpa);
sta.fs = fs;
sta.Nfft = Nfft;
sta.window = hamming(winLen);
sta.featureType = 'FFT';
[r, labels] = shortTimeAnalysis(frames, centers, sta);
    
% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of playButton
samples = getappdata(handles.cache, 'data');
fs = getappdata(handles.cache, 'fs');

if (length(samples)<1)
    disp('[windowingDemo] No sound samples to play. Record some speech.');
    return;
end

segments = get(handles.currentLabel, 'Data');
words = get(handles.currentLabel, 'RowName');
if (iscell(segments))
    segments = cell2mat(segments);
end
maxDuration = max(segments(:,2));
segments = round(segments * fs/1000);
segments(:,2) = segments(:,1)+segments(:,2);
label = '';

for i = 1: length(words);
    label = [label ' ' words{i}];
    title(handles.timeDomainAxes, label);
    soundsc(samples(segments(i,1):segments(i,2)), fs);
    pause(maxDuration/1000);
end

% --- Executes during object creation, after setting all properties.
function fsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function takeName = getCurrentTakeName(handles)
takeName = getappdata(handles.cache, 'takeName');

% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveButton

[filename, pathName] = uiputfile( getappdata(handles.cache, 'trainingFolder'), 'Save Take' );
if filename == 0
    return;
end

[pathstr, takeName] = fileparts(filename);

data = getappdata(handles.cache, 'data');
fs = getappdata(handles.cache, 'fs');

% get label data
labelHandle = handles.currentLabel;
labelData = get(labelHandle, 'Data');

if (~iscell(labelData))
    labelData = num2cell(labelData);
end
labelWord = get(labelHandle, 'RowName');
if size(labelData,1) < size(labelWord,1)
    labelData = num2cell(zeros(size(labelWord,1),2));
end

setappdata(handles.cache, 'takeName', [pathName takeName]);

set(handles.takePanel, 'Title', ['Active Take ' takeName]);

label = [labelWord, labelData];

saveActiveTake( pathName, takeName, data, fs, label );

updateTrainingStat( handles);


function saveActiveTake( pathName, takeName, data, fs, label)
wavfile = [pathName takeName '.wav'];
wavwrite(data, fs, 16, wavfile);

labfile = [pathName takeName '.lab'];
fid = fopen(labfile, 'w');
for i=1:size(label, 1)
    fprintf(fid, '%s %.3f %.3f\n', label{i,1}, label{i,2}, label{i,3});
end
fclose(fid);
