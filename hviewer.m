function varargout = hviewer(varargin)
% HVIEWER M-file for hviewer.fig
%      HVIEWER, by itself, creates a new HVIEWER or raises the existing
%      singleton*.
%
%      H = HVIEWER returns the handle to a new HVIEWER or the handle to
%      the existing singleton*.
%
%      HVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HVIEWER.M with the given input arguments.
%
%      HVIEWER('Property','Value',...) creates a new HVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hviewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hviewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help hviewer

% Last Modified by GUIDE v2.5 12-Jan-2009 14:27:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @hviewer_OpeningFcn, ...
                   'gui_OutputFcn',  @hviewer_OutputFcn, ...
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


% --- Executes just before hviewer is made visible.
function hviewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to hviewer (see VARARGIN)

% Choose default command line output for hviewer
handles.output = hObject;

MainGUIInput = find(strcmp(varargin,'TSViewer'));
if(isempty(MainGUIInput) || (length(varargin) <= MainGUIInput) || ~ishandle(varargin{MainGUIInput+1}))
    disp('Improper command line entry.');
    disp('----------------------------');
    disp('Usage:');
    disp('    hviewer TSViewer [handle]');
    delete(handles.hviewer);
    handles.output = 0;
else
    handles.MainFigure = varargin{MainGUIInput+1};
    MainHandles = guidata(handles.MainFigure);
    handles.cdfhandle = MainHandles.cdfhandle;
    handles.ProbeLongNames = MainHandles.ProbeLongNames;
    handles.ProbeShortNames = MainHandles.ProbeShortNames;
    handles.ProbeNames = MainHandles.Probes;
    handles.timevec = handles.cdfhandle{'timevec'}(:);
    handles.times = handles.cdfhandle{'time'}(:);
    handles.height = handles.cdfhandle{'PALT'}(:);
    if(MainHandles.HLoad == 0)
        handles.var_names = MainHandles.var_name{MainHandles.HVIndex};
        handles.long_names = MainHandles.long_names{MainHandles.HVIndex};
        handles.short_names = MainHandles.short_names{MainHandles.HVIndex};
        handles.numVars = MainHandles.numVars(MainHandles.HVIndex);
        handles.aveWindow = 1;      
        StartIndex = find(handles.times == str2double(datestr(MainHandles.Times(1), 'HHMMSS')));
        EndIndex = find(handles.times == str2double(datestr(MainHandles.Times(2), 'HHMMSS')));
        set(handles.StartTime, 'String', datestr(MainHandles.Times(1), 'HHMMSS'));
        set(handles.EndTime, 'String', datestr(MainHandles.Times(2), 'HHMMSS'));
        height = handles.height(StartIndex:EndIndex);
        hold all;
    
        for i = 1:MainHandles.numVars(MainHandles.HVIndex)
            N = handles.cdfhandle{handles.var_names{i}}(StartIndex:EndIndex)
            aveN = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N); 
            plot(aveN, height);      
        end
        hold off;
        set(handles.HVAxes, 'YLim', [min(height) max(height)], 'XScale', 'log');
        X = get(handles.HVAxes, 'XLim');
        H = get(handles.HVAxes, 'YLim');
        %Xtick = 10.^(linspace(log10(X(1)), log10(X(2)), 4));
        %Htick = 10.^(linspace(log10(H(1)), log10(H(2)), 4));
        set(handles.HVAxes, 'XMinorTick', 'on', 'YMinorTick', 'on');
        set(handles.XMin, 'String', num2str(X(1)));
        set(handles.HMin, 'String', num2str(H(1)));
        set(handles.XMax, 'String', num2str(X(2)));
        set(handles.HMax, 'String', num2str(H(2)));
        xlabel(handles.cdfhandle{handles.var_names{1}}.units(:));
        ylabel(['Height (' handles.cdfhandle{'PALT'}.units(:) ')']);
        title('Probe Measurements vs. Height');
        legend(handles.short_names, 'Location', 'NorthEastOutside');
    else
        handles.var_names = MainHandles.Hvar_names;
        handles.long_names = MainHandles.Hlong_names;
        handles.short_names = MainHandles.Hshort_names;
        handles.numVars = MainHandles.HnumVars;
        handles.aveWindow = MainHandles.HaveWindow;
        set(handles.StartTime, 'String', MainHandles.HStartTime);
        set(handles.EndTime, 'String', MainHandles.HEndTime);
        StartIndex = find(handles.times == str2double(MainHandles.HStartTime));
        EndIndex = find(handles.times == str2double(MainHandles.HEndTime));
        height = handles.height(StartIndex:EndIndex);
        hold all;
    
        for i = 1:handles.numVars
            N = handles.cdfhandle{handles.var_names{i}}(StartIndex:EndIndex)
            aveN = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N); 
            plot(aveN, height);      
        end
        hold off;
        
        set(handles.XMin, 'String', num2str(MainHandles.HXLim(1)));
        set(handles.XMax, 'String', num2str(MainHandles.HXLim(2)));
        set(handles.HMin, 'String', num2str(MainHandles.HHLim(1)));
        set(handles.HMax, 'String', num2str(MainHandles.HHLim(2)));
        set(handles.LinearX, 'Value', MainHandles.HLinearX);
        set(handles.LinearH, 'Value', MainHandles.HLinearH);
        if(MainHandles.HLinearX == 0)
            set(gca, 'XScale', 'log');
        end
        if(MainHandles.HLinearH == 0)
            set(gca, 'YScale', 'log');
        end
        set(gca, 'XLim', MainHandles.HXLim, 'YLim', MainHandles.HHLim);
        set(handles.IntervalMenu, 'String', num2str(handles.aveWindow));
        xlabel(MainHandles.HXLabel);
        ylabel(MainHandles.HHLabel);
        title(MainHandles.HTitle);
        legend(handles.short_names, 'Location', 'NorthEastOutside');
    end
    set(gca, 'ButtonDownFcn', {@HVAxes_ButtonDownFcn, handles});
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
end


