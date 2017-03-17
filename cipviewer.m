function varargout = cipviewer(varargin)
% CIPVIEWER M-file for cipviewer.fig
%      CIPVIEWER, by itself, creates a new CIPVIEWER or raises the existing
%      singleton*.
%
%      H = CIPVIEWER returns the handle to a new CIPVIEWER or the handle to
%      the existing singleton*.
%
%      CIPVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CIPVIEWER.M with the given input arguments.
%
%      CIPVIEWER('Property','Value',...) creates a new CIPVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cipviewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cipviewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cipviewer

% Last Modified by GUIDE v2.5 15-Feb-2009 11:33:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cipviewer_OpeningFcn, ...
                   'gui_OutputFcn',  @cipviewer_OutputFcn, ...
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


% --- Executes just before cipviewer is made visible.
function cipviewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cipviewer (see VARARGIN)

% Choose default command line output for cipviewer
handles.output = hObject;

MainGUIInput = find(strcmp(varargin,'TSViewer'));
if(isempty(MainGUIInput) || (length(varargin) <= MainGUIInput) || ~ishandle(varargin{MainGUIInput+1}))
    disp('Improper command line entry.');
    disp('----------------------------');
    disp('Usage:');
    disp('    cipviewer TSViewer [handle]');
    delete(handles.cipviewer);
    handles.output = 0;
