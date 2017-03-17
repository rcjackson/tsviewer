function varargout = tsviewer(varargin);
% TSVIEWER M-file for tsviewer.fig
%      TSVIEWER, by itself, creates a new TSVIEWER or raises the existing
%      singleton*.
%
%      H = TSVIEWER returns the handle to a new TSVIEWER or the handle to
%      the existing singleton*.
%
%      TSVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TSVIEWER.M with the given input arguments.
%
%      TSVIEWER('Property','Value',...) creates a new TSVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tsviewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tsviewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tsviewer

% Last Modified by GUIDE v2.5 29-Jan-2009 11:16:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tsviewer_OpeningFcn, ...
                   'gui_OutputFcn',  @tsviewer_OutputFcn, ...
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


% --- Executes just before tsviewer is made visible.
function tsviewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tsviewer (see VARARGIN)

% Choose default command line output for tsviewer
handles.output = hObject;
%position = get(handles.axes1, 'Position')

handles.selected = 0;
handles.SDViewer = 0;
handles.HViewer = 0;
handles.SPViewer = 0;
handles.numPlots = 4;
handles.axes = 1:handles.numPlots;
handles.AxesX = 0.055;
handles.AxesY = 0.18;
handles.AxesW = 0.935;
handles.AxesH = (1-0.03*(handles.numPlots)-.18)/(handles.numPlots);
handles.n = 1;
handles.button = 0;
handles.x = [0 0];
handles.y = [0 0];
handles.EventClicked = 0;
handles.ColorOrder = get(gca, 'ColorOrder');
handles.Path = '';
for i = 1:handles.numPlots
    handles.axes(i) = subplot('position', [handles.AxesX handles.AxesY+(i-1)*(handles.AxesH+0.04) handles.AxesW (1-0.07*(handles.numPlots-1))*handles.AxesH]);
end
%Positions = zeros(4,4);
%for i=1:4
%    Positions(i, :) = [position(1) position(2)+i*position(4)/4 position(3) position(4)]
%    set(handles.axes(i), 'Position', Positions(i, :));
%end
%set(handles.axes(1), 'Position', position);

handles.FirstOpen = 1;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tsviewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tsviewer_OutputFcn(hObject, eventdata, handles) 
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




function StartTime_Callback(hObject, eventdata, handles)
% hObject    handle to StartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartTime as text
%        str2double(get(hObject,'String')) returns contents of StartTime as a double

begin = str2num(get(hObject, 'String'));
  
ending = str2num(get(handles.EndTime, 'String'));
if (ending < begin)
    errordlg('Start time must be before the end time!', 'Error');
    XLim = get(gca, 'XLim');
    set(hObject, 'String', datestr(XLim(1), 'HHMMSS'));
else
    if(~isnan(begin) && ~isnan(ending))
       times = handles.cdfhandle{'time'}(:);
       timevec = handles.cdfhandle{'timevec'}(:);
       begin_index = find(times == begin);
       end_index = find(times == ending);
       ticks = timevec(begin_index):(timevec(end_index)-timevec(begin_index))/7:timevec(end_index);
       set(handles.axes(:), 'XMinorTick', 'on', 'XLim', [timevec(begin_index) timevec(end_index)]);
       set(handles.axes(:), 'XTick', ticks, 'XTickLabel', timeround(datestr(ticks, 'HH:MM:SS'), handles.roundNearest));
    end
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

begin = str2num(get(handles.StartTime, 'String'));
  
ending = str2num(get(hObject, 'String'));
if (ending < begin)
    errordlg('End time must be after the start time!', 'Error');
    XLim = get(gca, 'XLim');
    set(hObject, 'String', datestr(XLim(2), 'HHMMSS'));
else
    if(~isnan(begin) && ~isnan(ending))
       times = handles.cdfhandle{'time'}(:);
       timevec = handles.cdfhandle{'timevec'}(:);
       begin_index = find(times == begin);
       end_index = find(times == ending);
       ticks = timevec(begin_index):(timevec(end_index)-timevec(begin_index))/7:timevec(end_index);
   
       set(handles.axes(:), 'XMinorTick', 'on', 'XLim', [timevec(begin_index) timevec(end_index)]);
       set(handles.axes(:), 'XTick', ticks, 'XTickLabel', timeround(datestr(ticks, 'HH:MM:SS'), handles.roundNearest));
    end   
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


function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenu_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile({'*.cdf', 'NetCDF Files (*.cdf)'}, 'Pick a NetCDF file')
oldpath = pwd;  % Save old path so that we can work again
if ~isequal(file, 0)
    cd(path);
    handles.cdfhandle = netcdf(file, 'nowrite');
    handles.FileName = file;
    handles.Path = path;
    cd(oldpath);
    if(handles.FirstOpen == 1) 
        handles.var_name = {{'CAS_n'}, {'CAS_n'}, {'CAS_n'}, {'CAS_n'}, {'CAS_n'}, {'CAS_n'}, {'CAS_n'}, {'CAS_n'}, {'CAS_n'}, {'CAS_n'}};
        handles.long_names = {{'CAS number concentration (cm-3)'}, {'CAS number concentration (cm-3)'}, {'CAS number concentration (cm-3)'}, {'CAS number concentration (cm-3)'}, {'CAS number concentration (cm-3)'}, {'CAS number concentration (cm-3)'}, {'CAS number concentration (cm-3)'}, {'CAS number concentration (cm-3)'}, {'CAS number concentration (cm-3)'}, {'CAS number concentration (cm-3)'}};
        handles.short_names = {{'CAS N (cm-3)'}, {'CAS N (cm-3)'}, {'CAS N (cm-3)'}, {'CAS N (cm-3)'}, {'CAS N (cm-3)'}, {'CAS N (cm-3)'}, {'CAS N (cm-3)'}, {'CAS N (cm-3)'}, {'CAS N (cm-3)'}, {'CAS N (cm-3)'}}; 
        handles.numVars = ones(1, 10);
        handles.FirstOpen = 0;
        Vars = var(handles.cdfhandle);
        TimeLen = length(handles.cdfhandle('Time'));
        handles.Probes = {};
        handles.ProbeLongNames = {};
        handles.ProbeShortNames = {};
        handles.roundNearest = 1;
        for i=1:length(Vars)
            VarName = name(Vars{i});
            y = size(Vars{i});
            if(length(y) == 2)
                if y == [TimeLen 1]
                    if (~isequal(VarName, 'time') && ~isequal(VarName, 'timevec') && ~isequal(VarName, 'm200time') && ~isequal(VarName, 'm200timevec'))
                        handles.Probes = [handles.Probes; name(Vars{i})];
                        handles.ProbeLongNames = [handles.ProbeLongNames; handles.cdfhandle{name(Vars{i})}.long_name(:)];
                        handles.ProbeShortNames = [handles.ProbeShortNames; handles.cdfhandle{name(Vars{i})}.short_name(:)];
                    end
                end
            end
        end
    end
    t = handles.cdfhandle{'timevec'}(:);
    times = handles.cdfhandle{'time'}(:);
    
    
    for i=1:handles.numPlots
        subplot(handles.axes(i));
        cla(gca);
        set(gca, 'ColorOrder', handles.ColorOrder);
        hold on;
        for j = 1:handles.numVars(i)
            N = handles.cdfhandle{handles.var_name{i}{j}}(:);
            plot(t, N, 'HitTest', 'off');
            hold all;
            ticks = t(1):(t(end)-t(1))/7:t(end);
            set(gca, 'XMinorTick', 'on', 'XLim', [t(1) t(end)], 'XTick', ticks, 'XTickLabel', timeround(datestr(ticks, 'HH:MM:SS'), handles.roundNearest));
            xlabel('Time');
            
        end
        hold off;
        Pos = get(gca, 'Position');
        LegendPos = [Pos(1)+.67 Pos(2) .25 Pos(4)];
        NewAxisPos = [Pos(1) Pos(2) .65 Pos(4)];
        set(gca, 'Position', NewAxisPos);
        legend(handles.short_names{i}, 'Location', LegendPos);
            %legend boxoff;
        %set(gca, 'YScale', 'log');
    end    
    set(handles.figure1, 'Name', ['Time Series Viewer - ' path file]);
    % Enable all of the menu options and text boxes
   
    % Set the handle function as plot overwrites it
     
    set(handles.StartTime, 'String', num2str(times(1)));
    set(handles.EndTime, 'String', num2str(times(end)));
    
    handles.aveWindow = 1;
    % Load the probe data
    
    
    
    
    guidata(gcbo, handles);
    % Initalize the Probe Menu
    handles.ProbeMenu = uicontextmenu;
    
    handles.ProbeMenuItem = uimenu(handles.ProbeMenu, 'Label', 'Clear All And Select A Different Probe', 'Callback', {@ChangeProbeMenu_Callback, handles});
    handles.ProbeMenuItem2 = uimenu(handles.ProbeMenu, 'Label', 'View in Separate Figure', 'Callback', {@FigureMenu_CallBack, handles});
    handles.ProbeMenuItem3 = uimenu(handles.ProbeMenu, 'Label', 'Add Another Probe To View', 'Callback', {@AddProbeMenu_Callback, handles});
    
    set(handles.ProbeMenuItem, 'Callback', {@ChangeProbeMenu_Callback, handles});
    set(handles.ProbeMenuItem2, 'Callback', {@FigureMenu_Callback, handles});
    set(handles.ProbeMenuItem3, 'Callback', {@AddProbeMenu_Callback, handles});
    
    guidata(gcbo, handles);
    
    set(handles.axes(:), 'UIContextMenu', handles.ProbeMenu);
    set(handles.axes(:), 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});
    set(handles.SaveStateMenu, 'Enable', 'on');
    set(handles.SetVarNumMenu, 'Enable', 'on');
    set(handles.SaveAllMenu, 'Enable', 'on');
    set(handles.SaveAllButton, 'Enable', 'on');
    set(handles.TitleSet, 'Enable', 'on');
    set(handles.TitleButton, 'Enable', 'on');
    set(handles.WholeFlightMenu, 'Enable', 'on');
    set(handles.WholeFlightButton, 'Enable', 'on');
    set(handles.LegendOn, 'Value', 1.0);
    % Save the NetCDF data
    
    
    end

function AddProbeMenu_Callback(hObject, eventdata, handles)
[Selection, ok] = listdlg('ListString', handles.ProbeShortNames, 'Name', 'Select a Probe', ... 
                          'SelectionMode', 'multiple', ...
                          'PromptString', 'List of Time Series Variables:');                          
