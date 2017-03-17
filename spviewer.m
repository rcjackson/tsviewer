function varargout = spviewer(varargin)
% SPVIEWER M-file for spviewer.fig
%      SPVIEWER, by itself, creates a new SPVIEWER or raises the existing
%      singleton*.
%
%      H = SPVIEWER returns the handle to a new SPVIEWER or the handle to
%      the existing singleton*.
%
%      SPVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPVIEWER.M with the given input arguments.
%
%      SPVIEWER('Property','Value',...) creates a new SPVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spviewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spviewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spviewer

% Last Modified by GUIDE v2.5 12-Jan-2009 14:13:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spviewer_OpeningFcn, ...
                   'gui_OutputFcn',  @spviewer_OutputFcn, ...
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


% --- Executes just before spviewer is made visible.
function spviewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spviewer (see VARARGIN)

% Choose default command line output for spviewer
handles.output = hObject;

MainGUIInput = find(strcmp(varargin,'TSViewer'));
if(isempty(MainGUIInput) || (length(varargin) <= MainGUIInput) || ~ishandle(varargin{MainGUIInput+1}))
    disp('Improper command line entry.');
    disp('----------------------------');
    disp('Usage:');
    disp('    spviewer TSViewer [handle]');
    delete(handles.spviewer);
    handles.output = 0;
else
    handles.MainFigure = varargin{MainGUIInput+1};
    MainHandles = guidata(handles.MainFigure);
    handles.cdfhandle = MainHandles.cdfhandle;
    handles.timevec = handles.cdfhandle{'timevec'}(:);
    handles.time = handles.cdfhandle{'time'}(:);
    handles.ProbeShortNames = MainHandles.ProbeShortNames;
    if(MainHandles.SPLoad == 0)
        handles.y_var_names = MainHandles.var_name{MainHandles.SPIndex};
        handles.y_long_names = MainHandles.long_names{MainHandles.SPIndex};
        handles.y_short_names = MainHandles.short_names{MainHandles.SPIndex};
        handles.y_numVars = MainHandles.numVars(MainHandles.SPIndex);
        handles.ProbeLongNames = MainHandles.ProbeLongNames;
        
        handles.ProbeNames = MainHandles.Probes;
        handles.x_var_name = 'Alt';
        handles.x_var_long_name = 'Altitude';
        set(handles.StartTime, 'String', datestr(MainHandles.Times(1), 'HHMMSS'));
        set(handles.EndTime, 'String', datestr(MainHandles.Times(2), 'HHMMSS'));
        t0 = str2num(get(handles.StartTime, 'String'));
        t1 = str2num(get(handles.EndTime, 'String'));
        StartIndex = find(handles.time == t0);
        EndIndex = find(handles.time == t1);
        X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
    
        hold on;
        for i=1:handles.y_numVars
            Y = handles.cdfhandle{handles.y_var_names{i}}(StartIndex:EndIndex);
            scatter(X, Y, 25, 'filled');
        end
        hold off;
        xlabel('Pressure Altitude (kft)');
        ylabel(handles.cdfhandle{handles.y_var_names{i}}.units(:));
        title('Scatter Plot');
        legend(handles.y_short_names); % 'Location', 'NorthEastOutside');
        Xbound = get(gca, 'XLim');
        Ybound = get(gca, 'YLim');
        set(handles.XMin, 'String', num2str(Xbound(1)));
        set(handles.XMax, 'String', num2str(Xbound(2)));
        set(handles.YMin, 'String', num2str(Ybound(1)));
        set(handles.YMax, 'String', num2str(Ybound(2)));
        hold all;
        handles.OneToOneLine = plot(linspace(1e-5, 1e30, 500), linspace(1e-5, 1e30, 500));
        hold off;
        set(handles.OneToOneLine(:), 'Visible', 'off');
        handles.t0 = handles.time(StartIndex);
        handles.t1 = handles.time(EndIndex);
        set(gca, 'XScale', 'log', 'YScale', 'log');
    else
        handles.y_var_names = MainHandles.SP_y_var_names;
        handles.y_long_names = MainHandles.SP_y_long_names;
        handles.y_short_names = MainHandles.SP_y_short_names;
        handles.y_numVars = MainHandles.SP_y_numVars;
        handles.x_var_name = MainHandles.SP_x_var_name;
        handles.x_var_long_name = MainHandles.SP_x_var_long_name;
        set(handles.StartTime, 'String', MainHandles.SP_StartTime);
        set(handles.EndTime, 'String', MainHandles.SP_EndTime);
        set(handles.XMin, 'String', num2str(MainHandles.SPXLim(1)));
        set(handles.XMax, 'String', num2str(MainHandles.SPXLim(2)));
        set(handles.YMin, 'String', num2str(MainHandles.SPYLim(1)));
        set(handles.YMax, 'String', num2str(MainHandles.SPYLim(2)));
        set(handles.LinearX, 'Value', MainHandles.SPLinearX);
        set(handles.LinearY, 'Value', MainHandles.SPLinearY);
        set(handles.OneToOne, 'Value', MainHandles.SPOneToOne);
        t0 = str2num(get(handles.StartTime, 'String'));
        t1 = str2num(get(handles.EndTime, 'String'));
        StartIndex = find(handles.time == t0);
        EndIndex = find(handles.time == t1);
        X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
    
        hold on;
        for i=1:handles.y_numVars
            Y = handles.cdfhandle{handles.y_var_names{i}}(StartIndex:EndIndex);
            scatter(X, Y, 25, 'filled');
        end
        hold off;
        if(MainHandles.SPLinearX == 0)
            set(gca, 'XScale', 'log');
        end
        if(MainHandles.SPLinearY == 0)
            set(gca, 'YScale', 'log')
        end
        
        set(gca, 'XLim', MainHandles.SPXLim, 'YLim', MainHandles.SPYLim);
        xlabel(MainHandles.SP_XLabel);
        ylabel(MainHandles.SP_YLabel);
        title(MainHandles.SP_Title);
        XLim = MainHandles.SPXLim;
        handles.OneToOneLine = line(OOLims, OOLims);
        if(MainHandles.SPOneToOne == 1)
            set(handles.OneToOneLine, 'Visible', 'on', 'XData', XLim, 'YData', XLim);
            legend([handles.y_short_names '1:1']); % 'Location', 'NorthEastOutside'); 
        else
            set(handles.OneToOneLine, 'Visible', 'off', 'XData', XLim, 'YData', XLim);
            legend(handles.y_short_names); % 'Location', 'NorthEastOutside');
        end
    end
    zoom reset;
    handles.polycoeffs = [];
    handles.PowerFitVars = [];
    handles.FourierVars = {};
    handles.FourierDegrees = [];
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
end