else
    handles.MainFigure = varargin{MainGUIInput+1};
    MainHandles = guidata(handles.MainFigure);
    handles.cdfhandle = MainHandles.cdfhandle;
    handles.time = handles.cdfhandle{'time'}(:);
        handles.timevec = handles.cdfhandle{'timevec'}(:);
    if(MainHandles.CIPLoad == 0)
       handles.Index = MainHandles.CIPIndex;
        handles.Path = MainHandles.Path;
       handles.FileName = MainHandles.FileName;
        
        ST = datestr(MainHandles.Times(1), 'HHMMSS');
        ET = datestr(MainHandles.Times(2), 'HHMMSS');
        set(handles.StartTime, 'String', ST);
        set(handles.EndTime, 'String', ET);
    
        %Look for instances of CIP variables
        handles.var_name = MainHandles.var_name{MainHandles.CIPIndex};
        handles.numVars = MainHandles.numVars(MainHandles.CIPIndex);
        handles.CIPVars = {};
        for i = 1:handles.numVars
            if(~isempty(strfind(handles.var_name{i}, 'CIP')))
                handles.CIPVars = [handles.CIPVars handles.var_name{i}];
            end
        end
        if(isempty(handles.CIPVars))
            errordlg('Please add a CIP variable to the selected plot before viewing CIP image.');
            delete(handles.cipviewer);
            handles.output = 0;
        else
            %To be changed when standard is developed
            [file, path] = uigetfile({'*.cdf', 'NetCDF Files (*.cdf)'}, 'Pick the appropriate image CDF')
            oldpath = pwd;
            if(isempty(strfind(file, 'caps')))
                errordlg('Invalid image file!');
                delete(handles.cipviewer);
                handles.output = 0;
            else
                cd(path)
                handles.imgcdf = netcdf(file, 'nowrite');
                handles.filename = file;
                handles.path = path;
                procfile = ['proc' file(5:end)]
                handles.proccdf = netcdf(procfile, 'nowrite');
                cd(oldpath);
                handles.hours = handles.imgcdf{'hour'};
                handles.minutes = handles.imgcdf{'minute'};
                handles.seconds = handles.imgcdf{'second'};
                handles.millisecs = handles.imgcdf{'millisec'};
        
                %Preload autoanalysis variables
                handles.ProcTime = handles.proccdf{'Time'}(:);
                handles.Reject = handles.proccdf{'image_auto_reject'}(:);
                handles.Length = handles.proccdf{'image_length'}(:);
                handles.FramePointers = handles.imgcdf{'FramePointers'}(:);
                handles.ParentRecNum = handles.proccdf{'parent_rec_num'}(:);
                if(isempty(handles.FramePointers))
                   handles.isCompressed = 0;
                else
                   handles.isCompressed = 1;
                end
                guidata(hObject, handles);
                start_time = get(handles.StartTime, 'String');
                end_time = get(handles.EndTime, 'String');
                StartVec = datevec(start_time, 'HHMMSS');
                EndVec = datevec(end_time, 'HHMMSS');
                StartHour = StartVec(4);
                StartMinute = StartVec(5);
                StartSec = StartVec(6);
                EndHour = EndVec(4);
                EndMinute = EndVec(5);
                EndSec = EndVec(6);
                HourSpot = find(handles.hours >= StartHour, 1, 'first');
                MinSpot = find(handles.minutes(HourSpot:end) >= StartMinute, 1, 'first');
                if(handles.minutes(MinSpot+HourSpot) == StartMinute)
                   SecSpot = find(handles.seconds(HourSpot+MinSpot:end) >= StartSec, 1, 'first');
                else
                   SecSpot = 0;
                end
    
                i1 = HourSpot+MinSpot+SecSpot;
    
                HourSpot = find(handles.hours >= EndHour, 1, 'first');
                MinSpot = find(handles.minutes(HourSpot:end) >= EndMinute, 1, 'first');
                if(handles.minutes(MinSpot+HourSpot) == EndMinute)
                   SecSpot = find(handles.seconds(HourSpot+MinSpot:end) >= EndSec, 1, 'first');
                else
                   SecSpot = 0;
                end
    
                i2 = HourSpot+MinSpot+SecSpot;
                handles.FrameWindow = [i1 i2];
                handles.CurFrame = i1;
                guidata(hObject, handles);
                %handles.BaseFrame = i1-1;
                %Generate movie array
                %for(i=0:(i2-i1))
                %    imageview(handles.ImgFrame1, handles.imgcdf, (handles.CurFrame+i));
                %    handles.movie(i+1) = getframe(handles.ImgFrame1);
                %end
                %handles.CurFrame = 1;
                set(handles.ImgFrame1, 'Visible', 'on');
                set(handles.ImgFrame2, 'Visible', 'on');
                set(handles.ImgFrame3, 'Visible', 'on');
                %set(handles.LoadingText, 'Visible', 'off');
                datestring1 = [num2str(handles.hours(handles.CurFrame), '%02i') ':' num2str(handles.minutes(handles.CurFrame), '%02i') ':' num2str(handles.seconds(handles.CurFrame), '%02i') '.' num2str(handles.millisecs(handles.CurFrame), '%03i')];
                %[image, Map] = frame2im(handles.movie(handles.CurFrame));
                imageview(handles.ImgFrame1, handles.FrameWindow(1), handles);
                axes(handles.ImgFrame1);
                %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
                axis off;
                title(handles.ImgFrame1, datestring1);
                imageview(handles.ImgFrame2, handles.FrameWindow(1)+1, handles);
                datestring2 = [num2str(handles.hours(handles.CurFrame+1), '%02i') ':' num2str(handles.minutes(handles.CurFrame+1), '%02i') ':' num2str(handles.seconds(handles.CurFrame+1), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+1), '%03i')];
                %[image, Map] = frame2im(handles.movie(handles.CurFrame+1));
                axes(handles.ImgFrame2);
                %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
                axis off;
                title(handles.ImgFrame2, datestring2);
                imageview(handles.ImgFrame3, handles.FrameWindow(1)+2, handles);
                datestring3 = [num2str(handles.hours(handles.CurFrame+2), '%02i') ':' num2str(handles.minutes(handles.CurFrame+2), '%02i') ':' num2str(handles.seconds(handles.CurFrame+2), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+2), '%03i')];
                %[image, Map] = frame2im(handles.movie(handles.CurFrame+2));
                axes(handles.ImgFrame3);
                %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
                axis off;
                title(handles.ImgFrame3, datestring3);
                %imageview(handles.ImgFrame4, handles.imgcdf, 4);
                %imageview(handles.ImgFrame5, handles.imgcdf, 5);
                hold all;
                StartIndex = find(handles.time == str2double(start_time));
                EndIndex = find(handles.time == str2double(end_time));
                for(i=1:numel(handles.CIPVars))
                    X = handles.cdfhandle{handles.CIPVars{i}}(StartIndex:EndIndex);
                    T = handles.cdfhandle{'timevec'}(StartIndex:EndIndex);
                    plot(handles.CIPDataAxes, T, X);
                end
                hold all;
                axes(handles.CIPDataAxes);
                title('CIP Data');
                xlabel('Time');
                ylabel(handles.cdfhandle{handles.CIPVars{1}}.units(:));
           
                datetick(handles.CIPDataAxes, 'x', 'HH:MM:SS');
       
                timestring = [num2str(handles.hours(handles.CurFrame), '%02i') num2str(handles.minutes(handles.CurFrame), '%02i') num2str(handles.seconds(handles.CurFrame), '%02i')];
                linex = handles.timevec(find(handles.time == str2double(timestring)));
                handles.marker = line([linex linex], get(gca, 'YLim'));
                handles.isPlaying = 0; 
                handles.FramesPerSecond = 30;
            end    
        end
    else
        set(handles.StartTime, 'String', MainHandles.CIP_StartTime);
        set(handles.EndTime, 'String', MainHandles.CIP_EndTime);
        set(handles.FlagColorBox, 'Value', MainHandles.CIP_FlagColorBox);
        handles.FrameWindow = MainHandles.CIP_FrameWindow;
        handles.CurFrame = MainHandles.CIP_CurFrame;
        handles.CIPVars = MainHandles.CIP_Vars;
        handles.filename = MainHandles.CIP_filename;
        handles.path = MainHandles.CIP_path;
        oldpath = pwd;
        cd(handles.path)
        handles.imgcdf = netcdf(handles.filename, 'nowrite');
            
        procfile = ['proc' handles.filename(5:end)]
        handles.proccdf = netcdf(procfile, 'nowrite');
        cd(oldpath);
        handles.hours = handles.imgcdf{'hour'};
        handles.minutes = handles.imgcdf{'minute'};
        handles.seconds = handles.imgcdf{'second'};
        handles.millisecs = handles.imgcdf{'millisec'};
        
        %Preload autoanalysis variables
        handles.ProcTime = handles.proccdf{'Time'}(:);
        handles.Reject = handles.proccdf{'image_auto_reject'}(:);
        handles.Length = handles.proccdf{'image_length'}(:);
        handles.FramePointers = handles.imgcdf{'FramePointers'}(:);
        handles.ParentRecNum = handles.proccdf{'parent_rec_num'}(:);
        if(isempty(handles.FramePointers))
               handles.isCompressed = 0;
        else
               handles.isCompressed = 1;
        end
        set(handles.ImgFrame1, 'Visible', 'on');
        set(handles.ImgFrame2, 'Visible', 'on');
        set(handles.ImgFrame3, 'Visible', 'on');
        %set(handles.LoadingText, 'Visible', 'off');
        datestring1 = [num2str(handles.hours(handles.CurFrame), '%02i') ':' num2str(handles.minutes(handles.CurFrame), '%02i') ':' num2str(handles.seconds(handles.CurFrame), '%02i') '.' num2str(handles.millisecs(handles.CurFrame), '%03i')];
        %[image, Map] = frame2im(handles.movie(handles.CurFrame));
        imageview(handles.ImgFrame1, handles.FrameWindow(1), handles);
        axes(handles.ImgFrame1);
        %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
        axis off;
        title(handles.ImgFrame1, datestring1);
        imageview(handles.ImgFrame2, handles.FrameWindow(1)+1, handles);
        datestring2 = [num2str(handles.hours(handles.CurFrame+1), '%02i') ':' num2str(handles.minutes(handles.CurFrame+1), '%02i') ':' num2str(handles.seconds(handles.CurFrame+1), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+1), '%03i')];
        %[image, Map] = frame2im(handles.movie(handles.CurFrame+1));
        axes(handles.ImgFrame2);
        %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
        axis off;
        title(handles.ImgFrame2, datestring2);
        imageview(handles.ImgFrame3, handles.FrameWindow(1)+2, handles);
        datestring3 = [num2str(handles.hours(handles.CurFrame+2), '%02i') ':' num2str(handles.minutes(handles.CurFrame+2), '%02i') ':' num2str(handles.seconds(handles.CurFrame+2), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+2), '%03i')];
        %[image, Map] = frame2im(handles.movie(handles.CurFrame+2));
        axes(handles.ImgFrame3);
        %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
        axis off;
        title(handles.ImgFrame3, datestring3);
        %imageview(handles.ImgFrame4, handles.imgcdf, 4);
        %imageview(handles.ImgFrame5, handles.imgcdf, 5);
        StartIndex = find(handles.time == str2double(get(handles.StartTime, 'String')));
        EndIndex = find(handles.time == str2double(get(handles.EndTime, 'String')));
        for(i=1:numel(handles.CIPVars))
                X = handles.cdfhandle{handles.CIPVars{i}}(StartIndex:EndIndex);
                T = handles.cdfhandle{'timevec'}(StartIndex:EndIndex);
                plot(handles.CIPDataAxes, T, X);
        end
        hold all;
        axes(handles.CIPDataAxes);
        title('CIP Data');
        xlabel('Time');
        ylabel(handles.cdfhandle{handles.CIPVars{1}}.units(:));
           
        datetick(handles.CIPDataAxes, 'x', 'HH:MM:SS');
       
        timestring = [num2str(handles.hours(handles.CurFrame), '%02i') num2str(handles.minutes(handles.CurFrame), '%02i') num2str(handles.seconds(handles.CurFrame), '%02i')];
        linex = handles.timevec(find(handles.time == str2double(timestring)));
        handles.marker = line([linex linex], get(gca, 'YLim'));
        handles.isPlaying = 0; 
        handles.FramesPerSecond = 30;
    end
    
    guidata(hObject, handles);
    handles.output = hObject; 