% Replot the new graph
if(ok == 1)
     index = find(handles.axes == gca);
     for(i=1:length(Selection))
         handles.var_name{index} = [handles.var_name{index} handles.Probes{Selection(i)}];
         unitName = handles.cdfhandle{handles.Probes{Selection(i)}}.units(:); 
         handles.long_names{index} = [handles.long_names{index} [handles.ProbeLongNames{Selection(i)} ' (' unitName ')']];
         handles.short_names{index} = [handles.short_names{index} [handles.ProbeShortNames{Selection(i)} ' (' unitName ')']];
         handles.numVars(index) = handles.numVars(index) + 1;
     end 
     T = handles.cdfhandle{'timevec'}(:);
     times = handles.cdfhandle{'time'}(:);
     
     % Are the times within specified ranges
     StartIndex = find(times == str2double(get(handles.StartTime, 'String')));
     EndIndex = find(times == str2double(get(handles.EndTime, 'String')));
     
     
     N = zeros(handles.numVars(index), length(T));
     for i=1:handles.numVars(index)
        N(i, :) = handles.cdfhandle{handles.var_name{index}{i}}(:);
        N(i, :) = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N(i, :));
     end
     plot(gca, T, N, 'HitTest', 'off');    
     
     xlabel('Time');
     ylabel('');
     %title('Probe Measurements vs. Time');
     Pos = get(gca, 'Position');
     LegendPos = [Pos(1)+.67 Pos(2) .25 Pos(4)];
     
       
     legend(handles.axes(index), handles.short_names{index}, 'Location', LegendPos); 
     %legend boxoff;
     ticks = T(StartIndex):(T(EndIndex)-T(StartIndex))/7:T(EndIndex);
     set(handles.axes(:), 'XMinorTick', 'on', 'XLim', [T(StartIndex) T(EndIndex)], 'XTick', ticks, 'XTickLabel', timeround(datestr(ticks, 'HH:MM:SS'), handles.roundNearest));
     set(gca, 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles}); 
     if(get(handles.LinearY, 'Value') == 0.0)
         set(gca, 'YScale', 'log');
     end
     Y = [str2double(get(handles.YMin, 'String')) str2double(get(handles.YMax, 'String'))];
     set(gca, 'YLim', Y);
     if(isequal(get(gca, 'Selected'), 'on'))
         handles.selected = index;
     else
         handles.selected = 0;
     end
     
     
     
     CurCallback = {@ChangeProbeMenu_Callback, handles};
     set(handles.ProbeMenuItem, 'Callback', CurCallback);
     set(handles.ProbeMenuItem2, 'Callback', {@FigureMenu_Callback, handles});
     set(hObject, 'Callback', {@AddProbeMenu_Callback, handles});
     
    
     guidata(gcbo, handles);
     %set(handles.axes(:), 'UIContextMenu', handles.ProbeMenu);
     if(get(handles.LegendOn, 'Value') == 0.0)     
            legend('toggle');
            AxesPos = get(gca, 'Position');
            %AxesPos(3) = AxesPos(3) + .25;
            %set(gca, 'Position', AxesPos);
     end   

     
end

function FigureMenu_Callback(hObject, eventdata, handles, axesnum)

index = find(gca == handles.axes);
oldaxes = gca;
t = handles.cdfhandle{'timevec'}(:);


figure
N = zeros(handles.numVars(index), length(t));
for i=1:handles.numVars(index)
    N(i, :) = handles.cdfhandle{handles.var_name{index}{i}}(:);
    N(i, :) = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N(i, :));
end

plot(t, N);
datetick('x', 'HH:MM:SS');
xlabel(get(get(oldaxes, 'XLabel'), 'String'));
ylabel(get(get(oldaxes, 'YLabel'), 'String'));
title(get(handles.TSTitle, 'String'));
legend(handles.short_names{index});
%legend boxoff;
begin = str2num(get(handles.StartTime, 'String'));
  
ending = str2num(get(handles.EndTime, 'String'));

if(~isnan(begin) && ~isnan(ending))
    times = handles.cdfhandle{'time'}(:);
    timevec = handles.cdfhandle{'timevec'}(:);
    begin_index = find(times == begin);
    end_index = find(times == ending);
    ticks = linspace(timevec(begin_index), timevec(end_index), 7);
    set(gca, 'XMinorTick', 'on', 'XLim', [timevec(begin_index) timevec(end_index)]);
    set(gca, 'XTick', ticks, 'XTickLabel', datestr(ticks, 'HH:MM:SS'));
    YLims = get(oldaxes, 'YLim')
    if(get(handles.LinearY, 'Value') == 0.0)
         set(gca, 'YScale', 'log');
         yticks = 10.^(linspace(log10(YLims(1)), log10(YLims(2)), 6));
    else
         yticks = linspace(YLims(1), YLims(2), 4);
    end     
    set(gca, 'YMinorTick', 'on',  'YLim', YLims, 'YTick', yticks);
end

% --------------------------------------------------------------------
function SaveMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SaveMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uiputfile({'*.jpg;', 'JPEG Images (*.jpg)'}, 'Select a destination JPEG file');
oldpath = pwd;

if ~isequal(file, 0)
    index = find(gca == handles.axes);
    oldaxes = gca;
    t = handles.cdfhandle{'timevec'}(:);


    figure

    N = zeros(handles.numVars(index), length(t));
    for i=1:handles.numVars(index)
        N(i, :) = handles.cdfhandle{handles.var_name{index}{i}}(:);
        N(i, :) = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N(i, :));
    end    
    
    

    plot(t, N);
    datetick('x', 'HH:MM:SS');
    xlabel(get(get(oldaxes, 'XLabel'), 'String'));
    ylabel(get(get(oldaxes, 'YLabel'), 'String'));
    title(get(handles.TSTitle, 'String'));
    legend(handles.short_names{index});
    %legend boxoff;
    begin = str2num(get(handles.StartTime, 'String'));
  
    ending = str2num(get(handles.EndTime, 'String'));
    if(get(handles.LinearY, 'Value') == 0.0)
         set(gca, 'YScale', 'log');
    end
    if(~isnan(begin) && ~isnan(ending))
         times = handles.cdfhandle{'time'}(:);
         timevec = handles.cdfhandle{'timevec'}(:);
         begin_index = find(times == begin);
         end_index = find(times == ending);
         ticks = timevec(begin_index):(timevec(end_index)-timevec(begin_index))/7:timevec(end_index);
         set(gca, 'XMinorTick', 'on', 'XLim', [timevec(begin_index) timevec(end_index)]);
         set(gca, 'XTick', ticks, 'XTickLabel', datestr(ticks, 'HH:MM:SS'));
         YLims = get(oldaxes, 'YLim');
         if(get(handles.LinearY, 'Value') == 0.0)
             set(gca, 'YScale', 'log');
             yticks = 10.^(linspace(log10(YLims(1)), log10(YLims(2)), 6));
         else
             yticks = linspace(YLims(1), YLims(2), 6);
         end     
         set(gca, 'YMinorTick', 'on',  'YLim', YLims, 'YTick', yticks);
    end

    cd(path);
    print(gcf, '-djpeg', file);
    cd(oldpath);
end


% --------------------------------------------------------------------
function ExitMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ExitMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(ishandle(handles.SDViewer) && handles.SDViewer ~= 0)
    delete(handles.SDViewer);
end
if(ishandle(handles.SPViewer) && handles.SPViewer ~= 0)
    delete(handles.SPViewer);
end
if(ishandle(handles.HViewer) && handles.HViewer ~= 0)
    delete(handles.HViewer);
end
if(ishandle(handles.CIPViewer) && handles.CIPViewer ~= 0)
    delete(handles.CIPViewer);
