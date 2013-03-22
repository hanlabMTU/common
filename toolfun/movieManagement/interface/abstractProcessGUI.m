function varargout = abstractProcessGUI(varargin)
%ABSTRACTPROCESSGUI M-file for abstractProcessGUI.fig
%      ABSTRACTPROCESSGUI, by itself, creates a new ABSTRACTPROCESSGUI or raises the existing
%      singleton*.
%
%      H = ABSTRACTPROCESSGUI returns the handle to a new ABSTRACTPROCESSGUI or the handle to
%      the existing singleton*.
%
%      ABSTRACTPROCESSGUI('Property','Value',...) creates a new ABSTRACTPROCESSGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to abstractProcessGUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      ABSTRACTPROCESSGUI('CALLBACK') and ABSTRACTPROCESSGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in ABSTRACTPROCESSGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help abstractProcessGUI

% Last Modified by GUIDE v2.5 09-Jul-2012 10:49:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @abstractProcessGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @abstractProcessGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before abstractProcessGUI is made visible.
function abstractProcessGUI_OpeningFcn(hObject, eventdata, handles, varargin)

processGUI_OpeningFcn(hObject, eventdata, handles, varargin{:})

% Get current package and process
userData = get(handles.figure1, 'UserData');

procName = eval([userData.crtProcClassName '.getName()']); 
set(handles.uipanel_methods, 'Title', [procName ' methods']);
set(handles.text_methods, 'String', ['Choose a ' lower(procName) ' method']);


% Get current process constructer, set-up GUIs and mask refinement process
% constructor
userData.subProcClassNames = eval([userData.crtProcClassName '.getConcreteClasses()']);
isGraphicalProcess = @(x) Process.isProcess(x) && Process.hasGUI(x);
validClasses = cellfun(isGraphicalProcess, userData.subProcClassNames);
userData.subProcClassNames = userData.subProcClassNames(validClasses);
userData.subProcConstr = cellfun(@(x) str2func(x),userData.subProcClassNames,'Unif',0);
userData.subProcGUI = cellfun(@(x) eval([x '.GUI']),userData.subProcClassNames,'Unif',0);
subProcNames = cellfun(@(x) eval([x '.getName']),userData.subProcClassNames,'Unif',0);
popupMenuProcName = vertcat(subProcNames,{['Choose a ' lower(procName) ' method']});

% Set up input channel list box
if isempty(userData.crtProc)
    value = numel(userData.subProcClassNames)+1;
    set(handles.pushbutton_set, 'Enable', 'off');
else
    value = find(strcmp(userData.crtProc.getName,subProcNames));
end

existSubProc = @(proc) any(cellfun(@(x) isa(x,proc),userData.MD.processes_));
for i=find(cellfun(existSubProc,userData.subProcClassNames'))
  popupMenuProcName{i} = ['<html><b>' popupMenuProcName{i} '</b></html>'];
end

set(handles.popupmenu_methods, 'String', popupMenuProcName,...
    'Value',value)

% Choose default command line output for abstractProcessGUI
handles.output = hObject;

% Update user data and GUI data
set(hObject, 'UserData', userData);
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = abstractProcessGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% Delete figure
delete(handles.figure1);


% --- Executes on selection change in popupmenu_methods.
function popupmenu_methods_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_methods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_methods contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_methods
content = get(hObject, 'string');
if get(hObject, 'Value') == length(content)
    set(handles.pushbutton_set, 'Enable', 'off')
else
    set(handles.pushbutton_set, 'Enable', 'on')
end

% --- Executes on button press in pushbutton_set.
function pushbutton_set_Callback(hObject, eventdata, handles)

userData = get(handles.figure1, 'UserData');
segProcID = get(handles.popupmenu_methods, 'Value');
subProcGUI =userData.subProcGUI{segProcID};
subProcGUI('mainFig',userData.mainFig,userData.procID,...
    'procConstr',userData.subProcConstr{segProcID},...
    'procClassName',userData.subProcClassNames{segProcID});
delete(handles.figure1);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
userData = get(handles.figure1, 'UserData');

delete(userData.helpFig(ishandle(userData.helpFig))); 

set(handles.figure1, 'UserData', userData);
guidata(hObject,handles);