end
        

% Update handles structure
%guidata(hObject, handles);

% UIWAIT makes cipviewer wait for user response (see UIRESUME)
% uiwait(handles.cipviewer);

function [i1 i2] = SearchFrame(start_time, end_time)

handles = guidata(gcbo);
StartVec = datevec(start_time, 'HHMMSS');
EndVec = datevec(end_time, 'HHMMSS');
StartHour = StartVec(4);
StartMinute = StartVec(5);
StartSec = StartVec(6);
EndHour = EndVec(4);
EndMinute = EndVec(5);
EndSec = EndVec(6);
HourSpot = find(handles.hours >= StartHour, 1, 'first');
MinSpot = find(handles.minutes(HourSpot:end) >= StartMinute, 1, 'first');
if(handles.minutes(MinSpot+HourSpot) == StartMinute)
    SecSpot = find(handles.seconds(HourSpot+MinSpot:end) >= StartSec, 1, 'first');
else
    SecSpot = 0;
end

i1 = HourSpot+MinSpot+SecSpot;

HourSpot = find(handles.hours >= EndHour, 1, 'first');
MinSpot = find(handles.minutes(HourSpot:end) >= EndMinute, 1, 'first');
if(handles.minutes(MinSpot+HourSpot) == StartMinute)
    SecSpot = find(handles.seconds(HourSpot+MinSpot:end) >= EndSec, 1, 'first');
else
    SecSpot = 0;
end

i2 = HourSpot+MinSpot+SecSpot;

% --- Outputs from this function are returned to the command line.
function varargout = cipviewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if(~isempty(handles))
    varargout{1} = handles.output;