% UIWAIT makes spviewer wait for user response (see UIRESUME)
% uiwait(handles.spviewer);


% --- Outputs from this function are returned to the command line.
function varargout = spviewer_OutputFcn(hObject, eventdata, handles) 
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



% --- Executes on button press in OneToOne.
function OneToOne_Callback(hObject, eventdata, handles)
% hObject    handle to OneToOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OneToOne

legend off;

XLim = get(gca, 'XLim');
 hold all;
if(get(hObject, 'Value') == 0.0)
    set(handles.OneToOneLine(:), 'Visible', 'off');
    legend(handles.y_short_names); % 'Location', 'NorthEastOutside'); 
else
    set(handles.OneToOneLine(:), 'Visible', 'on');
    legend([handles.y_short_names '1:1']); % 'Location', 'NorthEastOutside'); 
end
hold off;
set(gca, 'XLim', [str2double(get(handles.XMin, 'String')) str2double(get(handles.XMax, 'String'))]);
set(gca, 'YLim', [str2double(get(handles.YMin, 'String')) str2double(get(handles.YMax, 'String'))]);
% --- Executes on button press in LinearX.
function LinearX_Callback(hObject, eventdata, handles)
% hObject    handle to LinearX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LinearX
if(get(hObject, 'Value') == 0.0)
    set(gca, 'XScale', 'log');  
else
    set(gca, 'XScale', 'linear');
end
XLims = get(gca, 'XLim');
YLims = get(gca, 'YLim');
set(handles.XMin, 'String', num2str(XLims(1)));
set(handles.XMax, 'String', num2str(XLims(2)));
set(handles.YMin, 'String', num2str(YLims(1)));
set(handles.YMax, 'String', num2str(YLims(2)));

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
XLims = get(gca, 'XLim');
YLims = get(gca, 'YLim');
set(handles.XMin, 'String', num2str(XLims(1)));
set(handles.XMax, 'String', num2str(XLims(2)));
set(handles.YMin, 'String', num2str(YLims(1)));
set(handles.YMax, 'String', num2str(YLims(2)));

% --- Executes on button press in ChangeXVar.
function ChangeXVar_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeXVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Selection, ok] = listdlg('ListString', handles.ProbeShortNames, 'Name', 'Select a Probe', ... 
                          'SelectionMode', 'single', ...
                          'PromptString', 'List of Variables:');   
if(ok == 1)
           cla(gca);
           legend off;
           handles.x_var_name = handles.ProbeNames{Selection};
           handles.x_var_long_name = handles.ProbeLongNames{Selection};
           StartTime = str2double(get(handles.StartTime, 'String'));
           EndTime = str2double(get(handles.EndTime, 'String'));
           StartIndex = find(handles.time == StartTime);
           EndIndex = find(handles.time == EndTime);
           X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
    
           hold all;
           for i=1:handles.y_numVars
              Y = handles.cdfhandle{handles.y_var_names{i}}(StartIndex:EndIndex);
              scatter(X, Y, 25, 'filled');
           end
           hold off;
           xlabel([handles.x_var_long_name ' (' handles.cdfhandle{handles.x_var_name}.units(:) ')']);
           if(min(X)~=max(X))
               set(gca, 'XLim', [min(X) max(X)]);
           else
               set(gca, 'XLim', [min(X) min(X)+1]);
           end
           set(handles.XMin, 'String', num2str(min(X)));
           set(handles.XMax, 'String', num2str(max(X)));
           Y = [str2double(get(handles.YMin, 'String')) str2double(get(handles.YMax, 'String'))]';
           XLim = get(gca, 'XLim'); 
           hold all;
           handles.OneToOneLine = plot(linspace(1e-5, 1e30, 500), linspace(1e-5, 1e30, 500));
           hold off;
           if(get(handles.OneToOne, 'Value') == 1.0)
                set(handles.OneToOneLine(:), 'Visible', 'on');
                legend([handles.y_short_names '1:1']); % 'Location', 'NorthEastOutside');
           else
                set(handles.OneToOneLine(:), 'Visible', 'off');
                legend(handles.y_short_names); % 'Location',  'NorthEastOutside');
           end
           set(gca, 'YLim', Y);
           set(handles.FitsText, 'String', '');
           handles.polycoeffs = [];
           handles.PowerFitVars = [];
           if(get(handles.LinearY, 'Value') == 0.0)
                set(gca, 'YScale', 'log');
           else
                set(gca, 'YScale', 'linear');
           end
           if(get(handles.LinearX, 'Value') == 0.0)
             set(gca, 'XScale', 'log');
           else
             set(gca, 'XScale', 'linear');
           end 
           zoom reset;
           handles.polycoeffs = [];
           handles.PowerFitVars = [];
           handles.FourierVars = [];
           handles.FourierDegrees = [];
          guidata(hObject, handles);