% UIWAIT makes hviewer wait for user response (see UIRESUME)
% uiwait(handles.HPlot);


% --- Outputs from this function are returned to the command line.
function varargout = hviewer_OutputFcn(hObject, eventdata, handles) 
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



function HMin_Callback(hObject, eventdata, handles)
% hObject    handle to HMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HMin as text
%        str2double(get(hObject,'String')) returns contents of HMin as a double
hrange = [str2double(get(hObject, 'String')) str2double(get(handles.HMax, 'String'))];
if(hrange(1)>hrange(2))
    errordlg('Maximum H values must be greater than Minimum H value!', 'Error')
    h = get(handles.HVAxes, 'YLim');
    set(hObject, 'String', num2str(h(1)));
else
    set(handles.HVAxes, 'YLim', hrange);
end

% --- Executes during object creation, after setting all properties.
function HMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HMax_Callback(hObject, eventdata, handles)
% hObject    handle to HMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HMax as text
%        str2double(get(hObject,'String')) returns contents of HMax as a double

hrange = [str2double(get(handles.HMin, 'String')) str2double(get(hObject, 'String'))];
if(hrange(1)>hrange(2))
    errordlg('Maximum H values must be greater than Minimum H value!', 'Error')
    h = get(handles.HVAxes, 'YLim');
    set(hObject, 'String', num2str(h(2)));
else
    set(handles.HVAxes, 'YLim', hrange);
end


% --- Executes during object creation, after setting all properties.
function HMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XMin_Callback(hObject, eventdata, handles)
% hObject    handle to XMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XMin as text
%        str2double(get(hObject,'String')) returns contents of XMin as a double
xrange = [str2double(get(hObject, 'String')) str2double(get(handles.XMax, 'String'))];
if(xrange(1)>xrange(2))
    errordlg('Maximum X values must be greater than Minimum X value!', 'Error')
    x = get(handles.HVAxes, 'XLim');
    set(hObject, 'String', num2str(x(1)));
else
    set(handles.HVAxes, 'XLim', xrange);
end