else
    varargout{1} = 0;
end




% --- Executes on button press in PlayButton.
function PlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.isPlaying = 1;
isPlaying = 1;

handles.CurPlayFrame = handles.FrameWindow(1);
while(isPlaying == 1 && (handles.CurPlayFrame ~= handles.FrameWindow(2)) && (isequal(get(handles.StopButton, 'SelectionHighlight'), 'off')))
    imageview(handles.ImgFrame1, handles.CurPlayFrame, handles);
    handles.CurPlayFrame = handles.CurPlayFrame + 1;
    timestring = [num2str(handles.hours(handles.CurPlayFrame), '%02i') num2str(handles.minutes(handles.CurPlayFrame), '%02i') num2str(handles.seconds(handles.CurPlayFrame), '%02i')];
    linex = handles.timevec(find(handles.time == str2double(timestring)));
    delete(handles.marker);
    axes(handles.CIPDataAxes);
    handles.marker = line([linex linex], get(gca, 'YLim'));
    guidata(hObject, handles);
    drawnow;
    handles = guidata(handles.StopButton);
    isPlaying = handles.isPlaying;
end

handles.isPlaying = 0;
datestring1 = [num2str(handles.hours(handles.CurFrame), '%02i') ':' num2str(handles.minutes(handles.CurFrame), '%02i') ':' num2str(handles.seconds(handles.CurFrame), '%02i') '.' num2str(handles.millisecs(handles.CurFrame), '%03i')];
imageview(handles.ImgFrame1, handles.CurFrame, handles);
axis off;
timestring = [num2str(handles.hours(handles.CurFrame), '%02i') num2str(handles.minutes(handles.CurFrame), '%02i') num2str(handles.seconds(handles.CurFrame), '%02i')];
linex = handles.timevec(find(handles.time == str2double(timestring)));
if(ishandle(handles.marker))
    delete(handles.marker);
end
axes(handles.CIPDataAxes);
handles.marker = line([linex linex], get(gca, 'YLim'));
set(handles.StopButton, 'SelectionHighlight', 'off');
guidata(hObject, handles);
    
% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)
% hObject    handle to StopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'SelectionHighlight', 'on');

% --- Executes on button press in FwdButton.
function FwdButton_Callback(hObject, eventdata, handles)
% hObject    handle to FwdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if((handles.CurFrame+1 < (handles.FrameWindow(2))) && (handles.isPlaying == 0))
    cla(handles.ImgFrame1);
    cla(handles.ImgFrame2);
    cla(handles.ImgFrame3);
    handles.CurFrame = handles.CurFrame + 1;
    guidata(hObject, handles);
    datestring1 = [num2str(handles.hours(handles.CurFrame), '%02i') ':' num2str(handles.minutes(handles.CurFrame), '%02i') ':' num2str(handles.seconds(handles.CurFrame), '%02i') '.' num2str(handles.millisecs(handles.CurFrame), '%03i')];
    %[image, Map] = frame2im(handles.movie(handles.CurFrame));
    axes(handles.ImgFrame1);
    %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
    imageview(handles.ImgFrame1, handles.CurFrame, handles);
    axis off;
    title(handles.ImgFrame1, datestring1);
    imageview(handles.ImgFrame2, handles.CurFrame+1, handles);
    datestring2 = [num2str(handles.hours(handles.CurFrame+1), '%02i') ':' num2str(handles.minutes(handles.CurFrame+1), '%02i') ':' num2str(handles.seconds(handles.CurFrame+1), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+1), '%03i')];
    %[image, Map] = frame2im(handles.movie(handles.CurFrame+1));
    axes(handles.ImgFrame2);
    %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
    axis off;
    title(handles.ImgFrame2, datestring2);
    imageview(handles.ImgFrame3, handles.CurFrame+2, handles);
    datestring3 = [num2str(handles.hours(handles.CurFrame+2), '%02i') ':' num2str(handles.minutes(handles.CurFrame+2), '%02i') ':' num2str(handles.seconds(handles.CurFrame+2), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+2), '%03i')];
    %[image, Map] = frame2im(handles.movie(handles.CurFrame+2));
    axes(handles.ImgFrame3);
    %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
    axis off;
    title(handles.ImgFrame3, datestring3);
    timestring = [num2str(handles.hours(handles.CurFrame), '%02i') num2str(handles.minutes(handles.CurFrame), '%02i') num2str(handles.seconds(handles.CurFrame), '%02i')];
    linex = handles.timevec(find(handles.time == str2double(timestring)));
    delete(handles.marker);
    axes(handles.CIPDataAxes);
    handles.marker = line([linex linex], get(gca, 'YLim'));
    handles.isPlaying = 0; 
end
guidata(hObject, handles);