end           

% --- Executes on button press in AddYVariable.
function AddYVariable_Callback(hObject, eventdata, handles)
% hObject    handle to AddYVariable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Selection, ok] = listdlg('ListString', handles.ProbeShortNames, 'Name', 'Select a Probe', ... 
                          'SelectionMode', 'single', ...
                          'PromptString', 'List of Variables:');  
if(ok == 1)
           cla(gca);
           legend off;
           handles.y_var_names = [handles.y_var_names handles.ProbeNames{Selection}];
           handles.y_long_names = [handles.y_long_names handles.ProbeLongNames{Selection}];
           handles.y_short_names = [handles.y_short_names handles.ProbeShortNames{Selection}];
           handles.y_numVars = handles.y_numVars + 1;
           StartTime = str2double(get(handles.StartTime, 'String'));
           EndTime = str2double(get(handles.EndTime, 'String'));
           StartIndex = find(handles.time == StartTime);
           EndIndex = find(handles.time == EndTime);
           X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
    
           hold all;
           for i=1:handles.y_numVars
              Y = handles.cdfhandle{handles.y_var_names{i}}(StartIndex:EndIndex);
              scatter(X, Y, 25, 'filled');
           end
           hold off;
           xlabel([handles.x_var_long_name ' (' handles.cdfhandle{handles.x_var_name}.units(:) ')']);
           
           
           set(gca, 'XLim', [str2double(get(handles.XMin, 'String')) str2double(get(handles.XMax, 'String'))]);
           
          %set(handles.XMin, 'String', num2str(min(X)));
          %set(handles.XMax, 'String', num2str(max(X)));
           XLim = [min(X) max(X)];
           hold all;
           handles.OneToOneLine = plot(linspace(1e-5, 1e30, 500), linspace(1e-5, 1e30, 500));
           hold off;
           if(get(handles.OneToOne, 'Value') == 1.0)
                set(handles.OneToOneLine(:), 'Visible', 'on');
                legend([handles.y_short_names '1:1']); % 'Location', 'NorthEastOutside');
           else
                set(handles.OneToOneLine(:), 'Visible', 'off');
                legend(handles.y_short_names); %'Location' % 'NorthEastOutside');
           end
           
           Y = [str2double(get(handles.YMin, 'String')) str2double(get(handles.YMax, 'String'))];
           set(gca, 'YLim', Y);
           if(get(handles.LinearY, 'Value') == 0.0)
                set(gca, 'YScale', 'log');
           else
                set(gca, 'YScale', 'linear');
           end
           if(get(handles.LinearX, 'Value') == 0.0)
             set(gca, 'XScale', 'log');
           else
             set(gca, 'XScale', 'linear');
           end 
           set(handles.FitsText, 'String', '');
           zoom reset;
           handles.polycoeffs = [];
           handles.PowerFitVars = [];
           handles.FourierVars = [];
           handles.FourierDegrees = [];
           guidata(hObject, handles);
end           

% --- Executes on button press in ClearSet.
function ClearSet_Callback(hObject, eventdata, handles)
% hObject    handle to ClearSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Selection, ok] = listdlg('ListString', handles.ProbeShortNames, 'Name', 'Select a Probe', ... 
                          'SelectionMode', 'single', ...
                          'PromptString', 'List of Variables:');  