end
delete(handles.figure1);


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on key press with focus on StartTime and none of its controls.
function StartTime_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to StartTime (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%if(strcmp(get(gcbf, 'SelectionType'), 'Normal'))
%    if(~isequal(get(gcbf, 'Name'), 'Time Series Viewer'))
%msgbox('Axes Clicked!');
        set(handles.axes(:), 'Selected', 'off');
        set(gcbo, 'Selected', 'on'); 
        index = find(gcbo == handles.axes);
        if(handles.selected ~= index)
            handles.EventClicked = 0;
            set(gcbf, 'Pointer', 'arrow');
            set(handles.CursorText, 'Visible', 'off');
           
            if(handles.n == 2)
                handles.n = 0;
                delete(handles.Line(:));
                delete(handles.Line2(:));
            end
        end
        handles.selected = index;
        subplot(handles.axes(index));
        YLimits = get(gca, 'YLim');
        set(handles.YMin, 'String', num2str(YLimits(1)));
        set(handles.YMax, 'String', num2str(YLimits(2)));
        TLimits = get(gca, 'XLim');
        if(isequal(get(handles.axes(index), 'YScale'), 'log'))
                  set(handles.LinearY, 'Value', 0.0);
        else
                  set(handles.LinearY, 'Value', 1.0);
        end    
        set(handles.StartTime, 'String', datestr(TLimits(1), 'HHMMSS'));
        set(handles.EndTime, 'String', datestr(TLimits(2), 'HHMMSS'));
        EnableAllButtons(handles);
        guidata(hObject, handles);
        if(handles.EventClicked ~= 0)
              handles.n = handles.n + 1;
              pos = get(hObject, 'CurrentPoint');
              handles.x(handles.n-1) = pos(1,1);
              handles.y(handles.n-1) = pos(1,2);
              if(handles.n == 2)
                  hold on;
                  XLim = get(handles.axes(handles.selected), 'XLim');
                  handles.Line2 = 1:handles.numPlots;
                  handles.Line = 1:handles.numPlots;
                  for(i=1:handles.numPlots)
                      subplot(handles.axes(i));
                      handles.Line2(i) = line(XLim, [handles.y(handles.n-1) handles.y(handles.n-1)]);
                      YLim = get(handles.axes(i), 'YLim');
                      handles.Line(i) = line([handles.x(handles.n-1) handles.x(handles.n-1)], YLim);
                  end
                  subplot(gcbo);
                  hold off;
              end
              if(handles.n == 3)
                  x = handles.x;
                  y = handles.y;
                  delete(handles.Line2(:));
                  delete(handles.Line(:));
                  if(handles.EventClicked == 1) %Zoom T
                      if(x(1) ~= x(2))           % Make sure user did not cancel operation
                            if(x(2) < x(1))       % Swap values if we have a reverse interval
                                temp = x(2);
                                x(2) = x(1);
                                x(1) = temp;
                            end
        
                            if(y(2) < y(1))
                                temp = y(2);
                                y(2) = y(1);
                                y(1) = temp;
                            end
    
                            ticks = x(1):(x(2)-x(1))/7:x(2);
                            set(handles.axes(:), 'XMinorTick', 'on', 'XLim', [x(1) x(2)]);
                            set(handles.axes(:), 'XTick', ticks, 'XTickLabel', timeround(datestr(ticks, 'HH:MM:SS'), handles.roundNearest));
    
                            % Set the fields to the given maximum and minimum values
                            set(handles.StartTime, 'String', datestr(x(1), 'HHMMSS'));
                            set(handles.EndTime, 'String', datestr(x(2), 'HHMMSS'));
                            set(handles.figure1, 'Pointer', 'arrow');
                            handles.EventClicked = 0;
                      end
                  end
                  if(handles.EventClicked == 2) %Zoom Y
                         if(x(2) < x(1))       % Swap values if we have a reverse interval
                            temp = x(2);
                            x(2) = x(1);
                            x(1) = temp;
                          end
        
                        if(y(2) < y(1))
                            temp = y(2);
                            y(2) = y(1);
                            y(1) = temp;
                        end
    

                           set(handles.axes(handles.selected), 'XMinorTick', 'on', 'YLim', [y(1) y(2)]);
        
                           set(handles.YMin, 'String', num2str(y(1)));
                           set(handles.YMax, 'String', num2str(y(2)));
                           set(handles.figure1, 'Pointer', 'arrow');
                          handles.EventClicked = 0;
                  end
                  if(handles.EventClicked == 3) %SD Viewer
                      set(gcf, 'Pointer', 'watch');
                      if(x(2) < x(1))       % Swap values if we have a reverse interval
                        temp = x(2);
                        x(2) = x(1);
                        x(1) = temp;
                      end
        
                      handles.Times = x;
                      handles.SDLoad = 0;
                      handles.SDIndex = handles.selected;
                      guidata(hObject, handles);
                      handles.SDViewer = sdviewer('TSViewer', handles.figure1);
                      set(handles.ProbeMenuItem, 'Callback', {@ChangeProbeMenu_Callback, handles});
                      set(handles.ProbeMenuItem2, 'Callback', {@FigureMenu_Callback, handles});
                      set(handles.ProbeMenuItem3, 'Callback', {@AddProbeMenu_Callback, handles});
                      %set(handles.ProbeMenuItem4, 'Callback', {@GenHeightsMenu_Callback, handles});
                      guidata(hObject, handles);
                      set(handles.figure1, 'Pointer', 'arrow');
                      handles.EventClicked = 0;
                  end
                  if(handles.EventClicked == 4) %Height Viewer
                      set(gcf, 'Pointer', 'watch');
                      if(x(2) < x(1))       % Swap values if we have a reverse interval
                           temp = x(2);
                            x(2) = x(1);
                            x(1) = temp;
                      end
        
                      handles.Times = x;
                      handles.YLims = get(gca, 'YLim');
                      handles.HVIndex = handles.selected;
                      handles.HLoad = 0;
                      guidata(hObject, handles);
                      handles.HViewer = hviewer('TSViewer', handles.figure1);
                      set(handles.ProbeMenuItem, 'Callback', {@ChangeProbeMenu_Callback, handles});
                      set(handles.ProbeMenuItem2, 'Callback', {@FigureMenu_Callback, handles});
                      set(handles.ProbeMenuItem3, 'Callback', {@AddProbeMenu_Callback, handles});
                     % set(handles.ProbeMenuItem4, 'Callback', {@GenHeightsMenu_Callback, handles});
                      guidata(hObject, handles);
                      set(handles.figure1, 'Pointer', 'arrow');
                      handles.EventClicked = 0;
                  end
                  if(handles.EventClicked == 5) %Scatter Plot Viewer
                      set(gcf, 'Pointer', 'watch');
                      handles.SPIndex = handles.selected;
                      if(x(2) < x(1))       % Swap values if we have a reverse interval
                            temp = x(2);
                            x(2) = x(1);
                            x(1) = temp;
                      end
        
                      handles.Times = x;
                      handles.SPLoad = 0;
                      guidata(hObject, handles);
                      handles.SPViewer = spviewer('TSViewer', handles.figure1);
                      set(handles.ProbeMenuItem, 'Callback', {@ChangeProbeMenu_Callback, handles});
                      set(handles.ProbeMenuItem2, 'Callback', {@FigureMenu_Callback, handles});
                      set(handles.ProbeMenuItem3, 'Callback', {@AddProbeMenu_Callback, handles});
                      %set(handles.ProbeMenuItem4, 'Callback', {@GenHeightsMenu_Callback, handles});
                      guidata(hObject, handles);
                      set(handles.figure1, 'Pointer', 'arrow');
                      handles.EventClicked = 0;
                  end
                  if(handles.EventClicked == 6) % Plot Series Viewer
                      if(x(2) < x(1))       % Swap values if we have a reverse interval
                          temp = x(2);
                          x(2) = x(1);
                          x(1) = temp;
                      end
    
                      prompt = 'Enter number of graphs:';
                      title = 'Enter number of graphs';
                      l = 1;
                      Answer = {'10'};
                      numStr = inputdlg(prompt, title, l, Answer);
                      index = handles.selected;
                      set(gcf, 'Pointer', 'watch');
                      if(~isempty(numStr))
                            t = handles.cdfhandle{'timevec'}(:);
                            num = str2double(numStr{1});
                            times = handles.cdfhandle{'time'}(:);
                            oldaxes = gca;
                            figure;
                            TLimits = linspace(x(1),x(2), num+1);
        
                            YMin = inf;
                            YMax = -inf;
        
                            N = zeros(handles.numVars(index), length(t));
                            for i=1:handles.numVars(index)
                                N(i, :) = handles.cdfhandle{handles.var_name{index}{i}}(:);
                                N(i, :) = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N(i, :));
                                YMax = max([YMax max(N(i, :))]);
                                YMin = min([YMin min(N(i, :))]);
                            end
        
                            for i=1:(length(TLimits)-1)
                                subplot(4, ceil((length(TLimits)+1)/4), i);
                                StartIndex = find(times == str2double(datestr(TLimits(i), 'HHMMSS')));
                                EndIndex = find(times == str2double(datestr(TLimits(i+1), 'HHMMSS')));
                                clear X;
                                hold all;
                                for j = 1:handles.numVars(index)
                                    X = N(j, StartIndex:EndIndex);
                                    Ts = t(StartIndex:EndIndex);
                                    plot(Ts, X);
                                end
                                hold off;
        
                                if(get(handles.LinearY, 'Value') == 0.0)
                                     set(gca, 'YScale', 'log');
                                end
                                ticks = linspace(t(StartIndex), t(EndIndex), 3);
                                set(gca, 'XMinorTick', 'on', 'XLim', [t(StartIndex) t(EndIndex)], 'YLim', [YMin YMax], 'YMinorTick', 'on', 'XTick' , ticks, 'XTickLabel', datestr(ticks, 'HH:MM:SS'));
    
                                xlabel(get(get(oldaxes, 'XLabel'), 'String'));
                                ylabel(get(get(oldaxes, 'YLabel'), 'String'));
            
                                %legend(handles.long_names{index});
            
                            end
        
                            % Create a legend and a supertitle
                            %legendaxishandle = subplot(4, ceil((length(TLimits)+1)/4), length(TLimits));
                            %lpos = get(legendaxishandle, 'Position');
                            %subplot(4, ceil((length(TLimits)+1)/4), length(TLimits)-1);
                            legend(handles.short_names{index}, 'Location', [0.5 0.01 0.1 0.05], 'Orientation', 'Horizontal');
                            %axis(legendaxishandle, 'off');
                            suptitle(get(get(oldaxes, 'Title'), 'String'));
        
                      end  
                      set(handles.figure1, 'Pointer', 'arrow');
                      handles.EventClicked = 0;
                  end      
                  if(handles.EventClicked == 7) %CIP Viewer
                      set(gcf, 'Pointer', 'watch');
                      if(x(2) < x(1))       % Swap values if we have a reverse interval
                         temp = x(2);
                         x(2) = x(1);
                         x(1) = temp;
                      end
        
                      handles.Times = x;
                      handles.CIPLoad = 0;
                      handles.CIPIndex = handles.selected;
                      guidata(hObject, handles);
                      handles.CIPViewer = cipviewer('TSViewer', handles.figure1);
                      set(handles.ProbeMenuItem, 'Callback', {@ChangeProbeMenu_Callback, handles});
                      set(handles.ProbeMenuItem2, 'Callback', {@FigureMenu_Callback, handles});
                      set(handles.ProbeMenuItem3, 'Callback', {@AddProbeMenu_Callback, handles});
                      %set(handles.ProbeMenuItem4, 'Callback', {@GenHeightsMenu_Callback, handles});
                      guidata(hObject, handles);
                      set(handles.figure1, 'Pointer', 'arrow');
                      handles.EventClicked = 0;
                  end
              end    
              guidata(hObject, handles);
              
                  
        end
         set(handles.axes(:), 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});
    %   else
     %      errordlg('You need to open a NetCDF file first!', 'No NetCDF file open.');
%    end
       
%end
%guidata(hObject, handles);
% --------------------------------------------------------------------
function ViewMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ViewMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ResetMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ResetMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    
if(isequal(questdlg('Resetting values will result in loss of unsaved data. Are you sure?', 'Warning', 'Yes', 'No', 'No'), 'Yes'))
    
        t = handles.cdfhandle{'timevec'}(:);
        for index = 1:handles.numPlots
            N = zeros(handles.numVars(index), length(t));
            for i=1:handles.numVars(index)
               N(i, :) = handles.cdfhandle{handles.var_name{index}{i}}(:);
            end
            handles.aveWindow = 1;  
            subplot(handles.axes(index));
            plot(t, N, 'HitTest', 'off');
            xlabel(handles.axes(index), 'Time');
            ylabel(handles.cdfhandle{handles.var_name{index}}.units(:));
            title(handles.TSTitle, 'String', 'Time Series Plots');
            Pos = get(gca, 'Position');
            LegendPos = [Pos(1)+.67 Pos(2) .25 Pos(4)];
            
            legend(handles.axes(index), handles.short_names{index}, 'Location', LegendPos); 
            %legend boxoff;
            ticks = t(1):(t(end)-t(1))/7:t(end);
            set(gca, 'XMinorTick', 'on', 'XLim', [t(1) t(end)], 'XTick', ticks, 'XTickLabel', timeround(datestr(ticks, 'HH:MM:SS'), handles.roundNearest));               
            %set(handles.axes(index), 'YScale', 'log');
            set(handles.axes(index), 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});
        end
        set(handles.LinearY, 'Value', 1.0);
        set(handles.LegendOn, 'Value', 1.0);
        set(handles.StartTime, 'String', datestr(t(1), 'HHMMSS'));
        set(handles.EndTime, 'String', datestr(t(end), 'HHMMSS'));
        guidata(hObject, handles);
        subplot(handles.axes(handles.selected));
end

% --------------------------------------------------------------------
function XAxisLabelMenu_Callback(hObject, eventdata, handles)
% hObject    handle to XAxisLabelMenu (see GCBO)
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

% --------------------------------------------------------------------
function YAxisLabelMenu_Callback(hObject, eventdata, handles)
% hObject    handle to YAxisLabelMenu (see GCBO)
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
% --------------------------------------------------------------------
function TitleSet_Callback(hObject, eventdata, handles)
% hObject    handle to TitleSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = 'Enter new graph title:';
title = 'Edit graph title';
l = 1;
Answer = {get(handles.TSTitle, 'String')};
newTitle = inputdlg(prompt, title, l, Answer);
if(~isempty(newTitle))
    set(handles.TSTitle, 'String', newTitle);
    guidata(hObject, handles);
end