% --- Executes on button press in RevButton.
function RevButton_Callback(hObject, eventdata, handles)
% hObject    handle to RevButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if((handles.CurFrame > handles.FrameWindow(1)) && (handles.isPlaying == 0))
    handles.CurFrame = handles.CurFrame - 1;
    cla(handles.ImgFrame1);
    cla(handles.ImgFrame2);
    cla(handles.ImgFrame3);
    guidata(hObject, handles);
    %imageview(handles.ImgFrame1, handles.imgcdf, handles.CurFrame);
    datestring1 = [num2str(handles.hours(handles.CurFrame), '%02i') ':' num2str(handles.minutes(handles.CurFrame), '%02i') ':' num2str(handles.seconds(handles.CurFrame), '%02i') '.' num2str(handles.millisecs(handles.CurFrame), '%03i')];
    %[image, Map] = frame2im(handles.movie(handles.CurFrame));
    axes(handles.ImgFrame1);
    %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
    imageview(handles.ImgFrame1, handles.CurFrame, handles);
    axis off;
    title(handles.ImgFrame1, datestring1);
    imageview(handles.ImgFrame2, handles.CurFrame+1, handles);
    datestring2 = [num2str(handles.hours(handles.CurFrame+1), '%02i') ':' num2str(handles.minutes(handles.CurFrame+1), '%02i') ':' num2str(handles.seconds(handles.CurFrame+1), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+1), '%03i')];
    %[image, Map] = frame2im(handles.movie(handles.CurFrame+1));
    axes(handles.ImgFrame2);
    %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
    axis off;
    title(handles.ImgFrame2, datestring2);
    imageview(handles.ImgFrame3, handles.CurFrame+2, handles);
    datestring3 = [num2str(handles.hours(handles.CurFrame+2), '%02i') ':' num2str(handles.minutes(handles.CurFrame+2), '%02i') ':' num2str(handles.seconds(handles.CurFrame+2), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+2), '%03i')];
    %[image, Map] = frame2im(handles.movie(handles.CurFrame+2));
    axes(handles.ImgFrame3);
    %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
    axis off;
    title(handles.ImgFrame3, datestring3);
    timestring = [num2str(handles.hours(handles.CurFrame), '%02i') num2str(handles.minutes(handles.CurFrame), '%02i') num2str(handles.seconds(handles.CurFrame), '%02i')];
    linex = handles.timevec(find(handles.time == str2double(timestring)));
    delete(handles.marker);
    axes(handles.CIPDataAxes);
    handles.marker = line([linex linex], get(gca, 'YLim'));
    handles.isPlaying = 0; 