if(ok == 1)
           cla(gca);
           legend off;
           handles.y_var_names = {};
           handles.y_long_names = {};
           handles.y_short_names = {};
           handles.y_var_names = {handles.ProbeNames{Selection}};
           handles.y_long_names = {handles.ProbeLongNames{Selection}};
           handles.y_short_names = {handles.ProbeShortNames{Selection}};
           handles.y_numVars = 1;
           StartTime = str2double(get(handles.StartTime, 'String'));
           EndTime = str2double(get(handles.EndTime, 'String'));
           StartIndex = find(handles.time == StartTime);
           EndIndex = find(handles.time == EndTime);
           X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
    
          
           Y = handles.cdfhandle{handles.y_var_names{1}}(StartIndex:EndIndex);
           scatter(X, Y, 25, 'filled');
           
           
           xlabel([handles.x_var_long_name ' (' handles.cdfhandle{handles.x_var_name}.units(:) ')']);
           ylabel(handles.cdfhandle{handles.y_var_names{1}}.units(:));
           title('Scatter Plot');
           set(gca, 'XLim', [min(X) max(X)]);
           set(handles.XMin, 'String', num2str(min(X)));
           set(handles.XMax, 'String', num2str(max(X)));
           XLim = [min(X) max(X)];
           hold all;
           handles.OneToOneLine = plot(linspace(1e-5, 1e30, 500), linspace(1e-5, 1e30, 500));
           hold off;
           if(get(handles.OneToOne, 'Value') == 1.0)
                set(handles.OneToOneLine(:), 'Visible', 'on');
                legend([handles.y_short_names '1:1']); % 'Location', 'NorthEastOutside');
           else
                set(handles.OneToOneLine(:), 'Visible', 'off');
                legend(handles.y_short_names); % 'Location', 'NorthEastOutside');
           end
           Y = get(gca, 'YLim');
           set(handles.YMin, 'String', num2str(Y(1)));
           set(handles.YMax, 'String', num2str(Y(2)));
           set(handles.FitsText, 'String', '');
           if(get(handles.LinearY, 'Value') == 0.0)
                set(gca, 'YScale', 'log');
           else
                set(gca, 'YScale', 'linear');
           end
           if(get(handles.LinearX, 'Value') == 0.0)
             set(gca, 'XScale', 'log');
           else
             set(gca, 'XScale', 'linear');
           end 
           zoom reset;
           handles.polycoeffs = [];
           handles.PowerFitVars = [];
           handles.FourierVars = [];
           handles.FourierDegrees = [];
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
           figure;            
           StartTime = str2double(get(handles.StartTime, 'String'));
           EndTime = str2double(get(handles.EndTime, 'String'));
           StartIndex = find(handles.time == StartTime);
           EndIndex = find(handles.time == EndTime);
           X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
    
           hold all;
           for i=1:handles.y_numVars
              Y = handles.cdfhandle{handles.y_var_names{i}}(StartIndex:EndIndex);
              scatter(X, Y, 25, 'filled');
           end
           d = size(handles.polycoeffs);
           polystrings = {};
           if(d(1) > 0)
               Xlim = get(handles.SPAxes, 'XLim')
               X = linspace(Xlim(1), Xlim(2), 700)
               polystring = 'y = '
               for i = 1:d(1)
                   plot(X, polyval(handles.polycoeffs(i, :), X));
                   for j = 6:-1:1
                        if(j ~= 1)
                          if(handles.polycoeffs(i,6-j+1) ~= 0)
                             polystring = [polystring num2str(handles.polycoeffs(i,6-j+1)) 'x^' num2str(j-1) ' + '];
                          end   
                        else
                          if(handles.polycoeffs(i,6) ~= 0)
                             polystring = [polystring num2str(handles.polycoeffs(i, 6))];
                          end
                        end
                   end
                   text(X(1), polyval(handles.polycoeffs(i, :), X(1)), polystring);
                   polystring = 'y = ';
               end    
           end
           
           if(length(handles.PowerFitVars) > 0)
               X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
               for i = 1:length(handles.PowerFitVars)
                   fitlaw = fittype('a*x^b');
                   Y = handles.cdfhandle{handles.y_var_names{handles.PowerFitVars(i)}}(StartIndex:EndIndex);
                   fitoption = fitoptions('a*x^b');
                   fitoption.Lower = [-1e-10 -1e-10]
                   fitoption.Upper = [1e10 1e10];
                   % Exclude invalid data
                   InfsX = find(X == inf);
                   NansX = find(isnan(X));
                   InfsY = find(X == inf);
                   NansY = find(isnan(Y));
                   ExcludedData = union(union(union(InfsX,InfsY),NansX),NansY);
                   fitoption.Exclude = excludedata(X, Y, 'indices', ExcludedData);
    
                   fitfun = fit(X, Y, fitlaw, fitoption)
                   
                   Xlim = get(gca, 'XLim');
                   X1 = linspace(Xlim(1), Xlim(2), 700);
                   plot(X1, feval(fitfun, X1));
                   
                   c = coeffvalues(fitfun);
                   text(X1(1), feval(fitfun, X(1)), ['y = ' num2str(c(1)) 'x^{' num2str(c(2)) '}']);
               end
           end
           if(length(handles.FourierVars) > 0)
              X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
              for i = 1:length(handles.FourierVars)
                  Y = handles.cdfhandle{handles.y_var_names{handles.FourierVars(i)}}(StartIndex:EndIndex);
                  fitlaw = fittype(['fourier' num2str(handles.FourierDegrees(i))]);
                  fitoption = fitoptions(['fourier' num2str(handles.FourierDegrees(i))]);
                  fitfun = fit(X, Y, fitlaw, fitoption)
                  hold all;
                  Xlim = get(gca, 'XLim');
                  X1 = linspace(Xlim(1), Xlim(2), 700);
                  plot(X1, feval(fitfun, X1));
                  hold off;
                  c = coeffvalues(fitfun);
                  Fits = get(handles.FitsText, 'String');
                  polystring = ['y = ' num2str(c(1)) ' + '];
                  p = 2*pi/(Xlim(2) - Xlim(1));
                  for(i=1:handles.FourierDegrees(i))
                      polystring = [polystring num2str(c(2*i)) '+ cos(' num2str(i*p) '*x) + ' num2str(c(2*i+1)) 'sin(' num2str(i*p) '*x) '];
                  end
                  text(X1(1), feval(fitfun, X(1)), polystring);
              end
           end
           hold off;
           xlabel(get(get(handles.SPAxes, 'XLabel'), 'String'));
           ylabel(get(get(handles.SPAxes, 'YLabel'), 'String'));
           title(get(get(handles.SPAxes, 'Title'), 'String'));
           X = get(handles.SPAxes, 'XLim');
           Y = get(handles.SPAxes, 'YLim');
           set(gca, 'XLim', X, 'YLim', Y);
           
           if(get(handles.OneToOne, 'Value') == 1.0)
                hold on;
                Xrange = get(gca, 'XLim');
                X = linspace(Xrange(1), Xrange(2), 300);
                plot(X, X);
                hold off;
                legend([handles.y_short_names '1:1']);
           else
                legend([handles.y_short_names]);
           end
           if(get(handles.LinearY, 'Value') == 0.0)
               set(gca, 'YScale', 'log');
           end
           if(get(handles.LinearX, 'Value') == 0.0)
               set(gca, 'XScale', 'log');
           end
            cd(path);
           print(gcf, '-djpeg', file);
           cd(oldpath);