% --- Executes on button press in defaultsButton.
function defaultsButton_Callback(hObject, eventdata, handles)
% hObject    handle to defaultsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isequal(questdlg('Resetting values will result in loss of unsaved data. Are you sure?', 'Warning', 'Yes', 'No', 'No'), 'Yes'))
    
        t = handles.cdfhandle{'timevec'}(:);
        for index = 1:handles.numPlots
            N = zeros(handles.numVars(index), length(t));
            for i=1:handles.numVars(index)
               N(i, :) = handles.cdfhandle{handles.var_name{index}{i}}(:);
            end
            handles.aveWindow = 1;  
            subplot(handles.axes(index));
            plot(t, N, 'HitTest', 'off');
            xlabel(handles.axes(index), 'Time');
            ylabel(handles.cdfhandle{handles.var_name{index}}.units(:));
            set(handles.TSTitle, 'String','Time Series Plots');
            Pos = get(gca, 'Position');
            LegendPos = [Pos(1)+.67 Pos(2) .25 Pos(4)];
            legend(handles.axes(index), handles.short_names{index}, 'Location', LegendPos); 
            %legend boxoff;
            ticks = t(1):(t(end)-t(1))/7:t(end);
            set(gca, 'XMinorTick', 'on', 'XLim', [t(1) t(end)], 'XTick', ticks, 'XTickLabel', timeround(datestr(ticks, 'HH:MM:SS'), handles.roundNearest));
                
            %set(handles.axes(index), 'YScale', 'log');
            
            set(handles.axes(index), 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});
        end
        set(handles.LinearY, 'Value', 1.0);
        set(handles.StartTime, 'String', datestr(t(1), 'HHMMSS'));
        set(handles.EndTime, 'String', datestr(t(end), 'HHMMSS'));
        set(handles.LegendOn, 'Value', 1.0);
        guidata(hObject, handles);
        if(handles.selected ~= 0)
            subplot(handles.axes(handles.selected));
        end
end

% --- Executes on button press in XLabelButton.
function XLabelButton_Callback(hObject, eventdata, handles)
% hObject    handle to XLabelButton (see GCBO)
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

% --- Executes on button press in YLabelButton.
function YLabelButton_Callback(hObject, eventdata, handles)
% hObject    handle to YLabelButton (see GCBO)
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
% --- Executes on button press in TitleButton.
function TitleButton_Callback(hObject, eventdata, handles)
% hObject    handle to TitleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = 'Enter new graph title:';
title = 'Edit graph title';
l = 1;
Answer = {get(handles.TSTitle, 'String')};
newTitle = inputdlg(prompt, title, l, Answer);
if(~isempty(newTitle))
    
    set(handles.TSTitle, 'String', newTitle);
    guidata(hObject, handles);
end
% Enables all of the greyed out options
function EnableAllButtons(handles)


set(handles.ResetMenu, 'Enable', 'on');
set(handles.SaveMenu, 'Enable', 'on');
set(handles.StartTime, 'Enable', 'on');
set(handles.EndTime, 'Enable', 'on');
set(handles.ResetMenu, 'Enable', 'on');
set(handles.XAxisLabelMenu, 'Enable', 'on');
set(handles.YAxisLabelMenu, 'Enable', 'on');
set(handles.HeightPlotButton, 'Enable', 'on');
set(handles.SDMenu, 'Enable', 'on');
set(handles.SDButton, 'Enable', 'on');
set(handles.XLabelButton, 'Enable', 'on');
set(handles.YLabelButton, 'Enable', 'on');
set(handles.CIPImgButton, 'Enable', 'on');
set(handles.defaultsButton, 'Enable', 'on');
set(handles.YMin, 'Enable', 'on');
set(handles.YMax, 'Enable', 'on');
set(handles.SaveButton, 'Enable', 'on');
set(handles.PrintButton, 'Enable', 'on');
set(handles.PrintMenu, 'Enable', 'on');
set(handles.ZoomXButton, 'Enable', 'on');
set(handles.ZoomYButton, 'Enable', 'on');
set(handles.ZoomXMenu, 'Enable', 'on');
set(handles.ZoomYMenu, 'Enable', 'on');
set(handles.LinearY, 'Enable', 'on');
set(handles.SetAveFilter, 'Enable', 'on');
set(handles.GenHeightsMenu, 'Enable', 'on');
set(handles.SPMenu, 'Enable', 'on');
set(handles.SPButton, 'Enable', 'on');
set(handles.SeriesPlotButton, 'Enable', 'on');
set(handles.LegendOn, 'Enable', 'on');
set(handles.AutoscaleYButton, 'Enable', 'on');

% --- Executes on button press in SDButton.
function SDButton_Callback(hObject, eventdata, handles)
% hObject    handle to SDButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.n = 1;
handles.button = 0;
handles.x = [0 0];
handles.y = [0 0];
handles.EventClicked = 3;
set(gcf, 'Pointer', 'fullcross');
guidata(hObject, handles);
set(gca, 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});



function YMin_Callback(hObject, eventdata, handles)
% hObject    handle to YMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YMin as text
%        str2double(get(hObject,'String')) returns contents of YMin as a double

Min = str2double(get(hObject, 'String'));
Max = str2double(get(handles.YMax, 'String'));
if (Max < Min)
    errordlg('Minimum Y value must be less than or equal to the Maximum Y value!', 'Error');
    Range = get(gca, 'YLim');
    set(hObject, 'String', num2str(Range(1)));
else
    set(gca, 'YLim', [Min Max]);
end

% --- Executes during object creation, after setting all properties.
function YMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YMax_Callback(hObject, eventdata, handles)
% hObject    handle to YMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YMax as text
%        str2double(get(hObject,'String')) returns contents of YMax as a double
    Min = str2double(get(handles.YMin, 'String'));
    Max = str2double(get(hObject, 'String'));
    if (Min > Max)
        errordlg('Minimum Y value must be less than or equal to the Maximum Y value!', 'Error');
        Range = get(gca, 'YLim');
        set(hObject, 'String', num2str(Range(2)));
    else
        set(gca, 'YLim', [Min Max]);
    end

% --- Executes during object creation, after setting all properties.
function YMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uiputfile({'*.jpg;', 'JPEG Images (*.jpg)'}, 'Select a destination JPEG file');
oldpath = pwd;

if ~isequal(file, 0)
    index = find(gca == handles.axes);
    oldaxes = gca;
    t = handles.cdfhandle{'timevec'}(:);


    
    figure
    
    N = zeros(handles.numVars(index), length(t));
    for i=1:handles.numVars(index)
        N(i, :) = handles.cdfhandle{handles.var_name{index}{i}}(:);
        N(i, :) = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N(i, :));
    end

    plot(t, N);
    datetick('x', 'HH:MM:SS');
    xlabel(get(get(oldaxes, 'XLabel'), 'String'));
    ylabel(get(get(oldaxes, 'YLabel'), 'String'));
    title(get(handles.TSTitle, 'String'));
    legend(handles.short_names{index});
    %legend boxoff;
    begin = str2num(get(handles.StartTime, 'String'));
  
    ending = str2num(get(handles.EndTime, 'String'));
    if(get(handles.LinearY, 'Value') == 0.0)
         set(gca, 'YScale', 'log');
    end
    if(~isnan(begin) && ~isnan(ending))
        times = handles.cdfhandle{'time'}(:);
        timevec = handles.cdfhandle{'timevec'}(:);
        begin_index = find(times == begin);
        end_index = find(times == ending);
        ticks = timevec(begin_index):(timevec(end_index)-timevec(begin_index))/7:timevec(end_index);
        set(gca, 'XMinorTick', 'on', 'XLim', [timevec(begin_index) timevec(end_index)]);
        set(gca, 'XTick', ticks, 'XTickLabel', datestr(ticks, 'HH:MM:SS'));
        YLims = get(oldaxes, 'YLim');
        if(get(handles.LinearY, 'Value') == 0.0)
             set(gca, 'YScale', 'log');
             yticks = 10.^(linspace(log10(YLims(1)), log10(YLims(2)), 6));
        else
             yticks = linspace(YLims(1), YLims(2), 4);
        end     
        set(gca, 'YMinorTick', 'on',  'YLim', YLims, 'YTick', yticks);
    end

    cd(path);
    print(gcf, '-djpeg', file);
    cd(oldpath);
end

% ----------------------------------------\----------------------------
function SDMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SDMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.n = 1;
handles.button = 0;
handles.x = [0 0];
handles.y = [0 0];
handles.EventClicked = 3;
set(gcf, 'Pointer', 'fullcrossair');
guidata(hObject, handles);
set(gca, 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});


    
% --------------------------------------------------------------------
function PrintMenu_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = find(gca == handles.axes);
oldaxes = gca;
t = handles.cdfhandle{'timevec'}(:);

figure

N = zeros(handles.numVars(index), length(t));
for i=1:handles.numVars(index)
    N(i, :) = handles.cdfhandle{handles.var_name{index}{i}}(:);
    N(i, :) = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N(i, :));
end

plot(t, N);
datetick('x', 'HH:MM:SS');
xlabel(get(get(oldaxes, 'XLabel'), 'String'));
ylabel(get(get(oldaxes, 'YLabel'), 'String'));
title(get(handles.TSTitle, 'String'));
legend(handles.short_names{index});
%legend boxoff;
begin = str2num(get(handles.StartTime, 'String'));
  
ending = str2num(get(handles.EndTime, 'String'));
if(get(handles.LinearY, 'Value') == 0.0)
         set(gca, 'YScale', 'log');
end
if(~isnan(begin) && ~isnan(ending))
    times = handles.cdfhandle{'time'}(:);
    timevec = handles.cdfhandle{'timevec'}(:);
    begin_index = find(times == begin);
    end_index = find(times == ending);
    ticks = timevec(begin_index):(timevec(end_index)-timevec(begin_index))/7:timevec(end_index);
    set(gca, 'XMinorTick', 'on', 'XLim', [timevec(begin_index) timevec(end_index)]);
    set(gca, 'XTick', ticks, 'XTickLabel', datestr(ticks, 'HH:MM:SS'));
    YLims = get(oldaxes, 'YLim');
    if(get(handles.LinearY, 'Value') == 0.0)
         set(gca, 'YScale', 'log');
         yticks = 10.^(linspace(log10(YLims(1)), log10(YLims(2)), 6));
    else
         yticks = linspace(YLims(1), YLims(2), 4);
    end     
    set(gca, 'YMinorTick', 'on',  'YLim', YLims, 'YTick', yticks);
    print(gcf);
end

delete(gcf);


% --- Executes on button press in PrintButton.
function PrintButton_Callback(hObject, eventdata, handles)
% hObject    handle to PrintButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = find(gca == handles.axes);
oldaxes = gca;
t = handles.cdfhandle{'timevec'}(:);

figure

N = zeros(handles.numVars(index), length(t));
for i=1:handles.numVars(index)
    N(i, :) = handles.cdfhandle{handles.var_name{index}{i}}(:);
    N(i, :) = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N(i, :));
end

plot(t, N);
datetick('x', 'HH:MM:SS');
xlabel(get(get(oldaxes, 'XLabel'), 'String'));
ylabel(get(get(oldaxes, 'YLabel'), 'String'));
title(get(handles.TSTitle, 'String'));
legend(handles.short_names{index});
%legend boxoff;
begin = str2num(get(handles.StartTime, 'String'));
  
