function varargout = costMatLinearMotionLink2GUI(varargin)
% COSTMATLINEARMOTIONLINK2GUI M-file for costMatLinearMotionLink2GUI.fig
%      COSTMATLINEARMOTIONLINK2GUI, by itself, creates a new COSTMATLINEARMOTIONLINK2GUI or raises the existing
%      singleton*.
%
%      H = COSTMATLINEARMOTIONLINK2GUI returns the handle to a new COSTMATLINEARMOTIONLINK2GUI or the handle to
%      the existing singleton*.
%
%      COSTMATLINEARMOTIONLINK2GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COSTMATLINEARMOTIONLINK2GUI.M with the given input arguments.
%
%      COSTMATLINEARMOTIONLINK2GUI('Property','Value',...) creates a new COSTMATLINEARMOTIONLINK2GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before costMatLinearMotionLink2GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to costMatLinearMotionLink2GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help costMatLinearMotionLink2GUI

% Last Modified by GUIDE v2.5 08-Dec-2010 17:49:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @costMatLinearMotionLink2GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @costMatLinearMotionLink2GUI_OutputFcn, ...
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


% --- Executes just before costMatLinearMotionLink2GUI is made visible.
function costMatLinearMotionLink2GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% userData.linkingFig = costMatLinearMotionLink2GUI{procID}('mainFig',
% handles.figure1, procID);
%
% userData.mainFig
% userData.procID
% userData.handles_main
% userData.userData_main
% userData.crtProc
% userData.parameters

handles.output = hObject;
set(handles.text_copyright, 'String', userfcn_copyright)
userData = get(handles.figure1, 'UserData');

% Get main figure handle and process id
t = find(strcmp(varargin,'mainFig'));
userData.mainFig = varargin{t+1};
userData.procID = varargin{t+2};
userData.handles_main = guidata(userData.mainFig);
userData.userData_main = get(userData.handles_main.figure1, 'UserData');
userData.crtProc = userData.userData_main.crtProc;

u = get(userData.handles_main.popupmenu_linking, 'UserData');
userData.parameters = u{userData.procID};
parameters = userData.parameters;

% Parameter Setup
set(handles.checkbox_linearMotion, 'Value', parameters.linearMotion)
set(handles.edit_lower, 'String', num2str(parameters.minSearchRadius))
set(handles.edit_upper, 'String', num2str(parameters.maxSearchRadius))
set(handles.edit_brownStdMult, 'String', num2str(parameters.brownStdMult))
set(handles.checkbox_useLocalDensity, 'Value', parameters.useLocalDensity)
set(handles.edit_nnWindow, 'String', num2str(parameters.nnWindow))

if isempty(parameters.diagnostics) || (length(parameters.diagnostics) == 1 && parameters.diagnostics == 0)
    
    set(handles.checkbox_diagnostics, 'Value', 0)
    set(handles.text_diag_1, 'Enable', 'off')
    set(handles.text_diag_2, 'Enable', 'off')
    set(handles.edit_diag_1, 'Enable', 'off')
    set(handles.edit_diag_2, 'Enable', 'off')
    set(handles.edit_diag_3, 'Enable', 'off')
else
    set(handles.checkbox_diagnostics, 'Value', 1)
    l = length(parameters.diagnostics);
    if l>3
       l = 3; 
    end
    for i = 1:l
        eval(['set(handles.edit_diag_',num2str(i),', ''String'', num2str(parameters.diagnostics(i)))'])
    end
end

set(handles.figure1, 'UserData', userData)
% Update handles structure
guidata(hObject, handles);



% UIWAIT makes costMatLinearMotionLink2GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = costMatLinearMotionLink2GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1)


% --- Executes on button press in pushbutton_done.
function pushbutton_done_Callback(hObject, eventdata, handles)

userData = get(handles.figure1, 'UserData');