end     
          

% --- Executes on button press in Print.
function Print_Callback(hObject, eventdata, handles)
% hObject    handle to Print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure;            
StartTime = str2double(get(handles.StartTime, 'String'));
EndTime = str2double(get(handles.EndTime, 'String'));
StartIndex = find(handles.time == StartTime);
EndIndex = find(handles.time == EndTime);
X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
   
hold all;
for i=1:handles.y_numVars
              Y = handles.cdfhandle{handles.y_var_names{i}}(StartIndex:EndIndex);
              scatter(X, Y, 25, 'filled');
end
hold off;
polystrings = {};
if(d(1) > 0)
               Xlim = get(handles.SPAxes, 'XLim')
               X = linspace(Xlim(1), Xlim(2), 700)
               polystring = 'y = '
               for i = 1:d(1)
                   plot(X, polyval(handles.polycoeffs(i, :), X));
                   for j = 6:-1:1
                        if(j ~= 1)
                          if(handles.polycoeffs(i,6-j+1) ~= 0)
                             polystring = [polystring num2str(handles.polycoeffs(i,6-j+1)) 'x^' num2str(j-1) ' + '];
                          end   
                        else
                          if(handles.polycoeffs(i,6) ~= 0)
                             polystring = [polystring num2str(handles.polycoeffs(i, 6))];
                          end
                        end
                   end
                   text(X(1), polyval(handles.polycoeffs(i, :), X(1)), polystring);
                   polystring = 'y = ';
               end    
end
           
if(length(handles.PowerFitVars) > 0)
               X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
               for i = 1:length(handles.PowerFitVars)
                   fitlaw = fittype('a*x^b');
                   Y = handles.cdfhandle{handles.y_var_names{handles.PowerFitVars(i)}}(StartIndex:EndIndex);
                   fitoption = fitoptions('a*x^b');
                   % Exclude invalid data
                   InfsX = find(X == inf);
                   NansX = find(isnan(X));
                   InfsY = find(X == inf);
                   NansY = find(isnan(Y));
                   ExcludedData = union(union(union(InfsX,InfsY),NansX),NansY);
                   fitoption.Exclude = excludedata(X, Y, 'indices', ExcludedData);
    
                   fitfun = fit(X, Y, fitlaw, fitoption)
                   
                   Xlim = get(gca, 'XLim');
                   X1 = linspace(Xlim(1), Xlim(2), 700);
                   plot(X1, feval(fitfun, X1));
                   
                   c = coeffvalues(fitfun);
                   text(X1(1), feval(fitfun, X1(1)), ['y = ' num2str(c(1)) 'x^{' num2str(c(2)) '}']);
               end
end
if(length(handles.FourierVars) > 0)
              X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
              for i = 1:length(handles.FourierVars)
                  Y = handles.cdfhandle{handles.y_var_names{handles.FourierVars(i)}}(StartIndex:EndIndex);
                  fitlaw = fittype(['fourier' num2str(handles.FourierDegrees(i))]);
                  fitoption = fitoptions(['fourier' num2str(handles.FourierDegrees(i))]);
                  fitfun = fit(X, Y, fitlaw, fitoption)
                  hold all;
                  Xlim = get(gca, 'XLim');
                  X1 = linspace(Xlim(1), Xlim(2), 700);
                  plot(X1, feval(fitfun, X1));
                  hold off;
                  c = coeffvalues(fitfun);
                  Fits = get(handles.FitsText, 'String');
                  polystring = ['y = ' num2str(c(1)) ' + '];
                  p = 2*pi/(Xlim(2) - Xlim(1));
                  for(i=1:handles.FourierDegrees(i))
                      polystring = [polystring num2str(c(2*i)) '+ cos(' num2str(i*p) '*x) + ' num2str(c(2*i+1)) 'sin(' num2str(i*p) '*x) '];
                  end
                  text(X(1), feval(fitfun, X(1)), polystring);
              end
end
hold off;
xlabel(get(get(handles.SPAxes, 'XLabel'), 'String'));
ylabel(get(get(handles.SPAxes, 'YLabel'), 'String'));
title(get(get(handles.SPAxes, 'Title'), 'String'));
set(gca, 'XLim', [min(X) max(X)]);
           
