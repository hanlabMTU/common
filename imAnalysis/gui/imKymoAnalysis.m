function varargout = imKymoAnalysis(varargin)
%imKymoAnalysis : This is the GUI interface to 'imKymograph'. 
%                 See help imKymograph.

% Fields of 'handles' that contain user input data through the gui.
%    numImages     : The number of images to be analyzed.
%    imgFileList   : A cell array of the list of image files to be analyzed.
%    whatIsShown   : A string that indicates what is shown in the figure
%                    window. Possible values: 'image' (default) and 'kymo'.
%    selImgObj     : Specify whether it is the kymograph curve, the single
%                    flow tracking point or the field of flow tracking that 
%                    has been selected by mouse clicking on the mark point.
%                    Possible values: 'kymoCurve', 'FTrackPt' and
%                    'FTrackField'. 
%    numKymoCurves : The number of curves or lines where the kymograph analysis
%                    is performed.
%    kymoX 
%    kymoY         : A cell array each element of which is a numerical array
%                    that defines the x (or y) coordinates of a list of
%                    interpolation points on one curve or line. The length of x
%                    and y must be the same. And, if the length is 2, it defines
%                    the line between the two points.
%    xBand 
%    yBand         : A cell array each element of which is the band along
%                    (kymoX,kymoY) returned by 'imKymograph'.
%    kCurveMP      : The point we use to mark each kymo curve. It is the 
%                    left-most point of the curve.
%    width         : A cell array each element of which is the width of the
%                    tube around each curve (or line) for kymograph analysis.
%                    It has to be an odd number. If the input is even, it is
%                    added by 1.
%    selKymoCurve  : The index of the selected curve whose kymograph is to be
%                    shown and analyzed.
%    kymo          : A cell array of length 'numKymoCurves'. It stores the 
%                    kymograph images.
%    vLineX 
%    vLineY        : Coordinates of the lines drawn on the kymograph
%                    to estimate the speed of the flow along the line.
%    numVLines     : The number of lines drawn on the kymograph
%                    for the estimation of speed.
%    selVLine      : The selected line drawn on the kymograph.
%    manSpeed      : A cell array of length 'numKymoCurves' that contains the
%                    manually tracked speed of flow along the line drawn on 
%                    the image. Each element of the cell array is a vector of
%                    length 'numVLines'.
%    calSpeed      : A vector of length 'numKymoCurves' that contains the
%                    calculated speed of flow along the line drawn on the
%                    image.
%    numFTrackPts  : The number of points where the flow velocity is 
%                    calculated.
%    selFTrackP    : The index of the selected point where the flow velocity 
%                    is calculated and shown.
%    flowV         : A 2D numerical array of size, 'numFTrackPts-by-4'. It
%                    contains the velocity of the flow at each point. Each row
%                    has the format [y0 x0 y1 x1] where [y0 x0] is
%                    y,x-coordinates of the base of the velocity vector
%                    and [y1 x1] is the end of the vector.
%    defKymFTLen   : The default length of the kymograph line drawn through a
%                    point where the flow velocity is to be calculated.
%    defKymFTWidth : The default width of the kymograph line drawn through a
%                    point where the flow velocity is to be calculated.
%    numFields     : Number of flow tracking fields.
%    selField      : The selected field for display.
%    defGridDx
%    defGridDy     : The default grid size in x and y direction.
%    field         : A structure by itself that boundles flow field related
%                    data. It contains the following fields.
%      selObj    : The selected object (point type) in the current displayed 
%                  field. Allowed types: 'grid', 'speckle' or 'initFlow'. 
%      MP        : The mark point of the field. It is the point with the
%                  smallest x and y coordinates (upper-left).
%      bndX
%      bndY      : x and y-coordinates of the field boundary. 
%      gridDx
%      gridDy    : The grid size in x and y direction.
%      gridPts
%      speckles
%      initFlow  : For each field, we can add grid points (fieldGridPts), 
%                    speckles (fieldSpeckles) and initial flow field
%                    (fieldInitFlow).
%
% IMKYMOANALYSIS M-file for imKymoAnalysis.fig
%      IMKYMOANALYSIS, by itself, creates a new IMKYMOANALYSIS or raises the existing
%      singleton*.
%
%      H = IMKYMOANALYSIS returns the handle to a new IMKYMOANALYSIS or the handle to
%      the existing singleton*.
%
%      IMKYMOANALYSIS('Property','Value',...) creates a new IMKYMOANALYSIS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to imKymoAnalysis_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IMKYMOANALYSIS('CALLBACK') and IMKYMOANALYSIS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IMKYMOANALYSIS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imKymoAnalysis

% Last Modified by GUIDE v2.5 02-Apr-2004 15:59:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imKymoAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @imKymoAnalysis_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before imKymoAnalysis is made visible.
function imKymoAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for imKymoAnalysis
handles.output = hObject;

%Initialization
handles.numImages     = 0;
handles.startImage    = 1;
handles.endImage      = 0;
handles.imgFileList   = {};
handles.whatIsShown   = [];
handles.selImgObj   = '';

% GUI data for Kymograph lines or curves.
handles.numKymoCurves = 0;
handles.kymo          = {};
handles.kymAxesP      = [];
handles.kymoX         = {};
handles.kymoY         = {};
handles.xBand         = {};
handles.yBand         = {};
handles.kCurveMP      = [];
handles.width         = [];
handles.selKymoCurve  = 0;
handles.currentWidth  = 5;

% GUI data for kymograph
handles.numVLines     = 0;
handles.vLineX        = {};
handles.vLineY        = {};
handles.vLineMP       = [];
handles.selVLine      = 0;
handles.manSpeed      = [];
handles.calSpeed      = [];

% GUI data for single point flow tracking.
handles.numFTrackPts  = 0;
handles.selFTrackP    = 0;
handles.flowV         = [];
handles.flowVScale    = 1;
handles.defKymFTLen   = 30;
handles.defKymFTWidth = 5;
handles.kymFTLen      = [];
handles.kymFTWidth    = [];
handles.FTkymo        = {};
handles.FTkymAxesP    = [];
handles.FTkymoX       = [];
handles.FTkymoY       = [];
handles.FTxBand       = {};
handles.FTyBand       = {};
handles.FTvLineX      = {};
handles.FTvLineY      = {};
handles.FTvLineMP     = [];
handles.FTselVLine    = 0;
handles.FTmanSpeed    = [];
handles.FTcalSpeed    = [];

% GUI data for field flow tracking.
handles.numFields      = 0;
handles.selField       = 0;
handles.defGridDx      = 20;
handles.defGridDy      = 20;
handles.field          = {};

%Get the handles to some GUI objects.
handles.figH       = gcf;
handles.numImgsH   = findobj('tag','numImages');
handles.startImgH  = findobj('tag','startImage');
handles.endImgH    = findobj('tag','endImage');
handles.curWidthFH  = findobj('tag','currentWidth');
handles.manSpeedFH = findobj('tag','manSpeedF');
handles.calSpeedFH = findobj('tag','calSpeedF');
handles.flowVFH    = findobj('tag','velocityField');
set(handles.curWidthFH,'string',num2str(handles.currentWidth));

%Caculate axes postion of the image.
axesWin = findobj('tag','axesWin');
handles.imgAxesP  = get(axesWin,'Position');

%The text message of the location of the pointer.
handles.pLocText = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imKymoAnalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imKymoAnalysis_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in selectImages.
function selectImages_Callback(hObject, eventdata, handles)
% hObject    handle to selectImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[firstImgFileName pathName filterIndex] = uigetfile({'*.tif;*.gif;*.jpg', ...
   'Image Files (*.tif,*.gif,*.jpg)';
   '*.tif','TIFF files (*.tif)';
   '*.gif','GIF files (*.gif)';
   '*.jpg','JPEG files (*.jpg)'},'Select the first image');

if filterIndex == 0
   return;
end

imgFileList = getFileStackNames([pathName firstImgFileName]);