end
guidata(hObject, handles);
% --- Executes on button press in FlagColorBox.
function FlagColorBox_Callback(hObject, eventdata, handles)
% hObject    handle to FlagColorBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FlagColorBox
cla(handles.ImgFrame1);
cla(handles.ImgFrame2);
cla(handles.ImgFrame3);
guidata(hObject, handles);
%imageview(handles.ImgFrame1, handles.imgcdf, handles.CurFrame);
datestring1 = [num2str(handles.hours(handles.CurFrame), '%02i') ':' num2str(handles.minutes(handles.CurFrame), '%02i') ':' num2str(handles.seconds(handles.CurFrame), '%02i') '.' num2str(handles.millisecs(handles.CurFrame), '%03i')];
%[image, Map] = frame2im(handles.movie(handles.CurFrame));
axes(handles.ImgFrame1);
%imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
imageview(handles.ImgFrame1, handles.CurFrame, handles);
axis off;
title(handles.ImgFrame1, datestring1);
imageview(handles.ImgFrame2, handles.CurFrame+1, handles);
datestring2 = [num2str(handles.hours(handles.CurFrame+1), '%02i') ':' num2str(handles.minutes(handles.CurFrame+1), '%02i') ':' num2str(handles.seconds(handles.CurFrame+1), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+1), '%03i')];
%[image, Map] = frame2im(handles.movie(handles.CurFrame+1));
axes(handles.ImgFrame2);
%imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
axis off;
title(handles.ImgFrame2, datestring2);
imageview(handles.ImgFrame3, handles.CurFrame+2, handles);
datestring3 = [num2str(handles.hours(handles.CurFrame+2), '%02i') ':' num2str(handles.minutes(handles.CurFrame+2), '%02i') ':' num2str(handles.seconds(handles.CurFrame+2), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+2), '%03i')];
%[image, Map] = frame2im(handles.movie(handles.CurFrame+2));
axes(handles.ImgFrame3);
%imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
axis off;
title(handles.ImgFrame3, datestring3);
timestring = [num2str(handles.hours(handles.CurFrame), '%02i') num2str(handles.minutes(handles.CurFrame), '%02i') num2str(handles.seconds(handles.CurFrame), '%02i')];
linex = handles.timevec(find(handles.time == str2double(timestring)));
delete(handles.marker);
axes(handles.CIPDataAxes);
handles.marker = line([linex linex], get(gca, 'YLim'));
handles.isPlaying = 0; 
guidata(hObject, handles);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.FramesPerSecond = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function StartTime_Callback(hObject, eventdata, handles)
% hObject    handle to StartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartTime as text
%        str2double(get(hObject,'String')) returns contents of StartTime as a double

    start_time = get(hObject, 'String');
        end_time = get(handles.EndTime, 'String');
        StartVec = datevec(start_time, 'HHMMSS');
        EndVec = datevec(end_time, 'HHMMSS');
        StartHour = StartVec(4);
        StartMinute = StartVec(5);
        StartSec = StartVec(6);
        EndHour = EndVec(4);
        EndMinute = EndVec(5);
        EndSec = EndVec(6);
        HourSpot = find(handles.hours >= StartHour, 1, 'first');
        MinSpot = find(handles.minutes(HourSpot:end) >= StartMinute, 1, 'first');
        if(handles.minutes(MinSpot+HourSpot) == StartMinute)
            SecSpot = find(handles.seconds(HourSpot+MinSpot:end) >= StartSec, 1, 'first');
        else
            SecSpot = 0;
        end

        i1 = HourSpot+MinSpot+SecSpot;

        HourSpot = find(handles.hours >= EndHour, 1, 'first');
        MinSpot = find(handles.minutes(HourSpot:end) >= EndMinute, 1, 'first');
        if(handles.minutes(MinSpot+HourSpot) == EndMinute)
            SecSpot = find(handles.seconds(HourSpot+MinSpot:end) >= EndSec, 1, 'first');
        else
            SecSpot = 0;
        end

        i2 = HourSpot+MinSpot+SecSpot;
        handles.FrameWindow = [i1 i2]
        handles.CurFrame = i1;

    cla(handles.ImgFrame1);
    cla(handles.ImgFrame2);
    cla(handles.ImgFrame3);
    guidata(hObject, handles);
    %imageview(handles.ImgFrame1, handles.imgcdf, handles.CurFrame);
    datestring1 = [num2str(handles.hours(handles.CurFrame), '%02i') ':' num2str(handles.minutes(handles.CurFrame), '%02i') ':' num2str(handles.seconds(handles.CurFrame), '%02i') '.' num2str(handles.millisecs(handles.CurFrame), '%03i')];
    %[image, Map] = frame2im(handles.movie(handles.CurFrame));
    axes(handles.ImgFrame1);
    %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
    imageview(handles.ImgFrame1, handles.CurFrame, handles);
    axis off;
    title(handles.ImgFrame1, datestring1);
    imageview(handles.ImgFrame2, handles.CurFrame+1, handles);
    datestring2 = [num2str(handles.hours(handles.CurFrame+1), '%02i') ':' num2str(handles.minutes(handles.CurFrame+1), '%02i') ':' num2str(handles.seconds(handles.CurFrame+1), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+1), '%03i')];
    %[image, Map] = frame2im(handles.movie(handles.CurFrame+1));
    axes(handles.ImgFrame2);
    %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
    axis off;
    title(handles.ImgFrame2, datestring2);
    imageview(handles.ImgFrame3, handles.CurFrame+2, handles);
    datestring3 = [num2str(handles.hours(handles.CurFrame+2), '%02i') ':' num2str(handles.minutes(handles.CurFrame+2), '%02i') ':' num2str(handles.seconds(handles.CurFrame+2), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+2), '%03i')];
    %[image, Map] = frame2im(handles.movie(handles.CurFrame+2));
    axes(handles.ImgFrame3);
    %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
    axis off;
    title(handles.ImgFrame3, datestring3);
    
    handles.isPlaying = 0; 
    StartIndex = find(handles.time == str2double(start_time));
    EndIndex = find(handles.time == str2double(end_time));
    for(i=1:numel(handles.CIPVars))
            X = handles.cdfhandle{handles.CIPVars{i}}(StartIndex:EndIndex);
            T = handles.cdfhandle{'timevec'}(StartIndex:EndIndex);
            plot(handles.CIPDataAxes, T, X);
    end
    axes(handles.CIPDataAxes);
    title('CIP Data');
    xlabel('Time');
    ylabel(handles.cdfhandle{handles.CIPVars{1}}.units(:));
        
    datetick(handles.CIPDataAxes, 'x', 'HH:MM:SS');
    timestring = [num2str(handles.hours(handles.CurFrame), '%02i') num2str(handles.minutes(handles.CurFrame), '%02i') num2str(handles.seconds(handles.CurFrame), '%02i')];
    linex = handles.timevec(find(handles.time == str2double(timestring)));
    %delete(handles.marker);
    axes(handles.CIPDataAxes);
    handles.marker = line([linex linex], get(gca, 'YLim'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function StartTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EndTime_Callback(hObject, eventdata, handles)
% hObject    handle to EndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EndTime as text
%        str2double(get(hObject,'String')) returns contents of EndTime as a double
    start_time = get(handles.StartTime, 'String');
        end_time = get(hObject, 'String');
        StartVec = datevec(start_time, 'HHMMSS');
        EndVec = datevec(end_time, 'HHMMSS');
        StartHour = StartVec(4);
        StartMinute = StartVec(5);
        StartSec = StartVec(6);
        EndHour = EndVec(4);
        EndMinute = EndVec(5);
        EndSec = EndVec(6);
        HourSpot = find(handles.hours >= StartHour, 1, 'first');
        MinSpot = find(handles.minutes(HourSpot:end) >= StartMinute, 1, 'first');
        if(handles.minutes(MinSpot+HourSpot) == StartMinute)
            SecSpot = find(handles.seconds(HourSpot+MinSpot:end) >= StartSec, 1, 'first');
        else
            SecSpot = 0;
        end

        i1 = HourSpot+MinSpot+SecSpot;

        HourSpot = find(handles.hours >= EndHour, 1, 'first');
        MinSpot = find(handles.minutes(HourSpot:end) >= EndMinute, 1, 'first');
        if(handles.minutes(MinSpot+HourSpot) == EndMinute)
            SecSpot = find(handles.seconds(HourSpot+MinSpot:end) >= EndSec, 1, 'first');
        else
            SecSpot = 0;
        end

        i2 = HourSpot+MinSpot+SecSpot;
        handles.FrameWindow = [i1 i2]
        handles.CurFrame = i1;

    cla(handles.ImgFrame1);
    cla(handles.ImgFrame2);
    cla(handles.ImgFrame3);
    guidata(hObject, handles);
    %imageview(handles.ImgFrame1, handles.imgcdf, handles.CurFrame);
    datestring1 = [num2str(handles.hours(handles.CurFrame), '%02i') ':' num2str(handles.minutes(handles.CurFrame), '%02i') ':' num2str(handles.seconds(handles.CurFrame), '%02i') '.' num2str(handles.millisecs(handles.CurFrame), '%03i')];
    %[image, Map] = frame2im(handles.movie(handles.CurFrame));
    axes(handles.ImgFrame1);
    %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
    imageview(handles.ImgFrame1, handles.CurFrame, handles);
    axis off;
    title(handles.ImgFrame1, datestring1);
    imageview(handles.ImgFrame2, handles.CurFrame+1, handles);
    datestring2 = [num2str(handles.hours(handles.CurFrame+1), '%02i') ':' num2str(handles.minutes(handles.CurFrame+1), '%02i') ':' num2str(handles.seconds(handles.CurFrame+1), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+1), '%03i')];
    %[image, Map] = frame2im(handles.movie(handles.CurFrame+1));
    axes(handles.ImgFrame2);
    %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
    axis off;
    title(handles.ImgFrame2, datestring2);
    imageview(handles.ImgFrame3, handles.CurFrame+2, handles);
    datestring3 = [num2str(handles.hours(handles.CurFrame+2), '%02i') ':' num2str(handles.minutes(handles.CurFrame+2), '%02i') ':' num2str(handles.seconds(handles.CurFrame+2), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+2), '%03i')];
    %[image, Map] = frame2im(handles.movie(handles.CurFrame+2));
    axes(handles.ImgFrame3);
    %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
    axis off;
    title(handles.ImgFrame3, datestring3);
    
    handles.isPlaying = 0; 
    StartIndex = find(handles.time == str2double(start_time));
    EndIndex = find(handles.time == str2double(end_time));
    for(i=1:numel(handles.CIPVars))
            X = handles.cdfhandle{handles.CIPVars{i}}(StartIndex:EndIndex);
            T = handles.cdfhandle{'timevec'}(StartIndex:EndIndex);
            plot(handles.CIPDataAxes, T, X);
    end
    axes(handles.CIPDataAxes);
    title('CIP Data');
    xlabel('Time');
    ylabel(handles.cdfhandle{handles.CIPVars{1}}.units(:));
    timestring = [num2str(handles.hours(handles.CurFrame), '%02i') num2str(handles.minutes(handles.CurFrame), '%02i') num2str(handles.seconds(handles.CurFrame), '%02i')];
    linex = handles.timevec(find(handles.time == str2double(timestring)));
    %delete(handles.marker);
    axes(handles.CIPDataAxes);
    handles.marker = line([linex linex], get(gca, 'YLim'));
        
    datetick(handles.CIPDataAxes, 'x', 'HH:MM:SS');
    
    
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EndTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function temp = imageview(axes_handle, frame, handles)