if(get(handles.OneToOne, 'Value') == 1.0)
                hold on;
                Xrange = get(gca, 'XLim');
                X = linspace(Xrange(1), Xrange(2), 300);
                plot(X, X);
                hold off;
                legend([handles.y_short_names '1:1']);
else
                legend(handles.y_short_names);
end
if(get(handles.LinearY, 'Value') == 0.0)
               set(gca, 'YScale', 'log');
end
if(get(handles.LinearX, 'Value') == 0.0)
               set(gca, 'XScale', 'log');
end
print(gcf);

% --- Executes on button press in XLabelChg.
function XLabelChg_Callback(hObject, eventdata, handles)
% hObject    handle to XLabelChg (see GCBO)
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

% --- Executes on button press in YLabelChg.
function YLabelChg_Callback(hObject, eventdata, handles)
% hObject    handle to YLabelChg (see GCBO)
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

% --- Executes on button press in TitleSet.
function TitleSet_Callback(hObject, eventdata, handles)
% hObject    handle to TitleSet (see GCBO)
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


function XMax_Callback(hObject, eventdata, handles)
% hObject    handle to XMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XMax as text
%        str2double(get(hObject,'String')) returns contents of XMax as a double
xrange = [str2double(get(handles.XMin, 'String')) str2double(get(hObject, 'String'))];
if(xrange(1)>xrange(2))
    errordlg('Maximum X value must be greater than Minimum X value!', 'Error')
    x = get(gca, 'XLim');
    set(hObject, 'String', num2str(x(2)));
else
    set(gca, 'XLim', xrange);
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



function YMax_Callback(hObject, eventdata, handles)
% hObject    handle to YMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YMax as text
%        str2double(get(hObject,'String')) returns contents of YMax as a double
yrange = [str2double(get(handles.YMin, 'String')) str2double(get(hObject, 'String'))];
if(yrange(1)>yrange(2))
    errordlg('Maximum Y value must be greater than Minimum Y value!', 'Error')
    y = get(gca, 'YLim');
    set(hObject, 'String', num2str(y(2)));
else
    set(gca, 'YLim', yrange);
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



function XMin_Callback(hObject, eventdata, handles)
% hObject    handle to XMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XMin as text
%        str2double(get(hObject,'String')) returns contents of XMin as a double
xrange = [str2double(get(hObject, 'String')) str2double(get(handles.XMax, 'String'))];
if(xrange(1)>xrange(2))
    errordlg('Maximum X values must be greater than Minimum X value!', 'Error')
    x = get(gca, 'XLim');
    set(hObject, 'String', num2str(x(1)));
else
    set(gca, 'XLim', xrange);
    
    
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



function YMin_Callback(hObject, eventdata, handles)
% hObject    handle to YMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YMin as text
%        str2double(get(hObject,'String')) returns contents of YMin as a double
yrange = [str2double(get(hObject, 'String')) str2double(get(handles.YMax, 'String'))];
if(yrange(1)>yrange(2))
    errordlg('Maximum Y value must be greater than Minimum Y value!', 'Error')
    y = get(gca, 'YLim');
    set(hObject, 'String', num2str(y(1)));
else
    set(gca, 'YLim', yrange);
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


% --- Executes during object creation, after setting all properties.
function spviewer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spviewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function StartTime_Callback(hObject, eventdata, handles)
% hObject    handle to StartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartTime as text
%        str2double(get(hObject,'String')) returns contents of StartTime as
%        a double
StartTime = str2double(get(hObject, 'String'));
EndTime = str2double(get(handles.EndTime, 'String'));
StartIndex = find(handles.time == StartTime);
EndIndex = find(handles.time == EndTime);
if(StartTime > EndTime)
    errordlg('Start time must be before end time!', 'Error');
    set(hObject, 'String', num2str(handles.t0));
else
    cla(gca);
    legend off;
    hold all;
    X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
    for i=1:handles.y_numVars
        Y = handles.cdfhandle{handles.y_var_names{i}}(StartIndex:EndIndex);
        scatter(X, Y, 25, 'filled');
    end
    hold off;
    hold all;
    handles.OneToOneLine = plot(linspace(1e-5, 1e30, 500), linspace(1e-5, 1e30, 500));
    hold off;
    if(get(handles.OneToOne, 'Value') == 1.0)
                set(handles.OneToOneLine(:), 'Visible', 'on');
                legend([handles.y_short_names '1:1']); % 'Location', 'NorthEastOutside');
    else
               set(handles.OneToOneLine(:), 'Visible', 'off');
                legend(handles.y_short_names, 'Location'); % 'NorthEastOutside');
    end
    hold off;
    zoom reset;
    handles.t0 = StartTime;
    
    set(handles.FitsText, 'String', '');
    handles.polycoeffs = [];
    handles.PowerFitVars = [];
    handles.FourierVars = {};
    handles.FourierDegrees = [];
     guidata(hObject, handles);
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
StartTime = str2double(get(handles.StartTime, 'String'));
EndTime = str2double(get(hObject, 'String'));
StartIndex = find(handles.time == StartTime);
EndIndex = find(handles.time == EndTime);
if(StartTime > EndTime)
    errordlg('Start time must be before end time!', 'Error');
    set(hObject, 'String', num2str(handles.t1));
