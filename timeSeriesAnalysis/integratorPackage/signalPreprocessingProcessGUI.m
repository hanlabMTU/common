function varargout = signalPreprocessingProcessGUI(varargin)
% signalPreprocessingProcessGUI M-file for signalPreprocessingProcessGUI.fig
%      signalPreprocessingProcessGUI, by itself, creates a new signalPreprocessingProcessGUI or raises the existing
%      singleton*.
%
%      H = signalPreprocessingProcessGUI returns the handle to a new signalPreprocessingProcessGUI or the handle to
%      the existing singleton*.
%
%      signalPreprocessingProcessGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in signalPreprocessingProcessGUI.M with the given input arguments.
%
%      signalPreprocessingProcessGUI('Property','Value',...) creates a new signalPreprocessingProcessGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before signalPreprocessingProcessGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to signalPreprocessingProcessGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help signalPreprocessingProcessGUI

% Last Modified by GUIDE v2.5 18-Nov-2011 15:20:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @signalPreprocessingProcessGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @signalPreprocessingProcessGUI_OutputFcn, ...
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


% --- Executes just before signalPreprocessingProcessGUI is made visible.
function signalPreprocessingProcessGUI_OpeningFcn(hObject,eventdata,handles,varargin)

processGUI_OpeningFcn(hObject, eventdata, handles, varargin{:});

userData=get(handles.figure1,'UserData');
funParams = userData.crtProc.funParams_;

% Set up available input channels
set(handles.listbox_availableMovies,'String',userData.MD.movieDataFile_, ...
    'UserData',1:numel(userData.MD.movies_));

movieIndex = funParams.MovieIndex;

if ~isempty(movieIndex)
    movieString = userData.MD.movieDataFile_(movieIndex);
else
    movieString = {};
end

set(handles.listbox_selectedMovies,'String',movieString,...
    'UserData',movieIndex);

% Set up available input processes
allProc = userData.crtProc.getCorrelationProcesses();
allProcString = cellfun(@(x) eval([x '.getName']),allProc,'UniformOutput',false);
set(handles.listbox_availableProcesses,'String',allProcString,'UserData',allProc);

% Set up selected input processes
selProc = funParams.ProcessName;
selProcString = cellfun(@(x) eval([x '.getName']),selProc,'UniformOutput',false);
set(handles.listbox_selectedProcesses,'String',selProcString,'UserData',selProc);

set(handles.edit_kSigma,'String',funParams.kSigma);

% Choose default command line output for signalPreprocessingProcessGUI
handles.output = hObject;

% Update user data and GUI data
set(hObject, 'UserData', userData);
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = signalPreprocessingProcessGUI_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(~, ~, handles)
% Delete figure
delete(handles.figure1);

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, ~, handles)
% Notify the package GUI that the setting panel is closed
userData = get(handles.figure1, 'UserData');

if isfield(userData, 'helpFig') && ishandle(userData.helpFig)
   delete(userData.helpFig) 
end

set(handles.figure1, 'UserData', userData);
guidata(hObject,handles);


% --- Executes on key press with focus on pushbutton_done and none of its controls.
function pushbutton_done_KeyPressFcn(~, eventdata, handles)

if strcmp(eventdata.Key, 'return')
    pushbutton_done_Callback(handles.pushbutton_done, [], handles);
end

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(~, eventdata, handles)

if strcmp(eventdata.Key, 'return')
    pushbutton_done_Callback(handles.pushbutton_done, [], handles);
end

% --- Executes on button press in checkbox_allMovies.
function checkbox_all_Callback(hObject, eventdata, handles)

% Identify listbox and retrieve handles
tokens = regexp(get(hObject,'Tag'),'^checkbox_all(.*)$','tokens');
listbox_available= handles.(['listbox_available' tokens{1}{1}]);
listbox_selected= handles.(['listbox_selected' tokens{1}{1}]);

% Retrieve available properties
availableProps = get(listbox_available, {'String','UserData'});
if isempty(availableProps{1}), return; end

if get(hObject,'Value')
    set(listbox_selected, 'String', availableProps{1},'UserData',availableProps{2});
else
    set(listbox_selected, 'String', {}, 'UserData',[], 'Value',1);
end

% --- Executes on button press in pushbutton_selectMovies.
function pushbutton_select_Callback(hObject, eventdata, handles)

% Identify listbox and retrieve handles
tokens = regexp(get(hObject,'Tag'),'^pushbutton_select(.*)$','tokens');
listbox_available= handles.(['listbox_available' tokens{1}{1}]);
listbox_selected= handles.(['listbox_selected' tokens{1}{1}]);

% Get handles properties
availableProps = get(listbox_available, {'String','UserData'});
selectedProps = get(listbox_selected, {'String','UserData'});
ID = get(listbox_available, 'Value');

% Update selected listbox properties
newChanID = ID(~ismember(availableProps{1}(ID),selectedProps{1}));
selectedString = horzcat(selectedProps{1},availableProps{1}(newChanID)');
selectedData = horzcat(selectedProps{2}, availableProps{2}(newChanID)');

set(listbox_selected, 'String', selectedString, 'Userdata', selectedData);


% --- Executes on button press in pushbutton_deleteMovies.
function pushbutton_delete_Callback(hObject, eventdata, handles)

% Identify listbox and retrieve handles
tokens = regexp(get(hObject,'Tag'),'^pushbutton_delete(.*)$','tokens');
listbox_selected= handles.(['listbox_selected' tokens{1}{1}]);

% Get selected properties and returin if empty
selectedProps = get(listbox_selected, {'String','UserData','Value'});
if isempty(selectedProps{1}) || isempty(selectedProps{3}),return; end

% Delete selected item
selectedProps{1}(selectedProps{3}) = [ ];
selectedProps{2}(selectedProps{3}) = [ ];
set(listbox_selected, 'String', selectedProps{1},'UserData',selectedProps{2},...
    'Value',max(1,min(selectedProps{3},numel(selectedProps{1}))));


% --- Executes on button press in pushbutton_done.
function pushbutton_done_Callback(hObject, eventdata, handles)

% Check user input
if isempty(get(handles.listbox_selectedMovies, 'String'))
    errordlg('Please select at least one input process from ''Available Movies''.','Setting Error','modal')
    return;
end

if isempty(get(handles.listbox_selectedProcesses, 'String'))
    errordlg('Please select at least one input process from ''Available Processes''.','Setting Error','modal')
    return;
end


funParams.MovieIndex = get(handles.listbox_selectedMovies, 'UserData');
funParams.ProcessName = get(handles.listbox_selectedProcesses,'UserData');

kSigma = str2double(get(handles.edit_kSigma,'String'));
if isnan(kSigma) || ~ismember(kSigma,1:10)
    errordlg('Please enter a valid value for the cutoff for detecting outliers',...
        'Setting error','modal');
    return;
end
funParams.kSigma = kSigma;

% Process Sanity check ( only check underlying data )
userData = get(handles.figure1, 'UserData');
try
    userData.crtProc.sanityCheck;
catch ME

    errordlg([ME.message 'Please double check your data.'],...
                'Setting Error','modal');
    return;
end

% Set parameters
processGUI_ApplyFcn(hObject, eventdata, handles,funParams);