handles.numImages  = length(imgFileList);
handles.startImage = 1;
handles.endImage   = handles.numImages;

%Display the first image
image = imread(imgFileList{1});
imshow(image,[]);
set(gca(handles.figH),'Units','pixels','Position',handles.imgAxesP);

handles.imgFileList = imgFileList;
handles.image       = image;
handles.imgWidth    = size(image,2);
handles.imgHeight   = size(image,1);

%numImages   = inputdlg('Number of images:','Enter Number of Images', ...
%   1,{num2str(length(imgFileList))});
%numImages   = str2num(numImages{1});

%Whenever new images are selected, clear the previous selected curves.
handles.numKymoCurves = 0;
handles.kymoX         = {};
handles.kymoY         = {};
handles.xBand         = {};
handles.yBand         = {};
handles.kCurveMP      = [];
handles.width         = [];
handles.selKymoCurve  = 0;
handles.selImgObj     = '';
handles.whatIsShown   = 'image';
handles.numVLines     = 0;
handles.kymo          = {};
handles.kymAxesP      = [];
handles.vLineX        = {};
handles.vLineY        = {};
handles.vLineMP       = [];
handles.selVLine      = 0;
handles.manSpeed      = [];
handles.calSpeed      = [];
handles.numFTrackPts  = 0;
handles.selFTrackP    = 0;
handles.flowV         = [];
handles.flowVScale    = 1;
handles.defKymFTLen   = 30;
handles.defKymFTWidth = 5;
handles.kymFTLen      = [];
handles.kymFTWidth    = [];
handles.FTkymo        = {};
handles.FTkymAxesP    = [];
handles.FTkymoX       = [];
handles.FTkymoY       = [];
handles.FTxBand       = {};
handles.FTyBand       = {};
handles.FTvLineX      = {};
handles.FTvLineY      = {};
handles.FTvLineMP     = [];
handles.FTselVLine    = 0;
handles.FTmanSpeed    = [];
handles.FTcalSpeed    = [];

% GUI data for field flow tracking.
handles.numFields = 0;
handles.selField  = 0;
handles.field     = {};

set(handles.startImgH,'enable','on','string',num2str(handles.startImage));
set(handles.endImgH,'enable','on','string',num2str(handles.endImage));
set(handles.numImgsH,'string',num2str(handles.numImages+1));

%Display the first image
redrawAllImg(handles);
guidata(hObject,handles);

% --- Executes on button press in lineDialog.
function lineDialog_Callback(hObject, eventdata, handles)
% hObject    handle to lineDialog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.whatIsShown,'image') == 0 | handles.numImages == 0
   %When what is shown in the figure window is not the image or when no image
   % is input yet.
   return;
end

%ans = inputdlg({'Enter the x-coordinates:','Enter the y-coordinates:', ...
%   'Enter the width:'}, 'New Line',1,{'' '' num2str(handles.defaultWidth)});
ans = inputdlg({'Enter the x-coordinates:','Enter the y-coordinates:'}, ...
   'New Line',1,{'' ''});

numKymoCurves = handles.numKymoCurves+1;

x = str2num(ans{1});
y = str2num(ans{2});
w = str2num(ans{3});

if mod(w,2) == 0
   w = w+1;
end

%Find the mark point which is the left-most end of the line.
if x(end) > x(1)
   kCurveMP = [x(1) y(1)];
else
   kCurveMP = [x(end) y(end)];
end

%Update GUI data.
handles.kymoX{numKymoCurves}      = x;
handles.kymoY{numKymoCurves}      = y;
handles.width(numKymoCurves)      = w;
handles.kCurveMP(numKymoCurves,:) = kCurveMP;
handles.numKymoCurves             = numKymoCurves;
handles.selKymoCurve              = numKymoCurves;
handles.selImgObj               = 'kymoCurve';

handles.numVLines(numKymoCurves)  = 0;
handles.kymo{numKymoCurves}       = [];
handles.xBand{numKymoCurves}      = [];
handles.yBand{numKymoCurves}      = [];
handles.kymAxesP(numKymoCurves,:) = zeros(1,4);
handles.vLineX{numKymoCurves}     = {};
handles.vLineY{numKymoCurves}     = {};
handles.vLineMP{numKymoCurves}    = [];
handles.selVLine(numKymoCurves)   = 0;
handles.manSpeed{numKymoCurves}   = [];
handles.calSpeed(numKymoCurves)   = Inf;

redrawAllImg(handles);
guidata(hObject,handles);

% --- Executes on button press in lineDraw.
function lineDraw_Callback(hObject, eventdata, handles)
% hObject    handle to lineDraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.whatIsShown,'image') == 0 | handles.numImages == 0
   %When what is shown in the figure window is not the image or when no image
   % is input yet.
   return;
end

[x,y] = imSelCurve;

numKymoCurves = handles.numKymoCurves+1;

%ans = inputdlg({'Enter the width:'}, ...
%   'New Line Width',1,{num2str(handles.defaultWidth)});
%w = str2num(ans{1});
%if mod(w,2) == 0
%   w = w+1;
%end

%Find the mark point which is the left-most end of the line.
if x(end) > x(1)
   kCurveMP = [x(1) y(1)];
else
   kCurveMP = [x(end) y(end)];
end

%Update GUI data.
handles.kymoX{numKymoCurves}      = x;
handles.kymoY{numKymoCurves}      = y;
handles.kymo{numKymoCurves}       = [];
handles.xBand{numKymoCurves}      = [];
handles.yBand{numKymoCurves}      = [];
handles.width(numKymoCurves)      = handles.currentWidth;
handles.kCurveMP(numKymoCurves,:) = kCurveMP;
handles.numKymoCurves             = numKymoCurves;
handles.selKymoCurve              = numKymoCurves;
handles.selImgObj               = 'kymoCurve';

handles.numVLines(numKymoCurves)  = 0;
handles.kymAxesP(numKymoCurves,:) = zeros(1,4);
handles.vLineX{numKymoCurves}     = {};
handles.vLineY{numKymoCurves}     = {};
handles.vLineMP{numKymoCurves}    = [];
handles.selVLine(numKymoCurves)   = 0;
handles.manSpeed{numKymoCurves}   = [];
handles.calSpeed(numKymoCurves)   = Inf;

redrawAllImg(handles);
guidata(hObject,handles);

% --- Executes on button press in clickPoints.
function clickPoints_Callback(hObject, eventdata, handles)
% hObject    handle to clickPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.whatIsShown,'image') == 0 | handles.numImages == 0
   %When what is shown in the figure window is not the image or when no image
   % is input yet.
   return;
end

[x,y] = imSelCurve(1);

numFTrackPts = handles.numFTrackPts+1;
handles.flowV(numFTrackPts,:)      = [y x Inf Inf];
handles.FTkymo{numFTrackPts}       = [];
handles.FTxBand{numFTrackPts}      = [];
handles.FTyBand{numFTrackPts}      = [];
handles.FTkymoX(numFTrackPts,:)    = [Inf Inf];
handles.FTkymoY(numFTrackPts,:)    = [Inf Inf];
handles.kymFTLen(numFTrackPts)     = handles.defKymFTLen;
handles.kymFTWidth(numFTrackPts)   = handles.defKymFTWidth;
handles.FTnumVLines(numFTrackPts)  = 0;
handles.FTkymAxesP(numFTrackPts,:) = zeros(1,4);
handles.FTvLineX{numFTrackPts}     = {};
handles.FTvLineY{numFTrackPts}     = {};
handles.FTvLineMP{numFTrackPts}    = [];
handles.FTselVLine(numFTrackPts)   = 0;
handles.FTmanSpeed{numFTrackPts}   = [];
handles.FTcalSpeed(numFTrackPts)   = Inf;


handles.numFTrackPts = numFTrackPts;
handles.selFTrackP   = numFTrackPts;
handles.selImgObj  = 'FTrackPt';

redrawAllImg(handles);
guidata(hObject,handles);