else
    cla(gca);
    legend off;
    hold all;
    X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
    for i=1:handles.y_numVars
        Y = handles.cdfhandle{handles.y_var_names{i}}(StartIndex:EndIndex);
        scatter(X, Y, 25, 'filled');
    end
    hold off;
    hold all;
           handles.OneToOneLine = plot(linspace(1e-5, 1e30, 500), linspace(1e-5, 1e30, 500));
           hold off;
           if(get(handles.OneToOne, 'Value') == 1.0)
                set(handles.OneToOneLine(:), 'Visible', 'on');
                legend([handles.y_short_names '1:1']); % 'Location', 'NorthEastOutside');
           else
                set(handles.OneToOneLine(:), 'Visible', 'off');
                legend(handles.y_short_names); %, 'Location', 'NorthEastOutside');
           end
    hold off;    
    zoom reset;
    handles.t1 = EndTime;
   
    set(handles.FitsText, 'String', '');
    handles.polycoeffs = [];
    handles.PowerFitVars = [];
    handles.FourierVars = {};
    handles.FourierDegrees = [];
    guidata(hObject, handles);
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


% --- Executes on button press in PolyFit.
function PolyFit_Callback(hObject, eventdata, handles)
% hObject    handle to PolyFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[Selection, ok] = listdlg('ListString', handles.y_short_names, 'Name', 'Select a Probe', ... 
                          'SelectionMode', 'single', ...
                          'PromptString', 'Select a Probe to Interpolate');  
if (ok == 1)
    prompt = 'Enter degree of polynomial (max 5):';
    title = 'Enter degree of polynomial';
    l = 1;
    Answer = {'1'};
    degree = str2double(inputdlg(prompt, title, l, Answer));
    if(~isempty(degree))
        if(degree < 6)
          time = handles.cdfhandle{'time'};
          StartIndex = find(time == str2double(get(handles.StartTime, 'String')));
          EndIndex = find(time == str2double(get(handles.EndTime, 'String')));
          X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
          Y = handles.cdfhandle{handles.y_var_names{Selection}}(StartIndex:EndIndex);
          finiteindicies = find(isfinite(Y));
          Xfin = X(finiteindicies(:));
          Yfin = Y(finiteindicies(:));
          coefficients = polyfit(Xfin, Yfin, degree);
          if(isnan(coefficients(1)))
              msgbox('No polynomial fit found!');
          else
              hold all;
              Xlim = get(gca, 'XLim');
              X1 = linspace(Xlim(1), Xlim(2), 700);
              plot(X1, polyval(coefficients, X1));
              hold off;
              polystring = 'y = ';
          
              for i = degree:-1:0
                  if(i ~= 0)
                     polystring = [polystring num2str(coefficients(degree-i+1)) 'x^' num2str(i) ' + '];
                  else
                     polystring = [polystring num2str(coefficients(degree+1))];
                  end
              end
              curvec = zeros(1, 6);
              for i=6:-1:(6-degree)
                  curvec(i) = coefficients(length(coefficients) - (6-i));
              end
         
              handles.polycoeffs = [handles.polycoeffs; curvec];
              CurPolyString = get(handles.FitsText, 'String');
              set(handles.FitsText, 'String', strvcat(CurPolyString, polystring));       
          end
        end
    end
    guidata(hObject, handles);
end
                      


% --- Executes on button press in CorrelationButton.
function CorrelationButton_Callback(hObject, eventdata, handles)
% hObject    handle to CorrelationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Selection, ok] = listdlg('ListString', handles.y_short_names, 'Name', 'Select a Probe', ... 
                          'SelectionMode', 'single', ...
                          'PromptString', 'Select a Probe to Interpolate');  
if(ok == 1)
      time = handles.cdfhandle{'time'};
      StartIndex = find(time == str2double(get(handles.StartTime, 'String')));
      EndIndex = find(time == str2double(get(handles.EndTime, 'String')));
      X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
      Y = handles.cdfhandle{handles.y_var_names{Selection}}(StartIndex:EndIndex);
      covariance = cov([X(:) Y(:)])
      corr = corrcoef([X(:) ,Y(:)])
      msgbox({['Covariance of ' handles.x_var_short_name ' vs. ' handles.y_short_names{Selection} ' = ' num2str(covariance(1,2))], ['Correlation coefficient of ' handles.x_var_short_name ' vs. ' handles.y_short_names{Selection} ' = ' num2str(corr(1,2))]}, 'Correlation data');
end


% --- Executes on button press in PowerFit.
function PowerFit_Callback(hObject, eventdata, handles)
% hObject    handle to PowerFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[Selection, ok] = listdlg('ListString', handles.y_short_names, 'Name', 'Select a Probe', ... 
                          'SelectionMode', 'single', ...
                          'PromptString', 'Select a Probe to Interpolate');  