% --- Executes during object creation, after setting all properties.
function XMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XMax_Callback(hObject, eventdata, handles)
% hObject    handle to XMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XMax as text
%        str2double(get(hObject,'String')) returns contents of XMax as a double
xrange = [str2double(get(handles.XMin, 'String')) str2double(get(hObject, 'String'))];
if(xrange(1)>xrange(2))
    errordlg('Maximum X values must be greater than Minimum X value!', 'Error')
    x = get(handles.HVAxes, 'XLim');
    set(hObject, 'String', num2str(x(2)));
else
    set(handles.HVAxes, 'XLim', xrange);
end

% --- Executes during object creation, after setting all properties.
function XMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ZoomHButton.
function ZoomHButton_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomHButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n = 1;
button = 0;
x = [0 0];
y = [0 0];

while (n < 3 && button ~= 3)
         [x(n), y(n), button] = ginput(1);
         n = n + 1;
end
 
if(button ~= 3)           % Make sure user did not cancel operati    
        if(y(2) < y(1))
            temp = y(2);
            y(2) = y(1);
            y(1) = temp;
        end
        set(handles.HVAxes, 'YLim', y);
        set(handles.HMin, 'String', num2str(y(1)));
        set(handles.HMax, 'String', num2str(y(2)));
end

% --- Executes on button press in ZoomXButton.
function ZoomXButton_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomXButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n = 1;
button = 0;
x = [0 0];
y = [0 0];

while (n < 3 && button ~= 3)
         [x(n), y(n), button] = ginput(1);
         n = n + 1;
end
 
if(button ~= 3)           % Make sure user did not cancel operati    
        if(x(2) < x(1))
            temp = x(2);
            x(2) = x(1);
            x(1) = temp;
        end
        set(handles.HVAxes, 'XLim', x);
        set(handles.XMin, 'String', num2str(x(1)));
        set(handles.XMax, 'String', num2str(x(2)));
end

% --- Executes on button press in SetTitleButton.
function SetTitleButton_Callback(hObject, eventdata, handles)
% hObject    handle to SetTitleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = 'Enter new graph title:';
title = 'Edit graph title';
l = 1;
Answer = {get(get(gca, 'Title'), 'String')};
newTitle = inputdlg(prompt, title, l, Answer);
if(~isempty(newTitle))
    
    set(get(gca, 'Title'), 'String', newTitle);
    guidata(hObject, handles);
end

% --- Executes on button press in SetXLabel.
function SetXLabel_Callback(hObject, eventdata, handles)
% hObject    handle to SetXLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = 'Enter X axis label:';
title = 'Edit X Axis label';
l = 1;
Answer = {get(get(gca, 'XLabel'), 'String')};
newTitle = inputdlg(prompt, title, l, Answer);
if(~isempty(newTitle))
    
    set(get(gca, 'XLabel'), 'String', newTitle);
    guidata(hObject, handles);
end    

% --- Executes on button press in SetYLabel.
function SetYLabel_Callback(hObject, eventdata, handles)
% hObject    handle to SetYLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = 'Enter Y axis label:';
title = 'Edit Y Axis label';
l = 1;
Answer = {get(get(gca, 'YLabel'), 'String')};
newTitle = inputdlg(prompt, title, l, Answer);
if(~isempty(newTitle))

    set(get(gca, 'YLabel'), 'String', newTitle);
    guidata(hObject, handles);
end

% --- Executes on button press in SavePlot.
function SavePlot_Callback(hObject, eventdata, handles)
% hObject    handle to SavePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uiputfile({'*.jpg;', 'JPEG Images (*.jpg)'}, 'Select a destination JPEG file');
oldpath = pwd;