% --- Executes on button press in drawFieldBnd.
function drawFieldBnd_Callback(hObject, eventdata, handles)
% hObject    handle to drawFieldBnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.whatIsShown,'image') == 0 | handles.numImages == 0
   %When what is shown in the figure window is not the image or when no image
   % is input yet.
   return;
end

[bw,fieldBndX,fieldBndY] = roipoly;
numFields = handles.numFields+1;

%Idenitify the mark point.
[leftX,ind] = min(fieldBndX);
leftI = find(fieldBndX==leftX);
[leftY,ind] = max(fieldBndY(leftI));

handles.field{numFields}.MP    = [leftX, leftY];
handles.field{numFields}.label = ['F' num2str(numFields)];
handles.field{numFields}.bndX  = fieldBndX;
handles.field{numFields}.bndY  = fieldBndY;

handles.field{numFields}.gridDx    = [];
handles.field{numFields}.gridDy    = [];
handles.field{numFields}.gridPts   = [];
handles.field{numFields}.speckles  = [];
handles.field{numFields}.initFlow  = [];
handles.field{numFields}.selObj    = 'none';
handles.field{numFields}.kymDirCrv = [];
handles.field{numFields}.kymLineOn = 'no';

handles.selField  = numFields;
handles.numFields = numFields;
handles.selImgObj = 'FTrackField';

redrawAllImg(handles);
guidata(hObject,handles);

% --- Executes on button press in addFieldPoints.
function addFieldPoints_Callback(hObject, eventdata, handles)
% hObject    handle to gridPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.whatIsShown,'image') == 0 | handles.numImages == 0
   %When what is shown in the figure window is not the image or when no image
   % is input yet.
   return;
end

menuItem = get(hObject,'Value');

if menuItem == 1
   handles.field{handles.selField}.selObj = 'none';
elseif menuItem == 2
   handles = addGridPoints(handles);
elseif menuItem == 3
   %handles = addSpeckles(handles);
elseif menuItem == 4
   %handles = addInitFlow(handles);
end

redrawAllImg(handles);
guidata(hObject,handles);


function handles = addGridPoints(handles)
%subfunction called by 'addFieldPoints_Callback' to add grid points.

selField = handles.selField;

handles.field{selField}.selObj = 'grid';

if ~isempty(handles.field{selField}.gridPts)
   return;
end

ans = inputdlg({'Enter the horizontal step size or coordinates:' ...
   'Enter the vertical step size or coordinates:'}, ...
   'Grid Points',1,{num2str(handles.defGridDx) ...
   num2str(handles.defGridDy)});

ans1 = str2num(ans{1});
ans2 = str2num(ans{2});

if length(ans1) == 1
   handles.field{selField}.gridDx = ans1;
   x = [1:ans1:handles.imgWidth];
else
   x = ans1;
end

if length(ans2) == 1
   handles.field{selField}.gridDy = ans2;
   y = [1:ans2:handles.imgHeight];
else
   y = ans2;
end

[gridX,gridY] = meshgrid(x,y);
gridX = reshape(gridX,1,length(gridX(:)));
gridY = reshape(gridY,1,length(gridY(:)));

%Select points that are inside the polygon.
fieldBndX = handles.field{selField}.bndX;
fieldBndY = handles.field{selField}.bndY;
in = inpolygon(gridX,gridY,fieldBndX,fieldBndY);
outI = find(in==0 | in==0.5);
gridX(outI) = [];
gridY(outI) = [];

handles.field{selField}.gridPts = [gridX.' gridY.'];


% --- Executes on button press in addFTrackKymLine.
function addFTrackKymLine_Callback(hObject, eventdata, handles)
% hObject    handle to addFTrackKymLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.whatIsShown,'image') == 0 | handles.numImages == 0 | ...
   strcmp(handles.selImgObj,'FTrackField') == 0
   %When what is shown in the figure window is not the image or when no image
   % is input yet.
   return;
end

selField = handles.selField;

if strcmp(handles.field{selField}.kymLineOn,'yes') == 1
   return;
end

%The way we add kymograph lines to each point is to first draw a curve and use
% the normal direction of the curve as the direction for the kymograph lines.
if isempty(handles.field{selField}.kymDirCrv)
   [xi,yi] = imSelCurve;
   handles.field{selField}.kymDirCrv = [xi;yi];
end
handles.field{selField}.kymLineOn = 'yes';

redrawAllImg(handles);
guidata(hObject,handles);

% --- Executes on button press in FTrackKymLineOff.
function FTrackKymLineOff_Callback(hObject, eventdata, handles)
% hObject    handle to FTrackKymLineOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.whatIsShown,'image') == 0 | handles.numImages == 0 | ...
   strcmp(handles.selImgObj,'FTrackField') == 0
   %When what is shown in the figure window is not the image or when no image
   % is input yet.
   return;
end

selField = handles.selField;

if strcmp(handles.field{selField}.kymLineOn,'no') == 1
   return;
end

handles.field{selField}.kymLineOn = 'no';

redrawAllImg(handles);
guidata(hObject,handles);

% --- Executes on the text field 'currentWidth'.
function currentWidth_Callback(hObject, eventdata, handles)
% hObject    handle to currentWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
entry = get(hObject,'string');
if isnan(str2double(entry))
   errordlg('You must enter a numeric value','Bad Input','modal');
end

handles.currentWidth = str2double(entry);
guidata(hObject,handles);

% --- Executes on the text field 'vectorScale'.
function vectorScale_Callback(hObject, eventdata, handles)
% hObject    handle to vectorScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
entry = get(hObject,'string');
if isnan(str2double(entry))
   errordlg('You must enter a numeric value','Bad Input','modal');
end

handles.flowVScale = str2double(entry);

redrawAllImg(handles);
guidata(hObject,handles);


% --- Executes on button press in calVelocity.
function calVelocity_Callback(hObject, eventdata, handles)
% hObject    handle to calVelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.whatIsShown,'image') == 0 | handles.numImages == 0
   %When what is shown in the figure window is not the image or when no image
   % is input yet.
   return;
end

ans = inputdlg({'Enter the length:' 'Enter the width:'}, ...
   'Kymograph Line',1,{num2str(handles.defKymFTLen) ...
   num2str(handles.defKymFTWidth)});

len   = str2num(ans{1});
width = str2num(ans{2});

selFTrackP = handles.selFTrackP;
x          = handles.flowV(selFTrackP,2);
y          = handles.flowV(selFTrackP,1);
stack      = handles.imgFileList(handles.startImage:handles.endImage);
[v,theta]  = imKymoVelocity(stack,x,y,len,width,'output','angle');
vx         = v*cos(theta);
vy         = v*sin(theta);
kymoX      = x + len*cos(theta)/2*[-1 1];
kymoY      = y + len*sin(theta)/2*[-1 1];

handles.flowV(selFTrackP,4)    = vx;
handles.flowV(selFTrackP,3)    = vy;
handles.FTkymo{selFTrackP}     = [];
handles.FTxBand{selFTrackP}    = [];
handles.FTyBand{selFTrackP}    = [];
handles.kymFTLen(selFTrackP)   = len;
handles.kymFTWidth(selFTrackP) = width;
handles.FTkymoX(selFTrackP,:)  = kymoX;
handles.FTkymoY(selFTrackP,:)  = kymoY;

redrawAllImg(handles);
guidata(hObject,handles)


% --- Executes on the text field 'startImage'.
function startImage_Callback(hObject, eventdata, handles)
% hObject    handle to startImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
entry = get(hObject,'string');
if isnan(str2double(entry))
   errordlg('You must enter a numeric value.','Bad Input','modal');
end

startImage = str2double(entry);

if startImage >= handles.numImages
   errordlg(['The starting image has to be less than the ' ...
       'total number of images ' num2str(handles.numImages) '.'], ...
       'Bad Input','modal');
end