if (ok == 1)
    time = handles.cdfhandle{'time'};
    StartIndex = find(time == str2double(get(handles.StartTime, 'String')));
    EndIndex = find(time == str2double(get(handles.EndTime, 'String')));
    X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
    Y = handles.cdfhandle{handles.y_var_names{Selection}}(StartIndex:EndIndex);
    fitlaw = fittype('a*x^b');
    fitoption = fitoptions('power1');
    % Exclude invalid data
    fitoption.Upper = [1e5 1e5 1e5];
    fitoption.Lower = [-1e5 -1e5 -1e5];

    InfsX = find(X == inf);
    NansX = find(isnan(X));
    InfsY = find(X == inf);
    NansY = find(isnan(Y));
    %NegsX = find(X < 0);
    %NegsY = find(Y < 0);
    ExcludedData = union(union(union(InfsX,InfsY),NansX),NansY);
    %ExcludedData = union(ExcludedData, NegsX);
    %ExcludedData = union(ExcludedData, NegsY);
    fitoption.Exclude = excludedata(X, Y, 'indices', ExcludedData);
    %try
        fitfun = fit(X, Y, fitlaw, fitoption)
        hold all;
        Xlim = get(gca, 'XLim');
        X1 = linspace(Xlim(1), Xlim(2), 700);
        plot(X1, feval(fitfun, X1));
        hold off;
        c = coeffvalues(fitfun);
        Fits = get(handles.FitsText, 'String');
        set(handles.FitsText, 'String', strvcat(Fits, ['y = ' num2str(c(1)) 'x^' num2str(c(2))]));
        handles.PowerFitVars = [handles.PowerFitVars Selection];
        guidata(hObject, handles);
    %catch ME
      %  msgbox('Unable to generate power law fit!');
    %end
    
end


% --- Executes on button press in ZoomOutButton.
function ZoomOutButton_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomOutButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom out;
X = get(gca, 'XLim');
Y = get(gca, 'YLim');
set(handles.XMin, 'String', num2str(X(1)));
set(handles.XMax, 'String', num2str(X(2)));
set(handles.YMin, 'String', num2str(Y(1)));
set(handles.YMax, 'String', num2str(Y(2)));


% --- Executes on button press in FourierFit.
function FourierFit_Callback(hObject, eventdata, handles)
% hObject    handle to FourierFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Selection, ok] = listdlg('ListString', handles.y_short_names, 'Name', 'Select a Probe', ... 
                          'SelectionMode', 'single', ...
                          'PromptString', 'Select a Probe to Interpolate');  
if (ok == 1)
    time = handles.cdfhandle{'time'};
    StartIndex = find(time == str2double(get(handles.StartTime, 'String')));
    EndIndex = find(time == str2double(get(handles.EndTime, 'String')));
    prompt = 'Enter number of sine-cosine pairs (max 8):';
    title = 'Enter degree of series';
    l = 1;
    Degree = {'1'};
    Answer = str2double(inputdlg(prompt, title, l, Degree));
    fitlaw = fittype(['fourier' num2str(Answer)]);
    fitoption = fitoptions(['fourier' num2str(Answer)]);
    if(Answer < 8)
        X = handles.cdfhandle{handles.x_var_name}(StartIndex:EndIndex);
        Y = handles.cdfhandle{handles.y_var_names{Selection}}(StartIndex:EndIndex);
        InfsX = find(X == inf);
        NansX = find(isnan(X));
        InfsY = find(X == inf);
        NansY = find(isnan(Y));
        %NegsX = find(X < 0);
        %NegsY = find(Y < 0);
        ExcludedData = union(union(union(InfsX,InfsY),NansX),NansY);
        %ExcludedData = union(ExcludedData, NegsX);
        %ExcludedData = union(ExcludedData, NegsY);
        fitoption.Exclude = excludedata(X, Y, 'indices', ExcludedData);
        fitfun = fit(X, Y, fitlaw, fitoption);
        hold all;
        Xlim = get(gca, 'XLim');
        X1 = linspace(Xlim(1), Xlim(2), 700);
        plot(X1, feval(fitfun, X1));
        hold off;
        c = coeffvalues(fitfun);
        Fits = get(handles.FitsText, 'String');
        polystring = ['y = ' num2str(c(1)) ' + '];
        p = 2*pi/(Xlim(2) - Xlim(1));
        for(i=1:Answer)
                polystring = [polystring num2str(c(2*i)) 'cos(' num2str(i*p) '*x) + ' num2str(c(2*i+1)) 'sin(' num2str(i*p) '*x) '];
        end
        set(handles.FitsText, 'String', strvcat(Fits, polystring));;
        handles.FourierVars = [handles.FourierVars Selection];
        handles.FourierDegrees = [handles.FourierDegrees Answer];
        guidata(hObject, handles);
    end
end


% --- Executes on button press in AutofitButton.
function AutofitButton_Callback(hObject, eventdata, handles)
% hObject    handle to AutofitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

StartTime = str2double(get(handles.StartTime, 'String'));
EndTime = str2double(get(handles.EndTime, 'String'));
StartIndex = find(handles.time == StartTime);
EndIndex = find(handles.time == EndTime);

curMin = inf;
curMax = -inf;

for i=1:handles.y_numVars
    curVar = handles.cdfhandle{handles.y_var_names{i}}(:);
    curMin = min([curMin min(curVar(StartIndex:EndIndex))]);
    curMax = max([curMax max(curVar(StartIndex:EndIndex))]);
end

set(gca, 'YLim', [curMin curMax]);
set(handles.YMin, 'String', num2str(curMin));
set(handles.YMax, 'String', num2str(curMax));