if userData.crtProc.procChanged_ 
    
    lower = get(handles.edit_lower, 'String');
    upper = get(handles.edit_upper, 'String');
    brownStdMult = get(handles.edit_brownStdMult, 'String');
    nnWindow = get(handles.edit_nnWindow, 'String');
    diagnostics{1} = ( get(handles.edit_diag_1, 'String') );
    diagnostics{2} = ( get(handles.edit_diag_2, 'String') );
    diagnostics{3} = ( get(handles.edit_diag_3, 'String') );  
    
    % lower
    if isempty( lower )
        errordlg('Parameter "Lower Bound" is requied by the algorithm.','Error','modal')
        return

    elseif isnan(str2double(lower)) || str2double(lower) < 0
        errordlg('Please provide a valid value to parameter "Lower Bound".','Error','modal')
        return
    else
        lower = str2double(lower);
    end    
    
    % Upper
    if isempty( upper )
        errordlg('Parameter "Upper Bound" is requied by the algorithm.','Error','modal')
        return

    elseif isnan(str2double(upper)) || str2double(upper) < 0 
        errordlg('Please provide a valid value to parameter "Upper Bound".','Error','modal')
        return
        
    elseif str2double(upper) <= lower
        errordlg('"Upper Bound" should be larger than "Lower Bound".','Error','modal')
        return
        
    else
        upper = str2double(upper);
    end        
    
    % brownStdMult
    if isempty( brownStdMult )
        errordlg('Parameter "Multiplication Factor for Search Radius Calculation" is requied by the algorithm.','Error','modal')
        return

    elseif isnan(str2double(brownStdMult)) || str2double(brownStdMult) < 0
        errordlg('Please provide a valid value to parameter "Multiplication Factor for Search Radius Calculation".','Error','modal')
        return
    else
        brownStdMult = str2double(brownStdMult);
    end  
    
    % nnWindow
    if isempty( nnWindow )
        errordlg('Parameter "Number of Frames for Nearest Neighbor Distance Calculation" is requied by the algorithm.','Error','modal')
        return

    elseif isnan(str2double(nnWindow)) || str2double(nnWindow) < 0
        errordlg('Please provide a valid value to parameter "Number of Frames for Nearest Neighbor Distance Calculation".','Error','modal')
        return
    else
        nnWindow = str2double(nnWindow);
    end    
    
    % diagnostics
    
    if get(handles.checkbox_diagnostics, 'Value')
        
        temp = cellfun(@(x)~isempty(x), diagnostics);
        if all(~temp)
            errordlg('Please provide 1 or more than 1 (maximum 3) "Frame Numbers to Plot Histograms" in the text boxes.','Error','modal')
            return

        elseif any(cellfun(@(x)isnan(str2double(x)), diagnostics(temp))) || ...
                any(cellfun(@(x)(str2double(x)<2 || str2double(x)>userData.crtProc.owner_.nFrames_-1), diagnostics(temp)))
            errordlg('Please provide a valid value to parameter "Frame Numbers to Plot Histograms". Note: the first or last frame of a movie is invalid.','Error','modal')
            return

        else
            diagnostics = cellfun(@(x)str2double(x), diagnostics(temp), 'UniformOutput', true);
        end  
        
    end
    
    
    % Set Parameters
    parameters = userData.parameters;
    
    parameters.linearMotion = get(handles.checkbox_linearMotion, 'Value');
    parameters.minSearchRadius = lower;
    parameters.maxSearchRadius = upper;
    parameters.brownStdMult = brownStdMult;
    parameters.useLocalDensity = get(handles.checkbox_useLocalDensity, 'Value');
    parameters.nnWindow = nnWindow;
    
    if get(handles.checkbox_diagnostics, 'Value')
        
        parameters.diagnostics = diagnostics;
    else
        parameters.diagnostics = []; 
    end
    
    u = get(userData.handles_main.popupmenu_linking, 'UserData');
    u{userData.procID} = parameters;
    
    set(userData.handles_main.popupmenu_linking, 'UserData', u)
    
    % set linearMotion to gap closing cost function "costMatLinearMotionCloseGaps2"
    u_gapclosing = get(userData.handles_main.popupmenu_gapclosing, 'UserData');
    u_gapclosing{strcmp('costMatLinearMotionCloseGaps2', userData.userData_main.cost_gapclosing)}.linearMotion = parameters.linearMotion;
    set(userData.handles_main.popupmenu_gapclosing, 'UserData', u_gapclosing)
    
    
end

set(handles.figure1, 'UserData', userData);
guidata(hObject,handles);
delete(handles.figure1);


% --- Executes on button press in checkbox_linearMotion.
function checkbox_linearMotion_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_linearMotion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_linearMotion
userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);


function edit_lower_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_lower as text
%        str2double(get(hObject,'String')) returns contents of edit_lower as a double
userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);

% --- Executes during object creation, after setting all properties.
function edit_lower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_upper_Callback(hObject, eventdata, handles)
% hObject    handle to edit_upper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_upper as text
%        str2double(get(hObject,'String')) returns contents of edit_upper as a double
userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);

% --- Executes during object creation, after setting all properties.
function edit_upper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_upper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_brownStdMult_Callback(hObject, eventdata, handles)
% hObject    handle to edit_brownStdMult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_brownStdMult as text
%        str2double(get(hObject,'String')) returns contents of edit_brownStdMult as a double
userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);

% --- Executes during object creation, after setting all properties.
function edit_brownStdMult_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_brownStdMult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_useLocalDensity.
function checkbox_useLocalDensity_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_useLocalDensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_useLocalDensity
userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);


function edit_nnWindow_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nnWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nnWindow as text
%        str2double(get(hObject,'String')) returns contents of edit_nnWindow as a double
userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);

% --- Executes during object creation, after setting all properties.
function edit_nnWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nnWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_diag_3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_diag_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_diag_3 as text
%        str2double(get(hObject,'String')) returns contents of edit_diag_3 as a double
userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);

% --- Executes during object creation, after setting all properties.
function edit_diag_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_diag_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_diag_2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_diag_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_diag_2 as text
%        str2double(get(hObject,'String')) returns contents of edit_diag_2 as a double
userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);

% --- Executes during object creation, after setting all properties.
function edit_diag_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_diag_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_diag_1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_diag_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_diag_1 as text
%        str2double(get(hObject,'String')) returns contents of edit_diag_1 as a double
userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);

% --- Executes during object creation, after setting all properties.
function edit_diag_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_diag_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_diagnostics.
function checkbox_diagnostics_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_diagnostics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_diagnostics
if get(hObject, 'Value')
   
    set(handles.text_diag_1, 'Enable', 'on')
    set(handles.text_diag_2, 'Enable', 'on')
    set(handles.edit_diag_1, 'Enable', 'on')
    set(handles.edit_diag_2, 'Enable', 'on')
    set(handles.edit_diag_3, 'Enable', 'on')    
else
    set(handles.text_diag_1, 'Enable', 'off')
    set(handles.text_diag_2, 'Enable', 'off')
    set(handles.edit_diag_1, 'Enable', 'off')
    set(handles.edit_diag_2, 'Enable', 'off')
    set(handles.edit_diag_3, 'Enable', 'off')    
end

userData = get(handles.figure1, 'UserData');
userData.crtProc.setProcChanged(true);


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmp(eventdata.Key, 'return')
    pushbutton_done_Callback(handles.pushbutton_done, [], handles);
end