if startImage ~= handles.startImage
   handles.image      = imread(handles.imgFileList{startImage});
   handles.startImage = startImage;

   for k = 1:handles.numKymoCurves
      handles.numVLines(k)  = 0;
      handles.kymo{k}       = [];
      handles.xBand{k}      = [];
      handles.yBand{k}      = [];
      handles.kymAxesP(k,:) = zeros(1,4);
      handles.vLineX{k}     = {};
      handles.vLineY{k}     = {};
      handles.vLineMP{k}    = [];
      handles.selVLine(k)   = 0;
      handles.manSpeed{k}   = [];
      handles.calSpeed(k)   = Inf;
   end
   for k = 1:handles.numFTrackPts
      handles.FTnumVLines(k)  = 0;
      handles.FTkymo{k}       = [];
      handles.FTkymoX(k,:)    = [Inf Inf];
      handles.FTkymoY(k,:)    = [Inf Inf];
      handles.FTxBand{k}      = [];
      handles.FTyBand{k}      = [];
      handles.FTkymAxesP(k,:) = zeros(1,4);
      handles.FTvLineX{k}     = {};
      handles.FTvLineY{k}     = {};
      handles.FTvLineMP{k}    = [];
      handles.FTselVLine(k)   = 0;
      handles.FTmanSpeed{k}   = [];
      handles.FTcalSpeed(k)   = Inf;
      handles.flowV(k,3:4)    = [Inf Inf];
   end

   %handles.whatIsShown = 'kymo';
   redrawAllImg(handles);
   handles.whatIsShown = 'image';
   guidata(hObject,handles);
end


% --- Executes on the text field 'endImage'.
function endImage_Callback(hObject, eventdata, handles)
% hObject    handle to endImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
entry = get(hObject,'string');
if isnan(str2double(entry))
   errordlg('You must enter a numeric value.','Bad Input','modal');
end

endImage = str2double(entry);

if endImage > handles.numImages
   errordlg(['The ending image can not be greater than the ' ...
       'total number of images ' num2str(handles.numImages) '.'], ...
       'Bad Input','modal');
end

if endImage <= handles.startImage
   errordlg(['The ending image must be greater than the ' ...
       'starting image ' num2str(handles.startImage) '.'], ...
       'Bad Input','modal');
end

if endImage ~= handles.endImage
   handles.endImage = endImage;

   for k = 1:handles.numKymoCurves
      handles.numVLines(k)  = 0;
      handles.kymo{k}       = [];
      handles.xBand{k}      = [];
      handles.yBand{k}      = [];
      handles.kymAxesP(k,:) = zeros(1,4);
      handles.vLineX{k}     = {};
      handles.vLineY{k}     = {};
      handles.vLineMP{k}    = [];
      handles.selVLine(k)   = 0;
      handles.manSpeed{k}   = [];
      handles.calSpeed(k)   = Inf;
   end
   for k = 1:handles.numFTrackPts
      handles.FTnumVLines(k)  = 0;
      handles.FTkymo{k}       = [];
      handles.FTkymoX(k,:)    = [Inf Inf];
      handles.FTkymoY(k,:)    = [Inf Inf];
      handles.FTxBand{k}      = [];
      handles.FTyBand{k}      = [];
      handles.FTkymAxesP(k,:) = zeros(1,4);
      handles.FTvLineX{k}     = {};
      handles.FTvLineY{k}     = {};
      handles.FTvLineMP{k}    = [];
      handles.FTselVLine(k)   = 0;
      handles.FTmanSpeed{k}   = [];
      handles.FTcalSpeed(k)   = Inf;
      handles.flowV(k,3:4)    = [Inf Inf];
   end

   redrawAllImg(handles);
   handles.whatIsShown = 'image';
   guidata(hObject,handles);
end

% --- Executes on button press in showImage.
function showImage_Callback(hObject, eventdata, handles)
% hObject    handle to showImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.whatIsShown,'image') == 1
   return;
end

redrawAllImg(handles);
handles.whatIsShown = 'image';

guidata(hObject,handles);

% --- Executes on button press of 'manSpeedTrack'.
function manSpeedTrack_Callback(hObject, eventdata, handles)
% hObject    handle to manSpeedTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.selImgObj,'kymoCurve') == 1
   if handles.numKymoCurves == 0
      return;
   end

   selKymoCurve = handles.selKymoCurve;
   numVLines    = handles.numVLines(selKymoCurve)+1;
   width        = handles.width(selKymoCurve);
elseif strcmp(handles.selImgObj,'FTrackPt') == 1
   if handles.numFTrackPts == 0
      return;
   end

   selFTrackP = handles.selFTrackP;
   numVLines  = handles.FTnumVLines(selFTrackP)+1;
   width      = handles.kymFTWidth(selFTrackP);
end

showKymograph_Callback(hObject,eventdata,handles);
handles = guidata(hObject);

[x,y] = imSelCurve(2);

%Find the mark point which is the left-most end of the line.
if x(end) > x(1)
   vLineMP = [x(1) y(1)];
else
   vLineMP = [x(end) y(end)];
end

%Calculate the speed from the drawn line slope.
if abs(y(end)-y(1)) < 1
   manSpeed = Inf;
else
   manSpeed = (x(end)-x(1))/(y(end)-y(1))*width;
end

if strcmp(handles.selImgObj,'kymoCurve') == 1
   handles.manSpeed{selKymoCurve}(numVLines) = manSpeed;

   %Update GUI data.
   handles.vLineX{selKymoCurve}{numVLines}    = x;
   handles.vLineY{selKymoCurve}{numVLines}    = y;
   handles.vLineMP{selKymoCurve}(numVLines,:) = vLineMP;
   handles.numVLines(selKymoCurve)            = numVLines;
   handles.selVLine(selKymoCurve)             = numVLines;
elseif strcmp(handles.selImgObj,'FTrackPt') == 1
   handles.FTmanSpeed{selFTrackP}(numVLines) = manSpeed;

   %Update GUI data.
   handles.FTvLineX{selFTrackP}{numVLines}    = x;
   handles.FTvLineY{selFTrackP}{numVLines}    = y;
   handles.FTvLineMP{selFTrackP}(numVLines,:) = vLineMP;
   handles.FTnumVLines(selFTrackP)            = numVLines;
   handles.FTselVLine(selFTrackP)             = numVLines;
end

redrawAllKymo(handles);
guidata(hObject,handles);

% --- Executes on button press of 'calSpeed'.
function calSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to calSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.selImgObj,'kymoCurve') == 1
   if handles.numKymoCurves == 0
      return;
   end

   showKymograph_Callback(hObject,eventdata,handles);
   handles = guidata(hObject);

   selKymoCurve = handles.selKymoCurve;
   kymo         = handles.kymo{selKymoCurve};
   width        = handles.width(selKymoCurve);
elseif strcmp(handles.selImgObj,'FTrackPt') == 1
   if handles.numFTrackPts == 0
      return;
   end

   selFTrackP = handles.selFTrackP;
   if isinf(handles.flowV(selFTrackP,3))
      return;
   end

   showKymograph_Callback(hObject,eventdata,handles);
   handles = guidata(hObject);

   kymo  = handles.FTkymo{selFTrackP};
   width = handles.kymFTWidth(selFTrackP);
end

calSpeed = imKymoSpeed(kymo,width);
set(handles.calSpeedFH,'String',num2str(calSpeed));

if strcmp(handles.selImgObj,'kymoCurve') == 1
   handles.calSpeed(selKymoCurve) = calSpeed;
elseif strcmp(handles.selImgObj,'FTrackPt') == 1
   handles.FTcalSpeed(selFTrackP) = calSpeed;
end
%if isinf(handles.calSpeed(selKymoCurve))
%   handles.calSpeed(selKymoCurve) = imKymoSpeed(kymo,bw);
%end

guidata(hObject,handles);

% --- Executes on button press in showKymograph.
function showKymograph_Callback(hObject, eventdata, handles)
% hObject    handle to showKymograph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.whatIsShown,'kymo') == 1
   return;
end

