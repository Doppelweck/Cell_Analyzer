function varargout = guidemo(varargin)
% GUIDEMO MATLAB code for guidemo.fig
% GUIDEMO, by itself, creates a new GUIDEMO or raises the existing
% singleton*.
%
% H = GUIDEMO returns the handle to a new GUIDEMO or the handle to
% the existing singleton*.
%
% GUIDEMO('CALLBACK',hObject,eventData,handles,...) calls the local
% function named CALLBACK in GUIDEMO.M with the given input arguments.
%
% GUIDEMO('Property','Value',...) creates a new GUIDEMO or raises the
% existing singleton*. Starting from the left, property value pairs are
% applied to the GUI before guidemo_OpeningFcn gets called. An
% unrecognized property name or invalid value makes property application
% stop. All inputs are passed to guidemo_OpeningFcn via varargin.
%
% *See GUI Options on GUIDE's Tools menu. Choose "GUI allows only one
% instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guidemo

% Last Modified by GUIDE v2.5 11-Jun-2017 11:18:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
'gui_Singleton', gui_Singleton, ...
'gui_OpeningFcn', @guidemo_OpeningFcn, ...
'gui_OutputFcn', @guidemo_OutputFcn, ...
'gui_LayoutFcn', [] , ...
'gui_Callback', []);
if nargin && ischar(varargin{1})
gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before guidemo is made visible.
function guidemo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject handle to figure
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)
% varargin command line arguments to guidemo (see VARARGIN)

% Choose default command line output for guidemo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guidemo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guidemo_OutputFcn(hObject, eventdata, handles) 
% varargout cell array for returning output args (see VARARGOUT);
% hObject handle to figure
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Browse.
function Browse_Callback(hObject, eventdata, handles)
% hObject handle to Browse (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.*', 'Pick a video');
if isequal(filename,0) || isequal(pathname,0)
disp('User pressed cancel')
else

readerobj = VideoReader(filename, 'tag', 'myreader1');

% Read in all video frames.
vidFrames = read(readerobj);

% Get the number of frames.
numFrames = get(readerobj, 'NumberOfFrames');

% Create a MATLAB movie struct from the video frames.
for k = 1 : numFrames
mov(k).cdata = vidFrames(:,:,:,k);
mov(k).colormap = [];
end


% Resize figure based on the video's width and height

% Playback movie once at the video's frame rate
movie( mov, 1, readerobj.FrameRate);

handles.filename=filename;


end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in Frameseparation.
function Frameseparation_Callback(hObject, eventdata, handles)
% hObject handle to Frameseparation (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

filename=handles.filename;
readerobj = VideoReader(filename, 'tag', 'myreader1');

% Read in all video frames.

vidFrames = read(readerobj);

% Get the number of frames.
numFrames = get(readerobj, 'NumberOfFrames');
datatype='.jpg';
% Create a MATLAB movie struct from the video frames.
for k = 1 : numFrames

str=num2str(k);

mov(k).cdata = vidFrames(:,:,:,k);

mov(k).colormap = [];

Frame=mov(k).cdata;

Frame=rgb2gray(Frame);

imshow(Frame);

pause(0.1)

filename=strcat(str,datatype);

imwrite(Frame,filename);



end

warndlg('process completed');
% --- Executes on button press in videos.
function videos_Callback(hObject, eventdata, handles)
% hObject handle to videos (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)


number_of_frames=18;
filetype='.jpg';

str3='o'
Next=2;
cc=1;


for k = 1:18
out=[0 0 0];
statframe=imread('1.jpg');

% Write each frame to the file.
aa=k-1;
% PreviousFrame=strcat(num2str(aa),filetype);
CurrentFrame=strcat(num2str(k),filetype);
%PreviousFrame=imread(PreviousFrame);
CurrentFrame=imread(CurrentFrame);


imgOut1 = compensaterow(CurrentFrame);
imgOut2 = compensatecol(CurrentFrame);


MSE1 = CalculateMSE( imgOut1,statframe);
MSE2 = CalculateMSE( imgOut2,statframe);
MSE3 = CalculateMSE( CurrentFrame,statframe);

MSE1=round(MSE1);
MSE2=round(MSE2);

MSE3=round(MSE3);


out=[-MSE1,-MSE2,-MSE3];

[min,index]=max(out);


if index==1

outputfile=strcat(str3,num2str(aa),filetype);
imgOut1=uint8(imgOut1);
imwrite(imgOut1,outputfile);
elseif index==2
outputfile=strcat(str3,num2str(aa),filetype);
imgOut2=uint8(imgOut2);

imwrite(imgOut2,outputfile);

else
outputfile=strcat(str3,num2str(aa),filetype);
% 
imwrite(CurrentFrame,outputfile);


end
end

helpdlg('Video Stabilization completed');
% --- Executes on button press in playvideo.
function playvideo_Callback(hObject, eventdata, handles)
% hObject handle to playvideo (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)


str3='o'
Next=2;
cc=1;
filetype='.jpg'

for k = 1:17
% PreviousFrame=strcat(num2str(aa),filetype);
Frame=strcat(str3,num2str(k),filetype);

a=imread(Frame);
imshow(a);
pause(0.1);

end