ending = str2num(get(handles.EndTime, 'String'));
if(get(handles.LinearY, 'Value') == 0.0)
         set(gca, 'YScale', 'log');
end
if(~isnan(begin) && ~isnan(ending))
    times = handles.cdfhandle{'time'}(:);
    timevec = handles.cdfhandle{'timevec'}(:);
    begin_index = find(times == begin);
    end_index = find(times == ending);
    ticks = timevec(begin_index):(timevec(end_index)-timevec(begin_index))/7:timevec(end_index);
    set(gca, 'XMinorTick', 'on', 'XLim', [timevec(begin_index) timevec(end_index)]);
    set(gca, 'XTick', ticks, 'XTickLabel', datestr(ticks, 'HH:MM:SS'));
    YLims = get(oldaxes, 'YLim');
    if(get(handles.LinearY, 'Value') == 0.0)
         set(gca, 'YScale', 'log');
         yticks = 10.^(linspace(log10(YLims(1)), log10(YLims(2)), 6));
    else
         yticks = linspace(YLims(1), YLims(2), 4);
    end     
    set(gca, 'YMinorTick', 'on',  'YLim', YLims, 'YTick', yticks);
    print(gcf);
end

delete(gcf);

% --- Executes on button press in ZoomXButton.
function ZoomXButton_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomXButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.n = 1;
handles.button = 0;
handles.x = [0 0];
handles.y = [0 0];
handles.EventClicked = 1;
set(gcf, 'Pointer', 'fullcross');
guidata(hObject, handles);
set(gca, 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});

    

% --- Executes on button press in ZoomYButton.
function ZoomYButton_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomYButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.n = 1;
handles.button = 0;
handles.x = [0 0];
handles.y = [0 0];
handles.EventClicked = 2;
set(gcf, 'Pointer', 'fullcross');
guidata(hObject, handles);
set(gca, 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});   

% --------------------------------------------------------------------
function ZoomXMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomXMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   
handles.n = 1;
handles.button = 0;
handles.x = [0 0];
handles.y = [0 0];
handles.EventClicked = 1;
set(gcf, 'Pointer', 'fullcross');
guidata(hObject, handles);
set(gca, 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});


% --------------------------------------------------------------------
function ZoomYMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomYMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.n = 1;
handles.button = 0;
handles.x = [0 0];
handles.y = [0 0];
handles.EventClicked = 2;
set(gcf, 'Pointer', 'fullcross');
guidata(hObject, handles);
set(gca, 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});

    


% --------------------------------------------------------------------
function ChangeProbeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeProbeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



[Selection, ok] = listdlg('ListString', handles.ProbeShortNames, 'Name', 'Select a Probe', ... 
                          'SelectionMode', 'multiple', ...
                          'PromptString', 'List of Time Series Variables:');                          
% Replot the new graph
if(ok == 1)
     index = find(handles.axes == gca);
     handles.var_name{index} = {};
     handles.long_names{index} = {};
     handles.short_names{index} = {};
     handles.numVars(index) = 0;
     T = handles.cdfhandle{'timevec'}(:);
     times = handles.cdfhandle{'time'}(:);
     for(i=1:length(Selection))
         handles.var_name{index} = [handles.var_name{index} handles.Probes{Selection(i)}];
         unitName = handles.cdfhandle{handles.Probes{Selection(i)}}.units(:); 
         handles.long_names{index} = [handles.long_names{index} [handles.ProbeLongNames{Selection(i)} ' (' unitName ')']];
         handles.short_names{index} = [handles.short_names{index} [handles.ProbeShortNames{Selection(i)} ' (' unitName ')']];
     end 
     handles.numVars(index) = length(Selection);
     % Are the times within specified ranges
     StartIndex = find(times == str2double(get(handles.StartTime, 'String')));
     EndIndex = find(times == str2double(get(handles.EndTime, 'String')));
     
     N = zeros(handles.numVars(index), length(T));
     for i=1:handles.numVars(index)
        N(i, :) = handles.cdfhandle{handles.var_name{index}{i}}(:);
        N(i, :) = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N(i, :));
     end
     plot(gca, T, N, 'HitTest', 'off');    
     xlabel('Time');
     ylabel('');
     
     Pos = get(gca, 'Position');
     LegendPos = [Pos(1)+.67 Pos(2) .25 Pos(4)];
     
     legend(handles.short_names{index}, 'Location', LegendPos); 
     %legend boxoff;
     ticks = T(StartIndex):(T(EndIndex)-T(StartIndex))/7:T(EndIndex);
     set(handles.axes(:), 'XMinorTick', 'on', 'XLim', [T(StartIndex) T(EndIndex)], 'XTick', ticks, 'XTickLabel', timeround(datestr(ticks, 'HH:MM:SS'), handles.roundNearest));
     set(gca, 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles}); 
     if(get(handles.LinearY, 'Value') == 0.0)
         set(gca, 'YScale', 'log');
     end
     Y = get(gca, 'YLim');
     set(handles.YMin, 'String', num2str(Y(1)));
     set(handles.YMax, 'String', num2str(Y(2)));
     if(isequal(get(gca, 'Selected'), 'on'))
         handles.selected = index;
     else
         handles.selected = 0;
     end    
     handles.numVars(index) = 1;
     
     set(handles.ProbeMenuItem, 'Callback', {@ChangeProbeMenu_Callback, handles});
     set(handles.ProbeMenuItem2, 'Callback', {@FigureMenu_Callback, handles});
     set(handles.ProbeMenuItem3, 'Callback', {@AddProbeMenu_Callback, handles});
     
     if(get(handles.LegendOn, 'Value') == 0.0)     
            legend('toggle');
            AxesPos = get(gca, 'Position');
            %AxesPos(3) = AxesPos(3) + .25;
            %set(gca, 'Position', AxesPos);
     end   
     guidata(gcbo, handles);
end


% --- Executes on button press in LinearY.
function LinearY_Callback(hObject, eventdata, handles)
% hObject    handle to LinearY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LinearY

if(get(hObject, 'Value') == 0.0)
    set(gca, 'YScale', 'log');
else
    set(gca, 'YScale', 'linear');
end
YLims = get(gca, 'YLim');
set(handles.YMin, 'String', num2str(YLims(1)));
set(handles.YMax, 'String', num2str(YLims(2)));

% --------------------------------------------------------------------
function GenHeightsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to GenHeightsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.n = 1;
handles.button = 0;
handles.x = [0 0];
handles.y = [0 0];
handles.EventClicked = 4;
set(gcf, 'Pointer', 'fullcross');
guidata(hObject, handles);
set(gca, 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});


 
     
    


% --------------------------------------------------------------------
function SetAveFilter_Callback(hObject, eventdata, handles)
% hObject    handle to SetAveFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = 'Enter averaging window in seconds:';
title = 'Data Filter';
l = 1;
Answer = {num2str(handles.aveWindow)};
newFilter = str2double(inputdlg(prompt, title, l, Answer));
if(~isnan(newFilter))
    handles.aveWindow = newFilter;
    timevec = handles.cdfhandle{'timevec'}(:);
    for index=1:handles.numPlots
        N = zeros(1, length(timevec));
        cla(handles.axes(index));
        subplot(handles.axes(index));
        hold all;
        for i=1:handles.numVars(index)
            N(:) = handles.cdfhandle{handles.var_name{index}{i}}(:);
            N(:) = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N(:));
            plot(timevec, N, 'HitTest', 'off');
        end
        hold off;
        YLims = get(handles.axes(index), 'YLim');
        
        
        
        Pos = get(gca, 'Position');
        LegendPos = [Pos(1)+.67 Pos(2) .25 Pos(4)];
        legend(handles.short_names{index}, 'Location', LegendPos);
        %legend boxoff;
       % begin = str2num(get(handles.StartTime, 'String'));
  
        %ending = str2num(get(handles.EndTime, 'String'));
%        if(get(handles.LinearY, 'Value') == 0.0)
%             set(gca, 'YScale', 'log');
%        end
%        if(~isnan(begin) && ~isnan(ending))
%            times = handles.cdfhandle{'time'}(:);
%            begin_index = find(times == begin);
%            end_index = find(times == ending);
%            ticks = timevec(begin_index):(timevec(end_index)-timevec(begin_index))/7:timevec(end_index);
%            set(gca, 'XMinorTick', 'on', 'XLim', [timevec(begin_index) timevec(end_index)]);
%            set(gca, 'XTick', ticks, 'XTickLabel', datestr(ticks, 'HH:MM:SS'));
         
%            set(gca, 'YLim', YLims);
%        end
        CurCallback = {@ChangeProbeMenu_Callback, handles};
        set(handles.ProbeMenuItem, 'Callback', CurCallback);
        set(handles.ProbeMenuItem2, 'Callback', {@FigureMenu_Callback, handles});
        set(handles.ProbeMenuItem3, 'Callback', {@AddProbeMenu_Callback, handles});
        
        set(handles.axes(:), 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});
        guidata(hObject, handles);
        if(get(handles.LegendOn, 'Value') == 0.0)     
            legend('toggle');
            AxesPos = get(gca, 'Position');
            %AxesPos(3) = AxesPos(3) + .25;
            %set(gca, 'Position', AxesPos);
        end   
    end
end    


% --------------------------------------------------------------------
function SPMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SPMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.n = 1;
handles.button = 0;
handles.x = [0 0];
handles.y = [0 0];
handles.EventClicked = 5;
set(gcf, 'Pointer', 'fullcross');
guidata(hObject, handles);
set(gca, 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});



    



% --- Executes on button press in SPButton.
function SPButton_Callback(hObject, eventdata, handles)
% hObject    handle to SPButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.n = 1;
handles.button = 0;
handles.x = [0 0];
handles.y = [0 0];
handles.EventClicked = 5;
set(gcf, 'Pointer', 'fullcross');
guidata(hObject, handles);
set(gca, 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});


% --- Executes on button press in SeriesPlotButton.
function SeriesPlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to SeriesPlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.n = 1;
handles.button = 0;
handles.x = [0 0];
handles.y = [0 0];
handles.EventClicked = 6;
set(gcf, 'Pointer', 'fullcross');
guidata(hObject, handles);
set(gca, 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});




% --------------------------------------------------------------------
function OpenStateMenu_Callback(hObject, eventdata, handles)
% hObject    handle to OpenStateMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uigetfile({'*.mat;', 'MATLAB MAT files (*.mat)'}, 'Select a destination MAT file');
oldpath = pwd;