startImage   = handles.startImage;
endImage     = handles.endImage;
if strcmp(handles.selImgObj,'kymoCurve') == 1
   if handles.numKymoCurves == 0
      return;
   end

   selKymoCurve = handles.selKymoCurve;
   kymo         = handles.kymo{selKymoCurve};
   kymoX        = handles.kymoX{selKymoCurve}; 
   kymoY        = handles.kymoY{selKymoCurve}; 
   width        = handles.width(selKymoCurve); 
elseif strcmp(handles.selImgObj,'FTrackPt') == 1
   if handles.numFTrackPts == 0
      return;
   end

   selFTrackP = handles.selFTrackP;
   if isinf(handles.flowV(selFTrackP,3))
      return;
   end
   kymo  = handles.FTkymo{selFTrackP};
   kymoX = handles.FTkymoX(selFTrackP,:);
   kymoY = handles.FTkymoY(selFTrackP,:);
   width = handles.kymFTWidth(selFTrackP);
else
   return;
end

if isempty(kymo)
   hmsg = msgbox('Kymograph stacking in progress ...');
   drawnow;

   stack = handles.imgFileList(startImage:endImage);
   [kymo, xBand, yBand] = imKymograph(stack,kymoX,kymoY,width, ...
      'verbose','off','interp','none');

   %Calculate the position of the axis for kymograph.
   imgAxesP = handles.imgAxesP;
   imgW  = imgAxesP(3); %Width of the image.
   imgH  = imgAxesP(4); %Height of the image.
   kymSz = size(kymo);
   kymW  = min(imgW,kymSz(2)); %Width of the kymograph image.
   kymH  = min(imgH,kymSz(1)); %Height of the kymograph image.

   kymAxesP = [imgAxesP(1:2)+[(imgW-kymW)/2 (imgH-kymH)/2] kymW kymH];

   if strcmp(handles.selImgObj,'kymoCurve') == 1
      handles.kymo{selKymoCurve}  = kymo;
      handles.xBand{selKymoCurve} = xBand;
      handles.yBand{selKymoCurve} = yBand;
      handles.kymAxesP(selKymoCurve,:) = kymAxesP;

      handles.numVLines(selKymoCurve) = 0;
      handles.vLineX{selKymoCurve}    = [];
      handles.vLineY{selKymoCurve}    = [];
      handles.vLineMP{selKymoCurve}   = [];
      handles.selVLine(selKymoCurve)  = 0;
      handles.manSpeed{selKymoCurve}  = [];
      handles.calSpeed(selKymoCurve)  = Inf;
   elseif strcmp(handles.selImgObj,'FTrackPt') == 1
      handles.FTkymo{selFTrackP}       = kymo;
      handles.FTxBand{selFTrackP}      = xBand;
      handles.FTyBand{selFTrackP}      = yBand;
      handles.FTkymAxesP(selFTrackP,:) = kymAxesP;

      handles.FTnumVLines(selFTrackP) = 0;
      handles.FTvLineX{selFTrackP}    = [];
      handles.FTvLineY{selFTrackP}    = [];
      handles.FTvLineMP{selFTrackP}   = [];
      handles.FTselVLine(selFTrackP)  = 0;
      handles.FTmanSpeed{selFTrackP}  = [];
      handles.FTcalSpeed(selFTrackP)  = Inf;
   end
   close(hmsg);
end

redrawAllKymo(handles);
handles.whatIsShown = 'kymo';

guidata(hObject,handles);