FlagColorMap = [1 1 1; 0 0 0; 1 0 0; 0 1 0; 0 0 1; 0 1 1];
%handles=guidata(gcbf);
if(handles.isCompressed == 0)
    imagedata = handles.imgcdf{'data'}(frame, :, :);
    dims = size(imagedata);
    newimage = zeros(dims(1), dims(2)*8);
else
    y = length(handles.imgcdf('ImgBlocklen'));
    z = length(handles.imgcdf('ImgRowlen'));
    numFrames = length(handles.FramePointers);
    if(frame~=numFrames)
        compframe = handles.imgcdf{'data'}(handles.FramePointers(frame):(handles.FramePointers(frame+1))-1);
    else
        compframe = handles.imgcdf{'data'}(handles.FramePointers(frame):end);
    end
    uncompframe = rleunshrink(int16(compframe));
    imagedata = double(reshape(uncompframe, y, z));
    dims = [y z];
end
i = 1;
k = 2;
y = 1;
endslice = [170 170 170 170 170 170 170 170];
invalidslice = [-1 -1 -1 -1 -1 -1 -1 -1];


NormalColor = 5;
FlagRejectColor = 3;
FlagHollowColor = 4;



% Find the first autoanalysis entry associated with this image

timeentry = handles.imgcdf{'hour'}(frame)*10000 + handles.imgcdf{'minute'}(frame)*100 + handles.imgcdf{'second'}(frame);
particlepos = find(handles.ProcTime == timeentry,1);
plength = handles.Length(particlepos);
p = 0;

if(get(handles.FlagColorBox, 'Value') == 1.0)
        CurColor = FlagRejectColor;
        if(handles.Reject(particlepos) == 48)
            CurColor = NormalColor;
%            disp('Normal');
        end
        if(handles.Reject(particlepos) == 72 || handles.Reject(particlepos) == 104)
            CurColor = FlagHollowColor;