if ~isequal(file, 0)
    cd(path);
    load(file);
    set(handles.StartTime, 'String', num2str(StartTime));
    set(handles.EndTime, 'String', num2str(EndTime));
    handles.var_name = var_name;
    handles.FileName = FileName;
    handles.Path = Path;
    handles.numVars = numVars;
    cd(Path)
    handles.cdfhandle = netcdf(handles.FileName, 'nowrite');
    cd(oldpath);
    handles.Probes = Probes;
    handles.ProbeLongNames = ProbeLongNames;
    handles.ProbeShortNames = ProbeShortNames;
    handles.numPlots = numPlots;
    handles.long_names = long_names;
    handles.short_names = short_names;
    handles.aveWindow = aveWindow;
    handles.roundNearest = roundNearest;
    times = handles.cdfhandle{'time'}(:);
    unixtimes = handles.cdfhandle{'timevec'}(:);
    StartIndex = find(times == StartTime);
    EndIndex = find(times == EndTime);
    T(1) = unixtimes(StartIndex);
    T(2) = unixtimes(EndIndex);
    handles.axes = 1:handles.numPlots;
    handles.FirstOpen = 0;
    guidata(gcbo, handles);
    for i=1:handles.numPlots
        handles.axes(i) = subplot('position', [handles.AxesX handles.AxesY+(i-1)*(handles.AxesH+0.04) handles.AxesW (1-0.1*(handles.numPlots-1))*handles.AxesH]);
        hold all;
        for j=1:handles.numVars(i)
            N = handles.cdfhandle{handles.var_name{i}{j}}(:);
            N(:) = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N(:));;
            plot(handles.axes(i), unixtimes, N, 'HitTest', 'off');
        end
        hold off;
        ticks = linspace(T(1), T(2), 8);
        set(gca, 'XLim',  T, 'XTick', ticks, 'XTickLabel', timeround(datestr(ticks, 'HH:MM:SS'), handles.roundNearest), 'YLim', y{i}, 'XMinorTick', 'on');
        if(Linears(i) == 0)
            set(gca, 'YScale', 'log');
        else
            set(gca, 'YScale', 'linear');
        end
        xlabel(XLabels{i});
        ylabel(YLabels{i});
        Pos = get(gca, 'Position');
        LegendPos = [Pos(1)+.67 Pos(2) .25 Pos(4)];
        NewAxisPos = [Pos(1) Pos(2) .65 Pos(4)];
        set(gca, 'Position', NewAxisPos);
        legend(handles.short_names{i}, 'Location', LegendPos);
        if(LegendOn == 0.0)                 
            AxesPos = get(gca, 'Position');
            AxesPos(3) = AxesPos(3) + .25;
            set(gca, 'Position', AxesPos);
        end
    end        
    set(handles.LegendOn, 'Value', LegendOn);
     
        
    set(handles.TSTitle, 'String', Title);
    
    set(gcbf, 'Name', ['Time Series Viewer - ' handles.FileName]);
    % Initalize the Probe Menu
    handles.ProbeMenu = uicontextmenu;
    
    handles.ProbeMenuItem = uimenu(handles.ProbeMenu, 'Label', 'Clear All And Select A Different Probe', 'Callback', {@ChangeProbeMenu_Callback, handles});
    handles.ProbeMenuItem2 = uimenu(handles.ProbeMenu, 'Label', 'View in Separate Figure', 'Callback', {@FigureMenu_Callback, handles});
    handles.ProbeMenuItem3 = uimenu(handles.ProbeMenu, 'Label', 'Add Another Probe To View', 'Callback', {@AddProbeMenu_Callback, handles});
    %handles.ProbeMenuItem4 = uimenu(handles.ProbeMenu, 'Label', 'Create a Height-Based Plot', 'Callback', {@GenHeightsMenu_Callback, handles});
    set(handles.ProbeMenuItem, 'Callback', {@ChangeProbeMenu_Callback, handles});
    set(handles.ProbeMenuItem2, 'Callback', {@FigureMenu_Callback, handles});
    set(handles.ProbeMenuItem3, 'Callback', {@AddProbeMenu_Callback, handles});
   % set(handles.ProbeMenuItem4, 'Callback', {@GenHeightsMenu_Callback, handles});
    guidata(gcbo, handles);
    
    if(SDExists == 1)
        handles.SDXLim = SDXLim;
        handles.SDYLim = SDYLim;
        handles.SDLinearX = SDLinearX;
        handles.SDLinearY = SDLinearY;
        handles.SDVariables = SDVariables;
        handles.SDCurBins = SDCurBins;
        handles.SDCurBinLocs = SDCurBinLocs;
        handles.SDCurLongNames = SDCurLongNames;
        handles.SDCurShortNames = SDCurShortNames;
        handles.SDConcVariables = SDConcVariables;
        handles.SDConcBinSizeNames = SDConcBinSizeNames;
        handles.SDConcBinLocNames = SDConcBinLocNames;
        handles.SDConcBinLongNames = SDConcBinLongNames;
        handles.SDConcBinShortNames = SDConcBinShortNames;
        handles.SDStartTime = SDStartTime;
        handles.SDEndTime = SDEndTime;
        handles.SDMoment = SDMoment;
        handles.SDND = SDND;
        handles.SDNDdD = SDNDdD;
        handles.SDNDdlogD = SDNDdlogD;
        handles.SDXlabel = SDXlabel;
        handles.SDYlabel = SDYlabel;
        handles.SDTitle = SDTitle;
        handles.SDNumVars = SDNumVars;
        handles.SDLoad = 1;
        guidata(hObject, handles)
        handles.SDViewer = sdviewer('TSViewer', gcbf);    
        handles.SDLoad = 0;
    end
    if(SPExists == 1)
        handles.SP_y_var_names = SP_y_var_names;
        handles.SP_y_long_names = SP_y_long_names;
        handles.SP_y_numVars = SP_y_numVars;
        handles.SP_x_var_name = SP_x_var_name;
        handles.SP_x_var_long_name = SP_x_var_long_name;
        handles.SP_y_short_names = SP_y_short_names;
        handles.SP_StartTime = SP_StartTime;
        handles.SP_EndTime = SP_EndTime;
        handles.SP_XLabel = SP_XLabel;
        handles.SP_YLabel = SP_YLabel;
        handles.SP_Title = SP_Title;
        handles.SPXLim = SPXLim;
        handles.SPYLim = SPYLim;
        handles.SPLinearX = SPLinearX;
        handles.SPLinearY = SPLinearY;
        handles.SPLoad = 1;
        handles.SPOneToOne = SPOneToOne;
        guidata(hObject, handles);
        handles.SPViewer = spviewer('TSViewer', gcbf);
        handles.SPLoad = 0;
    end
    if(HExists == 1)
        handles.Hvar_names = Hvar_names;
        handles.Hlong_names = Hlong_names;
        handles.HnumVars = HnumVars;
        handles.HaveWindow = HaveWindow;
        handles.HStartTime = HStartTime;
        handles.HEndTime = HEndTime
        handles.HXLim = HXLim;
        handles.HHLim = HHLim;
        handles.HXLabel = HXLabel;
        handles.HHLabel = HHLabel;
        handles.HTitle = HTitle;
        handles.HLinearX = HLinearX;
        handles.HLinearH = HLinearH;
        handles.HLoad = 1;
        guidata(hObject, handles);
        handles.HViewer = hviewer('TSViewer', gcbf);
        handles.HLoad = 0;
    end
    guidata(gcbo, handles);
    if(CIPExists == 1)
        handles.CIP_CurFrame = CIP_CurFrame;
        handles.CIP_FrameWindow = CIP_FrameWindow;
        handles.CIP_filename = CIP_filename;
        handles.CIP_StartTime = CIP_StartTime;
        handles.CIP_EndTime = CIP_EndTime;
        handles.CIPLoad = 1;
        handles.CIP_Vars = CIP_Vars;
        handles.CIP_path = CIP_path;
        handles.CIP_FlagColorBox = CIP_FlagColor;
        guidata(hObject, handles);
        handles.CIPViewer = cipviewer('TSViewer', gcbf);
        handles.CIPLoad = 0;
    end
    
    set(handles.axes(:), 'UIContextMenu', handles.ProbeMenu);
    set(handles.axes(:), 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});
    set(handles.SaveStateMenu, 'Enable', 'on');
    set(handles.SetVarNumMenu, 'Enable', 'on');
    set(handles.TitleSet, 'Enable', 'on');
    set(handles.TitleButton, 'Enable', 'on');
    set(handles.SaveAllMenu, 'Enable', 'on');
    set(handles.SaveAllButton, 'Enable', 'on');
    set(handles.WholeFlightMenu, 'Enable', 'on');
    set(handles.WholeFlightButton, 'Enable', 'on');
    cd(oldpath);
end    
% --------------------------------------------------------------------
function SaveStateMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SaveStateMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uiputfile({'*.mat;', 'MATLAB MAT files (*.mat)'}, 'Select a destination MAT file');
oldpath = pwd;