if ~isequal(file, 0)
    cd(path);
    oldaxes = gca;
    figure
    StartIndex = find(handles.times == str2double(get(handles.StartTime, 'String')));
    EndIndex = find(handles.times == str2double(get(handles.EndTime, 'String')));
    height = handles.height(StartIndex:EndIndex);
    
    hold all;
    
    for i = 1:handles.numVars
        N = handles.cdfhandle{handles.var_names{i}}(StartIndex:EndIndex);
        N = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N); 
        plot(N, height);      
    end
    hold off;
    
    
    xlabel(get(get(oldaxes, 'XLabel'), 'String'));
    ylabel(get(get(oldaxes, 'YLabel'), 'String'));
    title(get(get(oldaxes, 'Title'), 'String'));
    legend(handles.short_names);
    set(gca, 'XLim', get(oldaxes, 'XLim'));
    set(gca, 'YLim', get(oldaxes, 'YLim'));
    if(get(handles.LinearH, 'Value') == 0.0)
        set(gca, 'YScale', 'log');
    else
        set(gca, 'YScale', 'linear');
    end
    if(get(handles.LinearX, 'Value') == 0.0)
        set(gca, 'XScale', 'log');
    else
        set(gca, 'XScale', 'linear'); 
    end
    print(gcf, '-djpeg', file);
    cd(oldpath);
end
    % --- Executes on button press in Print.
function Print_Callback(hObject, eventdata, handles)
% hObject    handle to Print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure
StartIndex = find(handles.times == str2double(get(handles.StartTime, 'String')));
EndIndex = find(handles.times == str2double(get(handles.EndTime, 'String')));
height = handles.height(StartIndex:EndIndex);
   
hold all;
    
for i = 1:handles.numVars
        N = handles.cdfhandle{handles.var_names{i}}(StartIndex:EndIndex)
        N = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N); 
        plot(N, height);      
end
hold off;
    
    
xlabel(get(get(oldaxes, 'XLabel'), 'String'));
ylabel(get(get(oldaxes, 'YLabel'), 'String'));
title(get(get(oldaxes, 'Title'), 'String'));
legend(handles.short_names);
set(gca, 'XLim', get(oldaxes, 'XLim'));
set(gca, 'YLim', get(oldaxes, 'YLim'));
if(get(handles.LinearH, 'Value') == 0.0)
        set(gca, 'YScale', 'log');
else
        set(gca, 'YScale', 'linear');
end
if(get(handles.LinearX, 'Value') == 0.0)
        set(gca, 'XScale', 'log');
else
        set(gca, 'XScale', 'linear'); 
end
print(gcf);
    

% --- Executes on button press in LinearX.
function LinearX_Callback(hObject, eventdata, handles)
% hObject    handle to LinearX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%X = get(gca, 'XLim');
if(get(hObject, 'Value') == 0.0)
    %ticks = 10.^(linspace(log10(X(1)), log10(X(2)), 4));
    set(gca, 'XScale', 'log');
else
    set(gca, 'XScale', 'linear');
end
XLims = get(gca, 'XLim');
YLims = get(gca, 'YLim');
set(handles.XMin, 'String', num2str(XLims(1)));
set(handles.XMax, 'String', num2str(XLims(2)));
set(handles.HMin, 'String', num2str(YLims(1)));
set(handles.HMax, 'String', num2str(YLims(2)));
% Hint: get(hObject,'Value') returns toggle state of LinearX


% --- Executes on button press in LinearH.
function LinearH_Callback(hObject, eventdata, handles)
% hObject    handle to LinearH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%H = get(gca, 'YLim');
if(get(hObject, 'Value') == 0.0)
    %ticks = 10.^(linspace(log10(H(1)), log10(H(2)), 4));
    set(gca, 'YScale', 'log');
else
    set(gca, 'YScale', 'linear');
end
XLims = get(gca, 'XLim');
YLims = get(gca, 'YLim');
set(handles.XMin, 'String', num2str(XLims(1)));
set(handles.XMax, 'String', num2str(XLims(2)));
set(handles.HMin, 'String', num2str(YLims(1)));
set(handles.HMax, 'String', num2str(YLims(2)));
% Hint: get(hObject,'Value') returns toggle state of LinearH



function IntervalMenu_Callback(hObject, eventdata, handles)
% hObject    handle to IntervalMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IntervalMenu as text
%        str2double(get(hObject,'String')) returns contents of IntervalMenu as a double
handles.aveWindow = str2double(get(hObject, 'String'));
StartIndex = find(handles.times == str2double(get(handles.StartTime, 'String')))
EndIndex = find(handles.times == str2double(get(handles.EndTime, 'String')))
height = handles.height(StartIndex:EndIndex);
cla(gca);
hold all;
    