% --- Executes on mouse button motion.
function winButtonMotion_Callback(hObject, eventdata, handles)
% hObject    handle to 'WindowButtonMotionFcn' (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figH = handles.figH;
aH   = gca(figH);

%Get the current pointer location.
p = get(aH,'CurrentPoint');

set(aH,'Units','pixels');
xlim = get(aH,'XLim');
ylim = get(aH,'YLim');
axesP = get(aH,'Position');
axesW = xlim(2)-xlim(1)+1; %The width of the axes in plotting units.
axesH = ylim(2)-ylim(1)+1;
axesWPix = axesP(3); %The width of the axes in pixels.
axesHPix = axesP(4); %The height of the axes in pixels.

if strcmp(handles.whatIsShown,'image') == 1
   numLines     = handles.numKymoCurves;
   numFTrackPts = handles.numFTrackPts;
   numFields    = handles.numFields;

   selKymoCurve = handles.selKymoCurve;
   lineMP       = handles.kCurveMP;
   selFTrackP   = handles.selFTrackP;

   if numFTrackPts > 0
      FTrackP = handles.flowV(:,2:-1:1);
   else
      FTrackP = [];
   end
elseif strcmp(handles.whatIsShown,'kymo') == 1
   if strcmp(handles.selImgObj,'kymoCurve') == 1
      selKymoCurve = handles.selKymoCurve;
      numLines     = handles.numVLines(selKymoCurve);
      lineMP       = handles.vLineMP{selKymoCurve};
   elseif strcmp(handles.selImgObj,'FTrackPt') == 1
      selFTrackP = handles.selFTrackP;
      numLines   = handles.FTnumVLines(selFTrackP);
      lineMP     = handles.FTvLineMP{selFTrackP};
   end

   numFTrackPts = 0;
   numFields    = 0;
else
   numLines     = 0;
   numFTrackPts = 0;
   numFields    = 0;
end

%Calculate the distance between the current pointer 'p' and the mark points
% of each line (left-most end) and the selected points for flow tracking. If 
% the minimum distance is less than 5 pixels and the mouse action is left
% click, choose the corresponding line by highlight.
if numLines == 0
   dist1 = Inf;
else
   dist1 = sqrt(((p(1,1)-lineMP(:,1))*axesW/axesWPix).^2+ ...
      ((p(1,2)-lineMP(:,2))*axesH/axesHPix).^2);
end

if numFTrackPts == 0
   dist2 = inf;
else
   dist2 = sqrt(((p(1,1)-FTrackP(:,1))*axesW/axesWPix).^2+ ...
      ((p(1,2)-FTrackP(:,2))*axesW/axesWPix).^2);
end

if numFields == 0
   dist3 = inf;
else
   fieldMP = zeros(numFields,2);
   for k = 1:numFields
      fieldMP(k,:) = handles.field{k}.MP;
   end
   dist3 = sqrt(((p(1,1)-fieldMP(:,1))*axesW/axesWPix).^2+ ...
      ((p(1,2)-fieldMP(:,2))*axesW/axesWPix).^2);
end

[minD1,index1] = min(dist1);
[minD2,index2] = min(dist2);
[minD3,index3] = min(dist3);

minD = min([minD1 minD2 minD3]);
if isempty(handles.whatIsShown) | isinf(minD)
   set(figH,'Pointer','arrow');
elseif minD == minD1
   if minD1 <= 10
      %Change the mouse shape.
      set(figH,'Pointer','circle');
      p(1,1) = lineMP(index1,1);
      p(1,2) = lineMP(index1,2);
   else
      set(figH,'Pointer','arrow');
   end
elseif minD == minD2
   if minD2 <= 10
      %Change the mouse shape.
      set(figH,'Pointer','circle');
      p(1,1) = FTrackP(index2,1);
      p(1,2) = FTrackP(index2,2);
   else
      set(figH,'Pointer','arrow');
   end
elseif minD == minD3
   if minD3 <= 10
      %Change the mouse shape.
      set(figH,'Pointer','circle');
      p(1,1) = fieldMP(index1,1);
      p(1,2) = fieldMP(index1,2);
   else
      set(figH,'Pointer','arrow');
   end
end

%Display the current pointer position.
% First, delete the old position text message.
pLocText = findobj('Tag','pLocText');
if ishandle(pLocText)
   delete(pLocText);
end

if p(1,1) >= 1 & p(1,1) <= axesW & p(1,2) >= 1 & p(1,2) <= axesH
   if strcmp(handles.whatIsShown,'image') == 1
      imgW     = handles.imgWidth;
      pLocText = text(0,0,['(' num2str(p(1,1)) ',' num2str(p(1,2)),')']);
      tExtent  = get(pLocText,'Extent');
      tW       = tExtent(3);
      tH       = tExtent(4);
      set(pLocText,'Position',[(imgW-tW)/2 -tH 0],'Tag','pLocText');
   elseif strcmp(handles.whatIsShown,'kymo') == 1
      if strcmp(handles.selImgObj,'kymoCurve') == 1
         kymLineW = handles.width(selKymoCurve);
      elseif strcmp(handles.selImgObj,'FTrackPt') == 1
         kymLineW = handles.kymFTWidth(selFTrackP);
      end
      pLocText = text(0,0,['(' num2str(p(1,1)) ',' ...
         num2str(ceil(p(1,2)/kymLineW)),')']);
      tExtent = get(pLocText,'Extent');
      tW      = tExtent(3);
      tH      = tExtent(4);
      set(pLocText,'Position',[axesW+10*axesW/axesWPix axesH/2 0], ...
         'Tag','pLocText');
   end
end

%redrawAllImg(handles);
%guidata(hObject,handles);


% --- Executes on mouse button down.
function winButtonDown_Callback(hObject, eventdata, handles)
% hObject    handle to 'WindowButtonDownFcn' (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figH = handles.figH;
aH   = gca(figH);

whatIsShown = handles.whatIsShown;

if strcmp(whatIsShown,'image') == 1
   numLines     = handles.numKymoCurves;
   numFTrackPts = handles.numFTrackPts;
   numFields    = handles.numFields;
   if numLines == 0 & numFTrackPts == 0 & numFields == 0
      return;
   end

   selLine    = handles.selKymoCurve;
   lineMP     = handles.kCurveMP;
   selFTrackP = handles.selFTrackP;
   selField   = handles.selFTrackP;

   if numFTrackPts > 0
      FTrackP = handles.flowV(:,2:-1:1);
   else
      FTrackP = [];
   end
elseif strcmp(whatIsShown,'kymo') == 1
   if strcmp(handles.selImgObj,'kymoCurve') == 1
      selKymoCurve = handles.selKymoCurve;
      selLine      = handles.selVLine(selKymoCurve);
      numLines     = handles.numVLines(selKymoCurve);
      lineMP       = handles.vLineMP{selKymoCurve};
   elseif strcmp(handles.selImgObj,'FTrackPt') == 1
      selFTrackP = handles.selFTrackP;
      selLine    = handles.FTselVLine(selFTrackP);
      numLines   = handles.FTnumVLines(selFTrackP);
      lineMP     = handles.FTvLineMP{selFTrackP};
   end

   if numLines == 0
      return;
   end

   FTrackP = [];
   numFTrackPts = 0;
   numFields    = 0;
else
   return;
end

%Get the current pointer location.
p = get(aH,'CurrentPoint');

%Calculate the distance between the current pointer 'p' to the left-most end
% of each line. If the minimum distance is less than 5 pixels and the mouse
% action is left click, choose the corresponding line by highlight.
% To calculate the distance in pixels, we need info about the dimension in
% both plotting units and pixels.
set(aH,'Units','pixels');
xlim = get(aH,'XLim');
ylim = get(aH,'YLim');
axesP = get(aH,'Position');
axesW = xlim(2)-xlim(1)+1; %The width of the axes in plotting units.
aH = ylim(2)-ylim(1)+1;
axesWPix = axesP(3); %The width of the axes in pixels.
aHPix = axesP(4); %The height of the axes in pixels.
if numLines == 0
   dist1 = inf;
else
   dist1 = sqrt(((p(1,1)-lineMP(:,1))*axesWPix/axesW).^2+ ...
           ((p(1,2)-lineMP(:,2))*aHPix/aH).^2);
end

if numFTrackPts == 0
   dist2 = inf;
else
   dist2 = sqrt(((p(1,1)-FTrackP(:,1))*axesWPix/axesW).^2+ ...
           ((p(1,2)-FTrackP(:,2))*aHPix/aH).^2);
end

if numFields == 0
   dist3 = inf;
else
   fieldMP = zeros(numFields,2);
   for k = 1:numFields
      fieldMP(k,:) = handles.field{k}.MP;
   end
   dist3 = sqrt(((p(1,1)-fieldMP(:,1))*axesW/axesWPix).^2+ ...
      ((p(1,2)-fieldMP(:,2))*axesW/axesWPix).^2);
end

[minD1,index1] = min(dist1);
[minD2,index2] = min(dist2);
[minD3,index3] = min(dist3);

minD = min([minD1 minD2 minD3]);
if isempty(handles.whatIsShown) | isinf(minD)
   return;
elseif minD == minD1
   selImgObj = 'kymoCurve';
   index = index1;
elseif minD == minD2
   selImgObj = 'FTrackPt';
   index = index2;
elseif minD == minD3
   selImgObj = 'FTrackField';
   index = index2;
end

if minD <= 10
   mouseAction = get(figH,'SelectionType');
   if strcmp(mouseAction,'normal') == 1 | strcmp(mouseAction,'open') == 1
      %We have a left-mouse button click or double click. 
      % Select this line and hightlight it.
      if strcmp(whatIsShown,'image') == 1
         handles.selImgObj = selImgObj;
         if minD == minD1
            if index ~= selLine
               handles.selKymoCurve = index;
               handles.currentWidth = handles.width(index);
            end
         elseif minD == minD2
            if index ~= selFTrackP
               handles.selFTrackP  = index;
            end
         elseif minD == minD3
            if index ~= selFTrackP
               handles.selField = index;
            end
         end

         if strcmp(mouseAction,'open') == 1
            %Open a dialog to edit the line.
         end

         redrawAllImg(handles);
      elseif strcmp(whatIsShown,'kymo') == 1
         if index ~= selLine
            if strcmp(handles.selImgObj,'kymoCurve') == 1
               handles.selVLine(selKymoCurve) = index;
            elseif strcmp(handles.selImgObj,'FTrackPt') == 1
               handles.FTselVLine(selFTrackP) = index;
            end
            redrawAllKymo(handles);
         end
      end
   elseif strcmp(mouseAction,'alt') == 1
      %We have a right click. Delete the corresponding line in focus and
      % redraw everything.
      if strcmp(whatIsShown,'image') == 1
         if minD == minD1
            %In this case, it is one of the kymograph curves that has been 
            % clicked.
            handles.numKymoCurves     = numLines-1;
            handles.kymoX(index)      = [];
            handles.kymoY(index)      = [];
            handles.width(index)      = [];
            handles.kCurveMP(index,:) = [];

            handles.kymo(index)  = [];
            handles.xBand(index) = [];
            handles.yBand(index) = [];

            handles.numVLines(index) = [];
            handles.vLineX(index)    = [];
            handles.vLineY(index)    = [];
            handles.vLineMP(index)   = [];
            handles.selVLine(index)  = [];
            handles.manSpeed(index)  = [];
            handles.calSpeed(index)  = [];

            if numLines == 1
               handles.selKymoCurve = 0;
            elseif index < selLine
               handles.selKymoCurve = selLine-1;
            elseif selLine == numLines
               handles.selKymoCurve = handles.numKymoCurves;
            end
         elseif minD == minD2
            %In this case, it is one of the flow tracking points that has been
            % clicked.
            handles.numFTrackPts      = numFTrackPts-1;
            handles.FTkymoX(index,:)  = [];
            handles.FTkymoY(index,:)  = [];
            handles.flowV(index,:)    = [];
            handles.kymFTLen(index)   = [];
            handles.kymFTWidth(index) = [];

            handles.FTkymo(index)  = [];
            handles.FTxBand(index) = [];
            handles.FTyBand(index) = [];

            handles.FTnumVLines(index) = [];
            handles.FTvLineX(index)    = [];
            handles.FTvLineY(index)    = [];
            handles.FTvLineMP(index)   = [];
            handles.FTselVLine(index)  = [];
            handles.FTmanSpeed(index)  = [];
            handles.FTcalSpeed(index)  = [];

            if numFTrackPts == 1
               handles.selFTrackP = 0;
            elseif index < selFTrackP
               handles.selFTrackP = selFTrackP-1;
            elseif selFTrackP == numFTrackPts
               handles.selFTrackP = handles.numFTrackPts;
            end
         end

         redrawAllImg(handles);
      elseif strcmp(handles.whatIsShown,'kymo') == 1
         if strcmp(handles.selImgObj,'kymoCurve') == 1
            handles.numVLines(selKymoCurve)        = numLines-1;
            handles.vLineX{selKymoCurve}(index)    = [];
            handles.vLineY{selKymoCurve}(index)    = [];
            handles.vLineMP{selKymoCurve}(index,:) = [];
            handles.manSpeed{selKymoCurve}(index)  = [];

            if numLines == 1
               handles.selVLine(selKymoCurve) = 0;
            elseif index < selLine
               handles.selVLine(selKymoCurve) = selLine-1;
            elseif selLine == numLines
               handles.selVLine(selKymoCurve) = numLines-1;
            end
         elseif strcmp(handles.selImgObj,'FTrackPt') == 1
            handles.FTnumVLines(selFTrackP)       = numLines-1;
            handles.FTvLineX{selFTrackP}(index)    = [];
            handles.FTvLineY{selFTrackP}(index)    = [];
            handles.FTvLineMP{selFTrackP}(index,:) = [];
            handles.FTmanSpeed{selFTrackP}(index)  = [];

            if numLines == 1
               handles.FTselVLine(selFTrackP) = 0;
            elseif index < selLine
               handles.FTselVLine(selFTrackP) = selLine-1;
            elseif selLine == numLines
               handles.FTselVLine(selFTrackP) = numLines-1;
            end
         end

         redrawAllKymo(handles);
      end
   end
end

guidata(hObject,handles);


%%%%%%%%%%%%%%%%%%%%%%% subfunction %%%%%%%%%%%%%%%%%%%%%%%
function redrawAllImg(handles)
%Redraw the image and all the chosen lines (or curves).

figH = handles.figH;
imgAxesP = handles.imgAxesP;
delete(gca(figH));
figure(figH);
imshow(handles.image,[]); 
aH = gca(figH);
set(aH,'Units','pixels','Position',imgAxesP);

%To figure out an appropriate distance to the mark point for labeling, 
% we need to scale the x and y range of the image to units in pixels.
xlim = get(aH,'XLim');
ylim = get(aH,'YLim');
axesP = get(aH,'Position');
axesW = xlim(2)-xlim(1); %The width of the axes in plotting units.
axesH = ylim(2)-ylim(1);
axesWPix = axesP(3); %The width of the axes in pixels.
axesHPix = axesP(4); %The height of the axes in pixels.
labelShift = -[20*axesW/axesWPix,5*aH/axesHPix];

axis on; hold on;

%Draw all the kymograph curves.
for k = 1:handles.numKymoCurves
   drawCurve(aH,handles.kymoX{k},handles.kymoY{k}, ...
      floor(handles.width(k)/2), handles.kCurveMP(k,:)+labelShift, ...
      ['L' num2str(k)]);
end

%Draw all the points and the flow velocity vectors calculated.
scale = handles.flowVScale;
for k = 1:handles.numFTrackPts
   flowV = handles.flowV(k,:);
   kymoX = handles.FTkymoX(k,:);
   kymoY = handles.FTkymoY(k,:);
   width = handles.kymFTWidth(k);
   drawFTrackP(aH,flowV,scale,kymoX,kymoY,width,['P' num2str(k)],labelShift);
end

%Draw the boundary of the flow field and points in it if selected and flow
% velocity vectors if calculated.
for k = 1:handles.numFields;
   drawField(aH,handles.field{k},labelShift,'off');
end

%Highlight the selected point or curve.
if strcmp(handles.selImgObj,'kymoCurve') == 1
   selKymCurve = handles.selKymoCurve;
   if selKymCurve ~= 0
      kCurveMP = handles.kCurveMP(selKymCurve,:);
      labelMP  = kCurveMP+labelShift;
      tH = text(labelMP(1),labelMP(2),['L' num2str(selKymCurve)]);
      set(tH,'color','r');
      plot(kCurveMP(1),kCurveMP(2),'ro');

      %h = plot(handles.kymoX{selKymCurve},handles.kymoY{selKymCurve},'r');
      %   set(h,'LineWidth',1);
   end
elseif strcmp(handles.selImgObj,'FTrackPt') == 1
   selFTrackP = handles.selFTrackP;
   if selFTrackP > 0
      x = handles.flowV(selFTrackP,2);
      y = handles.flowV(selFTrackP,1);
      plot(x,y,'r.','MarkerSize',10);

      labelMP = [x,y]+labelShift;
      tH = text(labelMP(1),labelMP(2),['P' num2str(selFTrackP)]);
      set(tH,'color','r');

      %vx = handles.flowV(selFTrackP,4);
      %vy = handles.flowV(selFTrackP,3);
      %if ~isinf(vx)
      %   quiver(x,y,vx*scale,vy*scale,0,'r');
      %end
   end
elseif strcmp(handles.selImgObj,'FTrackField') == 1
   selField = handles.selField;
   drawField(aH,handles.field{selField},labelShift,'on');
end

updateCurWidthF(handles);
updateCalSpeedF(handles);
updateManSpeedF(handles);
updateFlowVF(handles);

% --- Some user defined subfunctions.
%%%%%%%%%%%%%%%%%%%%%%% subfunction %%%%%%%%%%%%%%%%%%%%%%%
function drawCurve(aH,x,y,w,labelMP,label)
%This function draws a curve though points defined in (x,y) and draw two bars
% that are perpendicular to the curve at the beginning and end points with
% width '2*w'. It also put a label at 'labelMP'. The function returns a column
% vector of handles to all the drawn objects.

plot(x,y,'g');

%Draw a bar perpendicular to the curve with width '2*w' at the first point.
len = sqrt((x(2)-x(1))^2+(y(2)-y(1))^2);
xL  = x(1) - w*(y(1)-y(2))/len;
yL  = y(1) - w*(x(2)-x(1))/len;
xR  = x(1) + w*(y(1)-y(2))/len;
yR  = y(1) + w*(x(2)-x(1))/len;
plot([xL xR],[yL yR],'y');

%Draw a bar perpendicular to the curve with width '2*w' at the last point.
len = sqrt((x(end)-x(end-1))^2+(y(end)-y(end-1))^2);
xL  = x(end) - w*(y(end-1)-y(end))/len;
yL  = y(end) - w*(x(end)-x(end-1))/len;
xR  = x(end) + w*(y(end-1)-y(end))/len;
yR  = y(end) + w*(x(end)-x(end-1))/len;
plot([xL xR],[yL yR],'y');
plot(x,y,'bo');

%Label the number of the line at 'labelMP'.
tH = text(labelMP(1),labelMP(2),label);
set(tH,'color','g');



%%%%%%%%%%%%%%%%%%%%%%% subfunction %%%%%%%%%%%%%%%%%%%%%%%
function drawFTrackP(aH,flowV,scale,kymX,kymY,width,label,labelShift)
%Draw the point where the flow velocity is tracked. If the velocity has
%already been identified, a vector will be drawn.

x  = flowV(2);
y  = flowV(1);
if ~isinf(kymX(1))
   %drawCurve(aH,kymX,kymY,floor(width/2),[x y],label);
else
   %plot(x,y,'g.','MarkerSize',10);
end

vx = flowV(4);
vy = flowV(3);
if ~isinf(vx)
   %The velocity vector has been calculated.
   quiver(x,y,vx*scale,vy*scale,0,'g');
else
   plot(x,y,'g.','MarkerSize',10);
end

%Label the number of the point.
tH = text(x+labelShift(1),y+labelShift(2),label);
set(tH,'color','g');


%%%%%%%%%%%%%%%%%%%%%%% subfunction %%%%%%%%%%%%%%%%%%%%%%%
function drawField(aH,field,labelShift,highLight)

plot(field.bndX,field.bndY,'g-.');

label   = field.label;
labelMP = field.MP + labelShift;

if strcmp(highLight,'on') == 1
   plot(field.MP(1),field.MP(2),'ro','MarkerSize',5);

   %Label the number of the line at 'labelMP'.
   tH = text(labelMP(1),labelMP(2),label);
      set(tH,'color','r');

   %Draw the curve whose normal direction is used for preset kymgraph lines.
   if strcmp(field.kymLineOn,'yes')
      plot(field.kymDirCrv(1,:),field.kymDirCrv(2,:),'g--');
   end

   %Draw the selected points in the field.
   if strcmp(field.selObj,'grid') == 1 & ~isempty(field.gridPts)
      plot(field.gridPts(:,1),field.gridPts(:,2),'y.','MarkerSize',3);
   end
elseif strcmp(highLight,'off') == 1
   plot(field.MP(1),field.MP(2),'go','MarkerSize',5);

   %Label the number of the line at 'labelMP'.
   tH = text(labelMP(1),labelMP(2),label);
      set(tH,'color','g');
end


%%%%%%%%%%%%%%%%%%%%%%% subfunction %%%%%%%%%%%%%%%%%%%%%%%
function drawKymoLine(aH,x,y,labelMP,label)
%Draw a line on the kymograph image so that the Speed can be estimated.

h = line(x,y);
set(h,'color','g');

plot(x,y,'b.');

%Label the number of the line at 'labelMP'.
tH = text(labelMP(1),labelMP(2),label);
set(tH,'color','g');


%%%%%%%%%%%%%%%%%%%%%%% subfunction %%%%%%%%%%%%%%%%%%%%%%%
function redrawAllKymo(handles)
%Redraw the kymograph for the selected curve and any line for manual speed 
% tracking.

if strcmp(handles.selImgObj,'kymoCurve') == 1
   selKymoCurve = handles.selKymoCurve;
   kymo         = handles.kymo{selKymoCurve}; 
   kymoTitle  = ['Kymograph Curve ' num2str(selKymoCurve)];

   %The axes position of the kymograph.
   kymAxesP  = handles.kymAxesP(selKymoCurve,:);

   width     = handles.width(selKymoCurve);
   numVLines = handles.numVLines(selKymoCurve);
   vLineX    = handles.vLineX{selKymoCurve};
   vLineY    = handles.vLineY{selKymoCurve};
   vLineMP   = handles.vLineMP{selKymoCurve};

   index     = handles.selVLine(selKymoCurve);
   if index ~= 0
      selVLineX = handles.vLineX{selKymoCurve}{index};
      selVLineY = handles.vLineY{selKymoCurve}{index};
   end
elseif strcmp(handles.selImgObj,'FTrackPt') == 1
   selFTrackP = handles.selFTrackP;
   kymo       = handles.FTkymo{selFTrackP}; 
   kymoTitle  = ['Flow Tracking Point ' num2str(selFTrackP)];

   %The axes position of the kymograph.
   kymAxesP  = handles.FTkymAxesP(selFTrackP,:);

   width     = handles.kymFTWidth(selFTrackP);
   numVLines = handles.FTnumVLines(selFTrackP);
   vLineX    = handles.FTvLineX{selFTrackP};
   vLineY    = handles.FTvLineY{selFTrackP};
   vLineMP   = handles.FTvLineMP{selFTrackP};

   index     = handles.FTselVLine(selFTrackP);
   if index ~= 0
      selVLineX = handles.FTvLineX{selFTrackP}{index};
      selVLineY = handles.FTvLineY{selFTrackP}{index};
   end
end

figH = handles.figH;
figure(figH);
delete(gca);
axes('Units','pixels','Position',kymAxesP);
imshow(kymo,[]); hold on;
aH = gca;

%To figure out an appropriate distance to the mark point for labeling, 
% we need to scale the x and y range of the image to units in pixels.
xlim = get(aH,'XLim');
ylim = get(aH,'YLim');
axesP = get(aH,'Position');
axesW = xlim(2)-xlim(1); %The width of the axes in plotting units.
axesH = ylim(2)-ylim(1);
axesWPix = axesP(3); %The width of the axes in pixels.
axesHPix = axesP(4); %The height of the axes in pixels.
labelShift = -[10*axesW/axesWPix,5*aH/axesHPix];

numFrames = handles.endImage-handles.startImage+1;
if numFrames > 3
   ytickL = [1 ceil(numFrames/2) numFrames];
else
   ytickL = [1 numFrames];
end
ytick = width*ytickL;
set(aH,'YTick',ytick,'YTickLabel',ytickL);
axis on;
title(kymoTitle);
xlabel('pixel');
ylabel('frame');

for j = 1:numVLines
   drawKymoLine(aH,vLineX{j}, vLineY{j}, vLineMP(j,:)+labelShift, num2str(j));
end

if index ~= 0
   h = line(selVLineX,selVLineY);
   set(h,'color','r','LineWidth',1);
end

updateManSpeedF(handles);
updateCalSpeedF(handles);
updateFlowVF(handles);


%%%%%%%%%%%%%%%%%%%%%%% subfunction %%%%%%%%%%%%%%%%%%%%%%%
%Update information in the text field, 'curWidthF' of the GUI.
function updateCurWidthF(handles);

if handles.selKymoCurve ~= 0
   set(handles.curWidthFH,'String', ...
      num2str(handles.width(handles.selKymoCurve)));
else
   set(handles.curWidthFH,'String', ...
      num2str(handles.currentWidth));
end

%%%%%%%%%%%%%%%%%%%%%%% subfunction %%%%%%%%%%%%%%%%%%%%%%%
%Update information in the text field, 'calSpeedF' of the GUI.
function updateCalSpeedF(handles);

if strcmp(handles.selImgObj,'kymoCurve') == 1
   selKymoCurve = handles.selKymoCurve;
   if selKymoCurve == 0
      return;
   end

   calSpeed = handles.calSpeed(selKymoCurve); 
elseif strcmp(handles.selImgObj,'FTrackPt') == 1
   selFTrackP = handles.selFTrackP;
   if selFTrackP == 0
      return;
   end

   calSpeed = handles.FTcalSpeed(selFTrackP); 
else
   return;
end

if isinf(calSpeed)
   set(handles.calSpeedFH,'String','');
else
   set(handles.calSpeedFH,'String',num2str(calSpeed));
end


%%%%%%%%%%%%%%%%%%%%%%% subfunction %%%%%%%%%%%%%%%%%%%%%%%
%Update information in the text field, 'manSpeedF' of the GUI.
function updateManSpeedF(handles);

if strcmp(handles.selImgObj,'kymoCurve') == 1
   selKymoCurve = handles.selKymoCurve;
   if selKymoCurve == 0
      return;
   end

   index = handles.selVLine(selKymoCurve);
   if index ~= 0
      manSpeed = handles.manSpeed{selKymoCurve}(index);
   end
elseif strcmp(handles.selImgObj,'FTrackPt') == 1
   selFTrackP = handles.selFTrackP;
   if selFTrackP == 0
      return;
   end

   index = handles.FTselVLine(selFTrackP);
   if index ~= 0
      manSpeed = handles.FTmanSpeed{selFTrackP}(index);
   end
else
   return;
end

if index ~= 0
   set(handles.manSpeedFH,'String',num2str(manSpeed));
else
   set(handles.manSpeedFH,'String','');
end

%%%%%%%%%%%%%%%%%%%%%%% subfunction %%%%%%%%%%%%%%%%%%%%%%%
%Update information in the text field, 'velocityField' of the GUI.
function updateFlowVF(handles);

if strcmp(handles.selImgObj,'FTrackPt') == 1
   selFTrackP = handles.selFTrackP;
   if selFTrackP > 0
      if isinf(handles.flowV(selFTrackP,3))
         set(handles.flowVFH,'String','');
      else
         vx = handles.flowV(selFTrackP,4);
         vy = handles.flowV(selFTrackP,3);
         set(handles.flowVFH,'String',num2str(sqrt(vx^2+vy^2)));
      end
   end
end