if ~isequal(file, 0)
    cd(path);
    y = get(handles.axes(:), 'YLim');
    Title = get(handles.TSTitle, 'String')
    for i=1:handles.numPlots
        XLabels{i} = get(get(handles.axes(i), 'XLabel'), 'String');
        YLabels{i} = get(get(handles.axes(i), 'YLabel'), 'String');
        
        if(isequal(get(handles.axes(i), 'YScale'), 'log'))
            Linears(i) = 0;
        else
            Linears(i) = 1;
        end
    end    
    StartTime = str2double(get(handles.StartTime, 'String'));
    EndTime = str2double(get(handles.EndTime, 'String'));
    var_name = handles.var_name;
    FileName = handles.FileName;
    Path = handles.Path
    numVars = handles.numVars;
    Probes = handles.Probes;
    ProbeLongNames = handles.ProbeLongNames;
    ProbeShortNames = handles.ProbeShortNames;
    long_names = handles.long_names;
    numPlots = handles.numPlots;
    aveWindow = handles.aveWindow;
    roundNearest = handles.roundNearest;
    LegendOn = handles.LegendOn;
    short_names = handles.short_names;
    save(file, 'StartTime', 'EndTime', 'var_name', 'y', 'FileName', 'numVars', 'Probes', 'ProbeLongNames', 'numPlots')
    save(file, '-APPEND', 'XLabels', 'YLabels', 'Title', 'long_names', 'Linears', 'aveWindow', 'roundNearest', 'LegendOn', 'ProbeShortNames', 'Path', 'short_names')
    if(handles.SDViewer == 0 || ~ishandle(handles.SDViewer))
        SDExists = 0;
        save(file, '-APPEND', 'SDExists');
    else
        SDExists = 1;
        SDData = guidata(handles.SDViewer);
        SDXLim = get(SDData.SDAxes, 'XLim');
        SDYLim = get(SDData.SDAxes, 'YLim');
        SDLinearX = get(SDData.LinearX, 'Value');
        SDLinearY = get(SDData.LinearY, 'Value');
        SDVariables = SDData.curvar;
        SDCurBins = SDData.CurBins;
        SDCurBinLocs = SDData.CurBinLocs;
        SDCurLongNames = SDData.CurLongNames;
        SDConcVariables = SDData.ConcVariables;
        SDConcBinSizeNames = SDData.ConcBinSizeNames;
        SDConcBinLocNames = SDData.ConcBinLocNames;
        SDConcBinLongNames = SDData.ConcBinLongNames;
        SDStartTime = get(SDData.StartTime, 'String');
        SDEndTime = get(SDData.EndTime, 'String');
        SDMoment = str2double(get(SDData.Moment, 'String'));
        SDND = get(SDData.NDButton, 'Value');
        SDNDdD = get(SDData.NDdD, 'Value');
        SDNDdlogD = get(SDData.NDdlogD, 'Value');
        SDXlabel = SDData.XLbl;
        SDYlabel = SDData.YLbl;
        SDTitle = SDData.Title;
        SDNumVars = SDData.NumVars;
        SDConcBinShortNames = SDData.ConcBinShortNames;
        SDCurShortNames = SDData.CurShortNames;
        save(file, '-APPEND', 'SDExists', 'SDXLim', 'SDYLim', 'SDLinearX', 'SDLinearY', 'SDVariables', 'SDCurBins');
        save(file, '-APPEND', 'SDCurBinLocs', 'SDCurLongNames', 'SDConcVariables', 'SDConcBinSizeNames', 'SDConcBinLocNames');
        save(file, '-APPEND', 'SDConcBinLongNames', 'SDStartTime', 'SDEndTime', 'SDMoment', 'SDND', 'SDNDdD', 'SDNDdlogD');
        save(file, '-APPEND', 'SDXlabel', 'SDYlabel', 'SDTitle', 'SDNumVars', 'SDConcBinShortNames', 'SDCurShortNames');
    end    
    if(handles.HViewer == 0 || ~ishandle(handles.HViewer))
        HExists = 0;
        save(file, '-APPEND', 'HExists');
    else
        HData = guidata(handles.HViewer);
        HExists = 1;
        Hvar_names = HData.var_names;
        Hlong_names = HData.long_names;
        Hshort_names = HData.short_names;
        HnumVars = HData.numVars;
        HaveWindow = HData.aveWindow;
        HStartTime = get(HData.StartTime, 'String');
        HEndTime = get(HData.EndTime, 'String');
        HXLim = get(HData.HVAxes, 'XLim');
        HHLim = get(HData.HVAxes, 'YLim');
        HXLabel = get(get(HData.HVAxes, 'XLabel'), 'String');
        HHLabel = get(get(HData.HVAxes, 'YLabel'), 'String');
        HTitle = get(get(HData.HVAxes, 'Title'), 'String');
        HLinearX = get(HData.LinearX, 'Value');
        HLinearH = get(HData.LinearH, 'Value');
        save(file, '-APPEND', 'HExists', 'Hvar_names', 'Hlong_names', 'HnumVars', 'HaveWindow', 'HStartTime', 'HEndTime');
        save(file, '-APPEND', 'HXLim', 'HHLim', 'HXLabel', 'HHLabel', 'HTitle', 'HLinearX', 'HLinearH', 'Hshort_names');
    end
    if(handles.SPViewer == 0 || ~ishandle(handles.SPViewer))
        SPExists = 0;
        save(file, '-APPEND', 'SPExists');
    else
        SPExists = 1;
        SPData = guidata(handles.SPViewer);
        SP_y_var_names = SPData.y_var_names;
        SP_y_long_names = SPData.y_long_names;
        SP_y_short_names = SPData.y_short_names;       
        SP_y_numVars = SPData.y_numVars;
        SP_x_var_name = SPData.x_var_name;
        SP_x_var_long_name = SPData.x_var_long_name;
        SP_StartTime = get(SPData.StartTime, 'String');
        SP_EndTime = get(SPData.EndTime, 'String');
        SP_XLabel = get(get(SPData.SPAxes, 'XLabel'), 'String');
        SP_YLabel = get(get(SPData.SPAxes, 'YLabel'), 'String');
        SP_Title = get(get(SPData.SPAxes, 'Title'), 'String');
        SPXLim = get(SPData.SPAxes, 'XLim');
        SPYLim = get(SPData.SPAxes, 'YLim');
        SPLinearX = get(SPData.LinearX, 'Value');
        SPLinearY = get(SPData.LinearY, 'Value');
        SPOneToOne = get(SPData.OneToOne, 'Value');
        save(file, '-APPEND', 'SP_y_var_names', 'SP_y_long_names', 'SP_y_numVars', 'SP_x_var_name', 'SP_x_var_long_name');
        save(file, '-APPEND', 'SP_StartTime', 'SP_EndTime', 'SP_XLabel', 'SP_YLabel', 'SP_Title', 'SPXLim', 'SPYLim');
        save(file, '-APPEND', 'SPLinearX', 'SPLinearY', 'SPExists', 'SPOneToOne', 'SP_y_short_names');    
    end
    if(handles.CIPViewer == 0 || ~ishandle(handles.CIPViewer))
        CIPExists = 0;
        save(file, '-APPEND', 'CIPExists');
    else
        CIPExists = 1;
        CIPData = guidata(handles.CIPViewer);
        CIP_CurFrame = CIPData.CurFrame;
        CIP_FrameWindow = CIPData.FrameWindow;
        CIP_filename = CIPData.filename;
        CIP_path = CIPData.path;
        CIP_StartTime = get(CIPData.StartTime, 'String');
        CIP_EndTime = get(CIPData.EndTime, 'String');
        CIP_Vars = CIPData.CIPVars;
        CIP_FlagColor = get(CIPData.FlagColorBox, 'Value');
        save(file, '-APPEND', 'CIPExists', 'CIPData', 'CIP_CurFrame', 'CIP_FrameWindow', 'CIP_filename', 'CIP_StartTime', 'CIP_EndTime', 'CIP_Vars', 'CIP_path', 'CIP_FlagColor');
    end
    
    cd(oldpath);
end


% --------------------------------------------------------------------
function SetVarNumMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SetVarNumMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = 'Enter number of plots (max 10):';
title = 'Change # of plots';
l = 1;
Answer = {num2str(handles.numPlots)};
newFilter = str2double(inputdlg(prompt, title, l, Answer));
if(~isnan(newFilter))
    if(newFilter < 11)
        time = handles.cdfhandle{'time'}(:);
        unixtime = handles.cdfhandle{'timevec'}(:);
        oldNumPlots = handles.numPlots;
        if(handles.numPlots == 1)
            OldYLims = {get(handles.axes(:), 'YLim')};
        else
            OldYLims = get(handles.axes(:), 'YLim');
        end  
        handles.numPlots = newFilter;
        handles.axes = 1:handles.numPlots;
        handles.AxesX = 0.055;
        handles.AxesY = 0.18;
        handles.AxesW = 0.935;
        handles.AxesH = (1-0.03*(handles.numPlots)-.18)/(handles.numPlots);
        StartIndex = find(time == str2double(get(handles.StartTime, 'String')));
        EndIndex = find(time == str2double(get(handles.EndTime, 'String')));
         
        subplot(1,1,1);
        for i = 1:handles.numPlots
            handles.axes(i) = subplot('position', [handles.AxesX handles.AxesY+(i-1)*(handles.AxesH+0.04) handles.AxesW (1-0.07*(handles.numPlots-1))*handles.AxesH]);
            ticks = linspace(unixtime(StartIndex), unixtime(EndIndex), 8);
            N = zeros(handles.numVars(i), length(unixtime));
            for j=1:handles.numVars(i)
                N(j, :) = handles.cdfhandle{handles.var_name{i}{j}}(:);
                N(j, :) = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N(j, :));
            end
            plot(gca, unixtime, N, 'HitTest', 'off');   
            xlabel('Time');
            ylabel(handles.cdfhandle{handles.var_name{i}{1}}.units(:));
            Pos = get(gca, 'Position');
            LegendPos = [Pos(1)+.67 Pos(2) .25 Pos(4)];
            NewAxisPos = [Pos(1) Pos(2) .65 Pos(4)];
            set(gca, 'Position', NewAxisPos);
            legend(handles.short_names{i}, 'Location', LegendPos); 
            if(get(handles.LegendOn, 'Value') == 0.0)     
                legend('toggle');
                AxesPos = get(gca, 'Position');
                AxesPos(3) = AxesPos(3) + .25;
                set(gca, 'Position', AxesPos);
            end
            set(handles.axes(i), 'XMinorTick', 'on', 'XLim', [unixtime(StartIndex) unixtime(EndIndex)]);
            set(handles.axes(i), 'XTick', ticks, 'XTickLabel', timeround(datestr(ticks, 'HH:MM:SS'), handles.roundNearest));
            if(i <= oldNumPlots)
                set(handles.axes(i), 'YLim', OldYLims{i});
            end
            
            if(get(handles.LinearY, 'Value') == 0.0)
                set(gca, 'YScale', 'log');    
            end        
        end
        set(handles.axes(handles.numPlots), 'Selected', 'on');
        handles.selected = handles.numPlots;
        set(handles.ProbeMenuItem, 'Callback', {@ChangeProbeMenu_Callback, handles});
        set(handles.ProbeMenuItem2, 'Callback', {@FigureMenu_Callback, handles});
        set(handles.ProbeMenuItem3, 'Callback', {@AddProbeMenu_Callback, handles});
        
        guidata(gcbo, handles);
    
        set(handles.axes(:), 'UIContextMenu', handles.ProbeMenu);
        set(handles.axes(:), 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});
    end
end
    


% --- Executes on button press in SaveAllButton.
function SaveAllButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uiputfile({'*.jpg;', 'JPEG Images (*.jpg)'}, 'Select a destination JPEG file');
oldpath = pwd;

if ~isequal(file, 0)
    figure;
    time = handles.cdfhandle{'time'}(:);
    unixtime = handles.cdfhandle{'timevec'}(:);
    StartIndex = find(time == str2double(get(handles.StartTime, 'String')));
    EndIndex = find(time == str2double(get(handles.EndTime, 'String')));
    for i=1:handles.numPlots
        subplot(handles.numPlots, 1, i);
        ticks = linspace(unixtime(StartIndex), unixtime(EndIndex), 7);
        N = zeros(handles.numVars(i), length(unixtime));
        for j=1:handles.numVars(i)
                N(j, :) = handles.cdfhandle{handles.var_name{i}{j}}(:);
                N(j, :) = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N(j, :));
        end
        plot(gca, unixtime, N);   
        xlabel(get(get(handles.axes(i), 'XLabel'), 'String'));
        ylabel(get(get(handles.axes(i), 'YLabel'), 'String'));
        Pos = get(gca, 'Position');
        LegendPos = [Pos(1)+.53 Pos(2) .35 Pos(4)];
        NewAxisPos = [Pos(1) Pos(2) .55 Pos(4)];
        set(gca, 'Position', NewAxisPos);
        legend(handles.short_names{i}, 'Location', LegendPos); 
        set(gca, 'XMinorTick', 'on', 'XLim', [unixtime(StartIndex) unixtime(EndIndex)]);
        set(gca, 'XTick', ticks, 'XTickLabel', datestr(ticks, 'HH:MM:SS'));
        Ylims = get(handles.axes(i), 'YLim');
        set(gca, 'YLim', Ylims, 'YMinorTick', 'on');
        if(isequal(get(handles.axes(i), 'YScale'), 'log'))
                set(gca, 'YScale', 'log');    
        end        
    end   
    suptitle(get(handles.TSTitle, 'String'));
    cd(path);
    print(gcf, '-djpeg', file);
    cd(oldpath); 