for i = 1:handles.numVars
        N = handles.cdfhandle{handles.var_names{i}}(StartIndex:EndIndex);
        N = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N); 
        plot(N, height);      
end
hold off;
legend(handles.short_names, 'Location', 'NorthEastOutside');
set(gca, 'XLim', [str2double(get(handles.XMin, 'String')) str2double(get(handles.XMax, 'String'))]);
guidata(hObject, handles);
set(gca, 'ButtonDownFcn', {@HVAxes_ButtonDownFcn, handles});

% --- Executes during object creation, after setting all properties.
function IntervalMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IntervalMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function AddProbe_Callback(hObject, eventdata, handles)
% hObject    handle to AddProbe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Selection, ok] = listdlg('ListString', handles.ProbeShortNames, 'Name', 'Select a Probe', ... 
                          'SelectionMode', 'single', ...
                          'PromptString', 'List of Time Series Variables:');                  
                      
if(ok == 1)
    handles.var_names = [handles.var_names handles.ProbeNames{Selection}];
    handles.long_names = [handles.long_names handles.ProbeLongNames{Selection}];
    handles.short_names = [handles.short_names handles.ProbeShortNames{Selection}];
    handles.numVars = handles.numVars + 1;
    StartIndex = find(handles.times == str2double(get(handles.StartTime, 'String')));
    EndIndex = find(handles.times == str2double(get(handles.EndTime, 'String')));
    height = handles.height(StartIndex:EndIndex);
    hold all;
    N = handles.cdfhandle{handles.ProbeNames{Selection}}(StartIndex:EndIndex)
    aveN = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N); 
    plot(aveN, height);    
    hold off;
    legend(handles.short_names, 'Location', 'NorthEastOutside');
    %Y1 = get(handles.HVAxes, 'YLim');
    %Y2 = [min(height) max(height)];
    %y = [min([Y1(1) Y2(1)]) max([Y1(2) Y2(2)])];
    
    x = [str2double(get(handles.XMin, 'String')) str2double(get(handles.XMax, 'String'))];
    y = [str2double(get(handles.XMax, 'String')) str2double(get(handles.YMax, 'String'))];
    
    set(gca, 'YLim', y, 'XLim', x);
    %set(handles.HMin, 'String', num2str(y(1)));
    %set(handles.HMax, 'String', num2str(y(2)));
    set(handles.XMin, 'String', num2str(x(1)));
    set(handles.XMax, 'String', num2str(x(2)));
    guidata(hObject, handles);
    set(gca, 'ButtonDownFcn', {@HVAxes_ButtonDownFcn, handles});
end

% --------------------------------------------------------------------
function AxesRightClickMenu_Callback(hObject, eventdata, handles)
% hObject    handle to AxesRightClickMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function HPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function StartTime_Callback(hObject, eventdata, handles)
% hObject    handle to StartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartTime as text
%        str2double(get(hObject,'String')) returns contents of StartTime as a double
StartIndex = find(handles.times == str2double(get(hObject, 'String')));
EndIndex = find(handles.times == str2double(get(handles.EndTime, 'String')));
if(StartIndex >= EndIndex)
    errordlg('Start time must be before ending time!', 'Error');
else
    cla(gca);
    hold all;
    
    for i = 1:handles.numVars
        N = handles.cdfhandle{handles.var_names{i}}(StartIndex:EndIndex)
        aveN = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N); 
        plot(aveN, handles.height(StartIndex:EndIndex));      
    end
    hold off;
    legend(handles.short_names, 'Location', 'NorthEastOutside');
    set(gca, 'ButtonDownFcn', {@HVAxes_ButtonDownFcn, handles});
end
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
StartIndex = find(handles.times == str2double(get(handles.StartTime, 'String')));
EndIndex = find(handles.times == str2double(get(hObject, 'String')));
if(StartIndex >= EndIndex)
    errordlg('Start time must be before ending time!', 'Error');