%            disp('Hollow');
        end
else
        CurColor = 2;
end
while(k<dims(1))
    
            
    % Get particle header first
    %particleno = uint8(imagedata(k, 1:2));
    %date = uint8(imagedata(k, 3:7));
    %slicecount = bitshift(uint8(imagedata(k,8)), -1);
    %slicecount = mod(uint8(imagedata(k,8)), 128)
    if(imagedata(k, :) ~= endslice)
        if(imagedata(k, :) ~= invalidslice)
           
           for(i=1:dims(2))        
            for(j=1:8)
               if(imagedata(k, i) == -1)
                   newimage(y, (i-1)*8+j) = FlagRejectColor;
               else                  
                   newimage(y, (i-1)*8+j) = CurColor-CurColor*bitget(uint8(imagedata(k, i)), 9-j);
               end    
            end
           end 
           y = y + 1;
           p = p + 1;
        else
           k
           k = dims(1);
        end 
         k = k + 1;
    else
        if(p >= plength)
            %If the next particle is not in the frame, end the drawing
            newimage(y, :) = 6;
            y = y + 1;
            k = k + 2;
            p = 0;
            particlepos = particlepos + 1;
            
            %if(handles.ParentRecNum(particlepos) ~= frame)
            %    k
            %    k = dims(1);
            %    y = y - 1;
            %end
            plength = handles.Length(particlepos);
            if(get(handles.FlagColorBox, 'Value') == 1.0)
                CurColor = FlagRejectColor;
                if(handles.Reject(particlepos) == 48)
                  CurColor = NormalColor;
                %  disp('Normal');
                end
                if(handles.Reject(particlepos) == 72 || handles.Reject(particlepos) == 104)
                  CurColor = FlagHollowColor;
                %  disp('Hollow');
                end
                %if(CurColor == FlagRejectColor)
                %    disp('Reject');
                %end
            else
               CurColor = 2;
            end
        else
            k = k + 2;
            p = p + 1;
        end
    end
    
    
    
    
end


ni = newimage(1:y,:);
axes(axes_handle);
colormap(FlagColorMap);
imagesc(get(axes_handle, 'XLim'), get(axes_handle, 'YLim'), ni', [1 6]);
axis off;


% --- Executes on button press in JPEGButton.
function JPEGButton_Callback(hObject, eventdata, handles)
% hObject    handle to JPEGButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uiputfile({'*.jpg;', 'JPEG Images (*.jpg)'}, 'Select a destination JPEG file');
oldpath = pwd;

if ~isequal(file, 0)
    figure;
    subplot(3,1,1);
    datestring1 = [num2str(handles.hours(handles.CurFrame), '%02i') ':' num2str(handles.minutes(handles.CurFrame), '%02i') ':' num2str(handles.seconds(handles.CurFrame), '%02i') '.' num2str(handles.millisecs(handles.CurFrame), '%03i')];
    %[image, Map] = frame2im(handles.movie(handles.CurFrame));
    %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
    imageview(gca, handles.CurFrame, handles);
    axis off;
    title(datestring1);
    subplot(3,1,2);
    imageview(gca, handles.CurFrame+1, handles);
    datestring2 = [num2str(handles.hours(handles.CurFrame+1), '%02i') ':' num2str(handles.minutes(handles.CurFrame+1), '%02i') ':' num2str(handles.seconds(handles.CurFrame+1), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+1), '%03i')];
    %[image, Map] = frame2im(handles.movie(handles.CurFrame+1));
    
    %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
    axis off;
    title(datestring2);
    subplot(3,1,3);
    imageview(gca, handles.CurFrame+2, handles);
    datestring3 = [num2str(handles.hours(handles.CurFrame+2), '%02i') ':' num2str(handles.minutes(handles.CurFrame+2), '%02i') ':' num2str(handles.seconds(handles.CurFrame+2), '%02i') '.' num2str(handles.millisecs(handles.CurFrame+2), '%03i')];
    %[image, Map] = frame2im(handles.movie(handles.CurFrame+2));
    %imagesc(get(gca, 'XLim'), get(gca, 'YLim'), image);
    axis off;
    title(datestring3);
    handles.isPlaying = 0; 
    cd(path);
    print(gcf, '-djpeg', file);
    cd(oldpath);
end    


% --- Executes on button press in MovieAVISaveButton.
function MovieAVISaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to MovieAVISaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uiputfile({'*.avi;', 'AVI Movies (*.avi)'}, 'Select a destination AVI file');
oldpath = pwd;

if ~isequal(file, 0)
    figure;
    cd(path)
    moviefile = avifile(file, 'fps', 2);
    cd(oldpath);
    axes('position', [.05 .4 .9 .2]);
    for(i=handles.FrameWindow(1):(handles.FrameWindow(2)-1))  
        imageview(gca, i, handles);
        datestring1 = [num2str(handles.hours(i), '%02i') ':' num2str(handles.minutes(i), '%02i') ':' num2str(handles.seconds(i), '%02i') '.' num2str(handles.millisecs(i), '%03i')];
        title(datestring1);
        moviefile = addframe(moviefile, gca);
    end
    moviefile = close(moviefile);
end    