end

% --------------------------------------------------------------------
function SaveAllMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAllMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uiputfile({'*.jpg;', 'JPEG Images (*.jpg)'}, 'Select a destination JPEG file');
oldpath = pwd;

if ~isequal(file, 0)
    figure;
    time = handles.cdfhandle{'time'}(:);
    unixtime = handles.cdfhandle{'timevec'}(:);
    StartIndex = find(time == str2double(get(handles.StartTime, 'String')));
    EndIndex = find(time == str2double(get(handles.EndTime, 'String')));
    for i=1:handles.numPlots
        subplot(handles.numPlots, 1, i);
        ticks = linspace(unixtime(StartIndex), unixtime(EndIndex), 7);
        N = zeros(handles.numVars(i), length(unixtime));
        for j=1:handles.numVars(i)
                N(j, :) = handles.cdfhandle{handles.var_name{i}{j}}(:);
                N(j, :) = filter(ones(1, handles.aveWindow)/handles.aveWindow,1, N(j, :));
        end
        plot(gca, unixtime, N);   
        xlabel(get(get(handles.axes(i), 'XLabel'), 'String'));
        ylabel(get(get(handles.axes(i), 'YLabel'), 'String'));
        Pos = get(gca, 'Position');
        LegendPos = [Pos(1)+.53 Pos(2) .35 Pos(4)];
        NewAxisPos = [Pos(1) Pos(2) .55 Pos(4)];
        set(gca, 'Position', NewAxisPos);
        legend(handles.short_names{i}, 'Location', LegendPos); 
        set(gca, 'XMinorTick', 'on', 'XLim', [unixtime(StartIndex) unixtime(EndIndex)]);
        set(gca, 'XTick', ticks, 'XTickLabel', datestr(ticks, 'HH:MM:SS'));
        Ylims = get(handles.axes(i), 'YLim');
        set(gca, 'YLim', Ylims, 'YMinorTick', 'on');
        if(isequal(get(handles.axes(i), 'YScale'), 'log'))
                set(gca, 'YScale', 'log');    
        end        
    end   
    suptitle(get(handles.TSTitle, 'String'));
    cd(path);
    print(gcf, '-djpeg', file);
    cd(oldpath); 
end


% --- Executes on button press in WholeFlightButton.
function WholeFlightButton_Callback(hObject, eventdata, handles)
% hObject    handle to WholeFlightButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
time = handles.cdfhandle{'time'};
timevec = handles.cdfhandle{'timevec'};
for (i=1:handles.numPlots);
    subplot(handles.axes(i));
    xlim([timevec(1) timevec(end)]);
    ticks = timevec(1):(timevec(end)-timevec(1))/7:timevec(end);
    set(gca, 'XMinorTick', 'on', 'XTick', ticks, 'XTickLabel', timeround(datestr(ticks, 'HH:MM:SS'), handles.roundNearest));
    %datetick('x', 'HH:MM:SS');
end
set(handles.StartTime, 'String', num2str(time(1)));
set(handles.EndTime, 'String', num2str(time(end)));
if(handles.selected ~= 0)
    subplot(handles.axes(handles.selected));
end
% --------------------------------------------------------------------
function WholeFlightMenu_Callback(hObject, eventdata, handles)
% hObject    handle to WholeFlightMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
time = handles.cdfhandle{'time'};
timevec = handles.cdfhandle{'timevec'};
for (i=1:handles.numPlots);
    subplot(handles.axes(i));
    xlim([timevec(1) timevec(end)]);
    ticks = timevec(1):(timevec(end)-timevec(1))/7:timevec(end);
    set(gca, 'XMinorTick', 'on', 'XTick', ticks, 'XTickLabel', timeround(datestr(ticks, 'HH:MM:SS'), handles.roundNearest));
    %datetick('x', 'HH:MM:SS');
end
set(handles.StartTime, 'String', num2str(time(1)));
set(handles.EndTime, 'String', num2str(time(end)));
if(handles.selected ~= 0)
   subplot(handles.axes(handles.selected));
end
% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%axes(handles.axes(handles.selected));
%if(handles.EventClicked == 0)
%   set(handles.CursorText, 'Visible', 'off');
%else
%    set(handles.CursorText, 'Visible', 'on');
%    point = get(gca, 'CurrentPoint');
%    point_figure = get(gcf, 'CurrentPoint');
%    set(handles.CursorText, 'Position', [point_figure(1,1)+.1 point_figure(1,2)+.1 30.2 1.538], 'Units', 'Characters');
%    set(handles.CursorText, 'String', ['X: ' datestr(point(1,1), 'HH:MM:SS') ' Y: ' num2str(point(1,2), 5)]);
%end

    
% This function will take a cell array of time strings in format 'HH:MM:SS'
% and round them to the
% nearest x seconds, (where x is a factor 0f 60)
function roundstrings = timeround(strings, x)
    len = numel(strings)/8;
    roundstrings = {};
    for i = 1:len
        seconds = str2double(strings(i,7:8));
        hours = str2double(strings(i,1:2));
        minutes = str2double(strings(i,4:5));
        totaltime = hours*3600+ minutes*60 + seconds;
        secondsmin = x*floor(totaltime/x) - hours*3600 - minutes*60;
        secondsmax = secondsmin+x;  
        
        if((seconds - secondsmin) >= (secondsmax-seconds)) % Round up
            if(secondsmax > 59)
                roundedseconds = secondsmax - 60;
                roundedminutes = minutes+1;
                if(roundedminutes > 59)
                    roundedminutes = roundedminutes - 60;
                    roundedhours = roundedhours + 1;
                    if(roundedhours > 23)
                        roundedhours = roundedhours - 24;
                    end
                end
            else
                roundedseconds = secondsmax;
                roundedhours = hours;
                roundedminutes = minutes;
            end
        else
            if(secondsmin < 0)
                roundedseconds = secondsmin + 60;
                roundedminutes = minutes - 1;
                if(roundedminutes < 0)
                    roundedminutes = roundedminutes + 60
                    roundedhours = roundedhours - 1;
                    if(roundedhours < 0)
                        roundedhours = roundedhours + 24;
                    end
                end
            else
                roundedseconds = secondsmin;
                roundedhours = hours;
                roundedminutes = minutes;
            end
        end
        curtimestring = datestr(datenum(1, 1, 1, roundedhours, roundedminutes, roundedseconds), 'HH:MM:SS');
        roundstrings = [roundstrings curtimestring];
    end
  


% --------------------------------------------------------------------
function RoundMenu_Callback(hObject, eventdata, handles)
% hObject    handle to RoundMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


prompt = 'Enter the number of seconds to round the seconds to:';
title = 'Rounding';
l = 1;
Answer = {num2str(handles.roundNearest)};
newFilter = str2double(inputdlg(prompt, title, l, Answer));
if(~isnan(newFilter))
    timevec = get(handles.axes(1), 'XLim');
    ticks = timevec(1):(timevec(2)-timevec(1))/7:timevec(2);
    handles.roundNearest = newFilter;
    set(handles.axes(:), 'XTickLabel', timeround(datestr(ticks, 'HH:MM:SS'), handles.roundNearest));
    guidata(hObject, handles);
end


% --- Executes on button press in HeightPlotButton.
function HeightPlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to HeightPlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.n = 1;
handles.button = 0;
handles.x = [0 0];
handles.y = [0 0];
handles.EventClicked = 4;
set(gcf, 'Pointer', 'fullcross');
guidata(hObject, handles);
set(gca, 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if(strcmp(eventdata.Key,'escape'))
    handles.EventClicked = 0;
    set(gcf, 'Pointer', 'Arrow');
    if(handles.n == 2)
        delete(handles.Line(:));
        delete(handles.Line2(:));
    end
    guidata(hObject, handles);
end

if(strcmp(eventdata.Key, 'shift'))
    set(handles.CursorText, 'Visible', 'on');
    point = get(gca, 'CurrentPoint');
    point_figure = get(gcf, 'CurrentPoint');
    set(handles.CursorText, 'Position', [point_figure(1,1)+.1 point_figure(1,2)+.1 30.2 1.538], 'Units', 'Characters');
    set(handles.CursorText, 'String', ['X: ' datestr(point(1,1), 'HH:MM:SS') ' Y: ' num2str(point(1,2), 5)]);
end

% --- Executes on key release with focus on figure1 or any of its controls.
function figure1_WindowKeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)

if(strcmp(eventdata.Key, 'shift'))
    set(handles.CursorText, 'Visible', 'off')
end


% --- Executes on button press in LegendOn.
function LegendOn_Callback(hObject, eventdata, handles)
% hObject    handle to LegendOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LegendOn
if(get(hObject, 'Value') == 0.0)
    for(i=1:handles.numPlots)
        legend(handles.axes(i), 'toggle');
        AxesPos = get(handles.axes(i), 'Position');
        AxesPos(3) = AxesPos(3) + .25;
        set(handles.axes(i), 'Position', AxesPos);
    end
else
    for(i=1:handles.numPlots)
        legend(handles.axes(i), 'toggle');
        AxesPos = get(handles.axes(i), 'Position');
        AxesPos(3) = AxesPos(3) - .25;
        set(handles.axes(i), 'Position', AxesPos);
    end    
end


% --- Executes on button press in AutoscaleYButton.
function AutoscaleYButton_Callback(hObject, eventdata, handles)
% hObject    handle to AutoscaleYButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


index = find(handles.axes == gca);
times = handles.cdfhandle{'time'};
curMax = -inf;
curMin = inf;

StartTime = str2double(get(handles.StartTime, 'String'))
StartIndex = find(times == StartTime)
EndTime = str2double(get(handles.EndTime, 'String'))
EndIndex = find(times == EndTime)

for i=1:handles.numVars(index)
    curVar = handles.cdfhandle{handles.var_name{index}{i}}(:);
    curMax = max([curMax max(curVar(StartIndex:EndIndex))]);
    curMin = min([curMin min(curVar(StartIndex:EndIndex))]);
end
set(gca, 'YLim', [curMin curMax]);
set(handles.YMin, 'String', num2str(curMin));
set(handles.YMax, 'String', num2str(curMax));


% --- Executes on button press in CIPImgButton.
function CIPImgButton_Callback(hObject, eventdata, handles)
% hObject    handle to CIPImgButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.n = 1;
handles.button = 0;
handles.x = [0 0];
handles.y = [0 0];
handles.EventClicked = 7;
set(gcf, 'Pointer', 'fullcross');
guidata(hObject, handles);
set(gca, 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});



% --------------------------------------------------------------------
function CIPMenu_Callback(hObject, eventdata, handles)
% hObject    handle to CIPMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.n = 1;
handles.button = 0;
handles.x = [0 0];
handles.y = [0 0];
handles.EventClicked = 7;
set(gcf, 'Pointer', 'fullcross');
guidata(hObject, handles);
set(gca, 'ButtonDownFcn', {@axes1_ButtonDownFcn, handles});