else
    cla(gca);
    hold all;
    
    for i = 1:handles.numVars
        N = handles.cdfhandle{handles.var_names{i}}(StartIndex:EndIndex)
        aveN = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N); 
        plot(aveN, handles.height(StartIndex:EndIndex));      
    end
    hold off;
    legend(handles.short_names, 'Location', 'NorthEastOutside');
    set(gca, 'ButtonDownFcn', {@HVAxes_ButtonDownFcn, handles});
end

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


% --- Executes on mouse press over axes background.
function HVAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to HVAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ZoomOutButton.
function ZoomOutButton_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomOutButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom(0.5);
X = get(gca, 'XLim');
Y = get(gca, 'YLim');
set(handles.XMin, 'String', num2str(X(1)));
set(handles.XMax, 'String', num2str(X(2)));
set(handles.HMin, 'String', num2str(Y(1)));
set(handles.HMax, 'String', num2str(Y(2)));


% --------------------------------------------------------------------
function ClearAllAndChangeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ClearAllAndChangeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[Selection, ok] = listdlg('ListString', handles.ProbeShortNames, 'Name', 'Select a Probe', ... 
                          'SelectionMode', 'single', ...
                          'PromptString', 'List of Time Series Variables:');                  
                      
if(ok == 1)
    handles.var_names = {};
    handles.long_names = {};
    handles.short_names = {};
    handles.var_names = {handles.ProbeNames{Selection}};
    handles.long_names = {handles.ProbeLongNames{Selection}};
    handles.short_names = {handles.ProbeShortNames{Selection}};
    handles.numVars = 1;
    StartIndex = find(handles.times == str2double(get(handles.StartTime, 'String')));
    EndIndex = find(handles.times == str2double(get(handles.EndTime, 'String')));
    height = handles.height(StartIndex:EndIndex);
    N = handles.cdfhandle{handles.ProbeNames{Selection}}(StartIndex:EndIndex)
    aveN = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N); 
    plot(aveN, height);    
    xlabel(handles.cdfhandle{handles.var_names{1}}.units(:));
    ylabel(['Height (' handles.cdfhandle{'PALT'}.units(:) ')']);
    title('Probe Measurements vs. Height');
    legend(handles.short_names, 'Location', 'NorthEastOutside');
    Y1 = get(handles.HVAxes, 'YLim');
    Y2 = [min(height) max(height)];
    y = [min([Y1(1) Y2(1)]) max([Y1(2) Y2(2)])];
    x = get(gca, 'XLim');
    set(gca, 'YLim', y);
    set(handles.HMin, 'String', num2str(y(1)));
    set(handles.HMax, 'String', num2str(y(2)));
    set(handles.XMin, 'String', num2str(x(1)));
    set(handles.XMax, 'String', num2str(x(2)));
    if(get(handles.LinearX, 'Value') == 0.0);
        set(gca, 'XScale', 'log');
    else
        set(gca, 'XScale', 'linear');
    end
    if(get(handles.LinearH, 'Value') == 0.0);
        set(gca, 'YScale', 'log');
    else
        set(gca, 'YScale', 'linear');
    end
    guidata(hObject, handles);
    set(gca, 'ButtonDownFcn', {@HVAxes_ButtonDownFcn, handles});
end


% --- Executes on button press in AutozoomXButton.
function AutozoomXButton_Callback(hObject, eventdata, handles)
% hObject    handle to AutozoomXButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

StartTime = str2double(get(handles.StartTime, 'String'));
EndTime = str2double(get(handles.EndTime, 'String'));
time = handles.cdfhandle{'time'}(:);
StartIndex = find(time == StartTime);
EndIndex = find(time == EndTime);

curMin = inf;
curMax = -inf;

for i=1:handles.numVars
    curVar = handles.cdfhandle{handles.var_names{i}}(:);
    curMin = min([curMin min(curVar(StartIndex:EndIndex))]);
    curMax = max([curMax max(curVar(StartIndex:EndIndex))]);
end

set(gca, 'XLim', [curMin curMax]);
set(handles.XMin, 'String', num2str(curMin));
set(handles.XMax, 'String', num2str(curMax));

