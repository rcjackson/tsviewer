
function varargout = sdviewer(varargin)
% SDVIEWER M-file for sdviewer.fig
%      SDVIEWER, by itself, creates a new SDVIEWER or raises the existing
%      singleton*.
%
%      H = SDVIEWER returns the handle to a new SDVIEWER or the handle to
%      the existing singleton*.
%
%      SDVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SDVIEWER.M with the given input arguments.
%
%      SDVIEWER('Property','Value',...) creates a new SDVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sdviewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sdviewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sdviewer

% Last Modified by GUIDE v2.5 12-Jan-2009 14:08:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sdviewer_OpeningFcn, ...
                   'gui_OutputFcn',  @sdviewer_OutputFcn, ...
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


% --- Executes just before sdviewer is made visible.
function sdviewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sdviewer (see VARARGIN)

% Choose default command line output for sdviewer
handles.output = hObject;

MainGUIInput = find(strcmp(varargin,'TSViewer'));
if(isempty(MainGUIInput) || (length(varargin) <= MainGUIInput) || ~ishandle(varargin{MainGUIInput+1}))
    disp('Improper command line entry.');
    disp('----------------------------');
    disp('Usage:');
    disp('    sdviewer TSViewer [handle]');
    delete(handles.sdviewer);
    handles.output = 0;
else
    handles.MainFigure = varargin{MainGUIInput+1};
    MainHandles = guidata(handles.MainFigure);
    handles.cdfhandle = MainHandles.cdfhandle;
    time = MainHandles.cdfhandle{'time'}(:);
    if(MainHandles.SDLoad == 0)
        t = MainHandles.Times;
        set(handles.StartTime, 'String', datestr(t(1), 'HHMMSS'));
        set(handles.EndTime, 'String', datestr(t(2), 'HHMMSS'));
        
        % Load all of the concentration variable names
        j = 0;
        handles.ConcVariables = {};
        handles.ConcBinSizeNames = {};
        handles.ConcBinLocNames = {};
        handles.ConcBinLongNames = {};
        handles.ConcBinShortNames = {};
        Variables = var(MainHandles.cdfhandle);
        for i=1:length(Variables)
            conc_location = strfind(name(Variables{i}), 'conc');
            VarName = name(Variables{i});
            if(~isempty(conc_location))
               if(conc_location(1) == (length(VarName) - 3))        % It's a concentration variable
                  Dimensions = size(Variables{i});
                  if(Dimensions(1) == length(time))                   % Make sure that time is a dimension
                     handles.ConcVariables = [handles.ConcVariables; VarName];
                     if(~isempty(strfind(VarName, 'TwoDS')))            % Special case for 2DS
                         BinSizeName = 'TwoDS_bin_dD';
                         BinLocName = 'TwoDS_bin_mid';
                     else
                         if (isequal(VarName, 'CASPBP_conc'))          % And for CAS PBP
                            BinSizeName = 'CAS_bin_dD';
                            BinLocName = 'CAS_bin_mid';
                         else
                            BinSizeName = [strrep(VarName, 'conc', '') 'bin_dD'];
                            BinLocName = [strrep(VarName, 'conc', '') 'bin_mid'];
                         end   
                     end    
                     handles.ConcBinSizeNames = [handles.ConcBinSizeNames BinSizeName];
                     handles.ConcBinLocNames = [handles.ConcBinLocNames BinLocName];
                     LongName = handles.cdfhandle{VarName}.long_name(:);
                     ShortName = handles.cdfhandle{VarName}.short_name(:);
                     handles.ConcBinLongNames = [handles.ConcBinLongNames LongName];
                     handles.ConcBinShortNames = [handles.ConcBinShortNames ShortName];
                  end
               end  
            end
        end
        MainVariables = MainHandles.var_name{MainHandles.SDIndex};
        
        % Look for variables in the clicked window that we can make a size
        % distribution out of
        handles.CurBins = {};
        handles.curvar = {};
        handles.CurBinLocs = {};
        handles.CurLongNames = {};
        handles.CurShortNames = {};
        handles.NumVars = 0;
        for i = 1:MainHandles.numVars(MainHandles.SDIndex)
            if(~isempty(strfind(MainVariables{i}, 'TwoDC')))
                handles.curvar = [handles.curvar '2DC_conc'];
                handles.CurBins = [handles.CurBins '2DC_bin_dD'];
                handles.CurBinLocs = [handles.CurBinLocs '2DC_bin_mid'];
                handles.CurLongNames = [handles.CurLongNames '2DC concentration'];
                handles.CurShortNames = [handles.CurShortNames '2DC N(D)'];
                handles.NumVars = handles.NumVars + 1;
            end
            if(~isempty(strfind(MainVariables{i}, 'TwoDP')))
                handles.curvar = [handles.curvar '2DP_conc'];
                handles.CurBins = [handles.CurBins '2DP_bin_dD'];
                handles.CurBinLocs = [handles.CurBinLocs '2DP_bin_mid'];
                handles.CurLongNames = [handles.CurLongNames '2DP concentration'];
                handles.CurShortNames = [handles.CurShortNames '2DP N(D)'];
                handles.NumVars = handles.NumVars + 1;
            end
            if(~isempty(strfind(MainVariables{i}, 'f096')))
                handles.curvar = [handles.curvar 'FSSP096_conc'];
                handles.CurBins = [handles.CurBins 'FSSP096_bin_dD'];
                handles.CurBinLocs = [handles.CurBinLocs 'FSSP096_bin_mid'];
                handles.CurLongNames = [handles.CurLongNames 'FSSP96 concentration'];
                handles.CurShortNames = [handles.CurShortNames 'FSSP96 N(D)'];
                handles.NumVars = handles.NumVars + 1;
            end
            if(~isempty(strfind(MainVariables{i}, 'f124')))
                handles.curvar = [handles.curvar 'FSSP124_conc'];
                handles.CurBins = [handles.CurBins 'FSSP124_bin_dD'];
                handles.CurBinLocs = [handles.CurBinLocs 'FSSP124_bin_mid'];
                handles.CurLongNames = [handles.CurLongNames 'FSSP124 concentration'];
                handles.CurShortNames = [handles.CurShortNames 'FSSP124 N(D)'];
                handles.NumVars = handles.NumVars + 1;
            end
            if(~isempty(strfind(MainVariables{i}, 'FSSP300')))
                handles.curvar = [handles.curvar 'FSSP300_conc'];
                handles.CurBins = [handles.CurBins 'FSSP300_bin_dD'];
                handles.CurBinLocs = [handles.CurBinLocs 'FSSP300_bin_mid'];
                handles.CurLongNames = [handles.CurLongNames 'FSSP300 concentration'];
                handles.CurShortNames = [handles.CurShortNames 'FSSP300 N(D)'];
                handles.NumVars = handles.NumVars + 1;
            end
            if(~isempty(strfind(MainVariables{i}, 'PCASP')))
                handles.curvar = [handles.curvar 'PCASP_conc'];
                handles.CurBins = [handles.CurBins 'PCASP_bin_dD'];
                handles.CurBinLocs = [handles.CurBinLocs 'PCASP_bin_mid'];
                handles.CurLongNames = [handles.CurLongNames 'PCASP concentration'];
                handles.CurShortNames = [handles.CurShortNames 'PCASP N(D)'];
                handles.NumVars = handles.NumVars + 1;
            end
            if(~isempty(strfind(MainVariables{i}, 'CDP')))
                handles.curvar = [handles.curvar 'CDP_conc'];
                handles.CurBins = [handles.CurBins 'CDP_bin_dD'];
                handles.CurBinLocs = [handles.CurBinLocs 'CDP_bin_mid'];
                handles.CurLongNames = [handles.CurLongNames 'CDP concentration'];
                handles.CurShortNames = [handles.CurShortNames 'CDP N(D)'];
                handles.NumVars = handles.NumVars + 1;
            end
            if(~isempty(strfind(MainVariables{i}, 'CIP1')) && isempty(strfind(MainVariables{i}, 'corr')))
                handles.curvar = [handles.curvar 'CIP1_conc'];
                handles.CurBins = [handles.CurBins 'CIP1_bin_dD'];
                handles.CurBinLocs = [handles.CurBinLocs 'CIP1_bin_mid'];
                handles.CurLongNames = [handles.CurLongNames 'CIP1 concentration'];
                handles.CurShortNames = [handles.CurShortNames 'CIP1 N(D)'];
                handles.NumVars = handles.NumVars + 1;
            end
            if(~isempty(strfind(MainVariables{i}, 'CIP1corr')));
                handles.curvar = [handles.curvar 'CIP1corr_conc'];
                handles.CurBins = [handles.CurBins 'CIP1corr_bin_dD'];
                handles.CurBinLocs = [handles.CurBinLocs 'CIP1corr_bin_mid'];
                handles.CurLongNames = [handles.CurLongNames 'CIP1 corrected concentration'];
                handles.CurShortNames = [handles.CurShortNames 'CIP1corr N(D)'];    
                handles.NumVars = handles.NumVars + 1;
            end    
            if(~isempty(strfind(MainVariables{i}, 'CIP2')) && isempty(strfind(MainVariables{i}, 'corr')))
                handles.curvar = [handles.curvar 'CIP2_conc'];
                handles.CurBins = [handles.CurBins 'CIP2_bin_dD'];
                handles.CurBinLocs = [handles.CurBinLocs 'CIP2_bin_mid'];
                handles.CurLongNames = [handles.CurLongNames 'CIP2 concentration'];
                handles.CurShortNames = [handles.CurShortNames 'CIP2 N(D)'];
                handles.NumVars = handles.NumVars + 1;
            end
            if(~isempty(strfind(MainVariables{i}, 'CIP2corr')));
                handles.curvar = [handles.curvar 'CIP2corr_conc'];
                handles.CurBins = [handles.CurBins 'CIP2corr_bin_dD'];
                handles.CurBinLocs = [handles.CurBinLocs 'CIP2corr_bin_mid'];
                handles.CurLongNames = [handles.CurLongNames 'CIP2 corrected concentration'];
                handles.CurShortNames = [handles.CurShortNames 'CIP2corr N(D)'];    
                handles.NumVars = handles.NumVars + 1;
            end    
            % Since CAS is a substring of CASPBP, we need to make sure we
            % don't plot both CAS and CASPBP!
            if(isempty(strfind(MainVariables{i}, 'CASPBP')) && ~isempty(strfind(MainVariables{i}, 'CAS')))
                handles.curvar = [handles.curvar 'CAS_conc'];
                handles.CurBins = [handles.CurBins 'CAS_bin_dD'];
                handles.CurBinLocs = [handles.CurBinLocs 'CAS_bin_mid'];
                handles.CurLongNames = [handles.CurLongNames 'CAS concentration'];
                handles.CurShortNames = [handles.CurShortNames 'CAS N(D)'];
                handles.NumVars = handles.NumVars + 1;
            else
                if(~isempty(strfind(MainVariables{i}, 'CASPBP')))
                    handles.curvar = [handles.curvar 'CASPBP_conc'];
                    handles.CurBins = [handles.CurBins 'CAS_bin_dD'];
                    handles.CurBinLocs = [handles.CurBinLocs 'CAS_bin_mid'];
                    handles.CurLongNames = [handles.CurLongNames 'CAS particle by particle concentration'];
                    handles.CurShortNames = [handles.CurShortNames '2DC N(D)'];
                    handles.NumVars = handles.NumVars + 1;
                end
            end
            if(~isempty(strfind(MainVariables{i}, 'TwoDSV')))
                handles.curvar = [handles.curvar 'TwoDSV_conc'];
                handles.CurBins = [handles.CurBins 'TwoDS_bin_dD'];
                handles.CurBinLocs = [handles.CurBinLocs 'TwoDS_bin_mid'];
                handles.CurLongNames = [handles.CurLongNames '2DSV concentration'];
                handles.CurShortNames = [handles.CurShortNames '2DC N(D)'];
                handles.NumVars = handles.NumVars + 1;
            end
            if(~isempty(strfind(MainVariables{i}, 'TwoDSH')))
                handles.curvar = [handles.curvar 'TwoDSH_conc'];
                handles.CurBins = [handles.CurBins 'TwoDS_bin_dD'];
                handles.CurBinLocs = [handles.CurBinLocs 'TwoDS_bin_mid'];
                handles.CurLongNames = [handles.CurLongNames '2DSH concentration'];
                handles.CurShortNames = [handles.CurShortNames '2DC N(D)'];
                handles.NumVars = handles.NumVars + 1;
            end
        end
        t0 = str2double(get(handles.StartTime, 'String'));
        t1 = str2double(get(handles.EndTime, 'String'));
        StartIndex = find(time == t0);
        EndIndex = find(time == t1);
        if(isempty(handles.CurBins))
            conc = MainHandles.cdfhandle{'CAS_conc'}(:);
            bin_loc = MainHandles.cdfhandle{'CAS_bin_mid'}(:);
            handles.curvar = {'CAS_conc'};
            handles.CurBins = {'CAS_bin_dD'};
            handles.CurBinLocs = {'CAS_bin_mid'};
            handles.CurLongNames = {'CAS concentration'};
            handles.CurShortNames = {'CAS N(D)'};
           
            N = zeros(1, 30);
            N = mean(conc(StartIndex:EndIndex, :), 1);
            YLims = [1e-5 max(N)*10];
            if(isnan(max(N)))
                YLims = [1e-5 1];
            end
            stairs(bin_loc, N);
            handles.CurMaxX = max(bin_loc);
            CurMinX = min(bin_loc);
            legend('CAS N(D)');
            handles.NumVars = 1;
        else
            handles.CurMaxX = -inf;
            CurMaxY = -inf;
            CurMinX = inf;
            hold all;
            for i = 1:handles.NumVars
                 bin_loc = handles.cdfhandle{handles.CurBinLocs{i}}(:);
                 N = zeros(1, length(bin_loc));
                 conc = handles.cdfhandle{handles.curvar{i}}(:);
                 N(:) = mean(conc(StartIndex:EndIndex, :), 1);
                 stairs(bin_loc, N);
                 handles.CurMaxX = max([handles.CurMaxX max(bin_loc)]);
                 CurMaxY = max([CurMaxY max(N)]);
                 CurMinX = min([CurMinX min(bin_loc)]);
            end
            YLims = [1e-5 CurMaxY];
            if(isnan(CurMaxY))
                YLims = [1e-5 1];
            end
            hold off;
            legend(handles.CurShortNames);
        end
        xlabel('Diameter [\mum]');
        ylabel('N(D) {cm}^{-3}');
        title(['Moment 0 from time ' datestr(t(1), 'HH:MM:SS') ' to time ' datestr(t(2), 'HH:MM:SS') '.']);
        handles.XLbl = 'Diameter [\mum]';
        handles.YLbl = 'N(D) [{cm}^{-3}]';
        handles.Title = ['Moment 0 from time ' datestr(t(1), 'HH:MM:SS') ' to time ' datestr(t(2), 'HH:MM:SS') '.'];
        set(handles.SDAxes, 'XScale', 'log', 'YScale', 'log', 'XMinorTick', 'on', 'YLim', YLims)
        set(handles.SDAxes, 'XLim', [CurMinX handles.CurMaxX]);
        y = get(handles.SDAxes, 'YLim');
        set(handles.XMin, 'String', num2str(min(bin_loc)));
        set(handles.XMax, 'String', num2str(handles.CurMaxX));
        set(handles.YMin, 'String', num2str(y(1)));
        set(handles.YMax, 'String', num2str(y(2)));
        
        
        
        
    
        
        % Generate string array of variable names of all possible size
        % distributions
        
        
        
    else
        handles.CurBins = MainHandles.SDCurBins;
        handles.CurBinLocs = MainHandles.SDCurBinLocs;
        handles.CurLongNames = MainHandles.SDCurLongNames;
        handles.CurShortNames = MainHandles.SDCurShortNames;
        handles.ConcVariables = MainHandles.SDConcVariables;
        handles.ConcBinSizeNames = MainHandles.SDConcBinSizeNames;
        handles.ConcBinLocNames = MainHandles.SDConcBinLocNames;
        handles.ConcBinLongNames = MainHandles.SDConcBinLongNames;
        handles.ConcBinShortNames = MainHandles.SDConcBinShortNames;
        set(handles.StartTime, 'String', MainHandles.SDStartTime);
        set(handles.EndTime, 'String', MainHandles.SDEndTime);
        set(handles.Moment, 'String', MainHandles.SDMoment);
        set(handles.NDButton, 'Value', MainHandles.SDND);
        set(handles.NDdD, 'Value', MainHandles.SDNDdD);
        set(handles.NDdlogD, 'Value', MainHandles.SDNDdlogD);
        set(handles.LinearX, 'Value', MainHandles.SDLinearX);
        set(handles.LinearY, 'Value', MainHandles.SDLinearY);
        set(handles.XMin, 'String', num2str(MainHandles.SDXLim(1)));
        set(handles.XMax, 'String', num2str(MainHandles.SDXLim(2)));
        set(handles.YMin, 'String', num2str(MainHandles.SDYLim(1)));
        set(handles.YMax, 'String', num2str(MainHandles.SDYLim(2)));
        handles.curvar = MainHandles.SDVariables;
        handles.XLbl = MainHandles.SDXlabel;
        handles.YLbl = MainHandles.SDYlabel;
        handles.Title = MainHandles.SDTitle;
        handles.NumVars = MainHandles.SDNumVars;
        % Now display the data
        t0 = str2double(get(handles.StartTime, 'String'));
        t1 = str2double(get(handles.EndTime, 'String'));
        StartIndex = find(time == t0);
        EndIndex = find(time == t1);
        moment = str2double(get(handles.Moment, 'String'));
        YLims = MainHandles.SDYLim;
        hold all;
        % Plot each variable
        for i=1:handles.NumVars
           % Add the next variable to the graph
           conc = handles.cdfhandle{handles.curvar{i}}(:);
           bin_loc = handles.cdfhandle{handles.CurBinLocs{i}}(:);
           if(get(handles.NDButton, 'Value') == 1.0)
                 bin_width = ones(1, length(bin_loc));
           else
                 bin_width = handles.cdfhandle{handles.CurBins{i}}(:);
                 if(get(handles.NDdlogD, 'Value') == 1.0)
                     bin_width = log(bin_width);
                 end
           end
           bin_width = bin_width';
           N = zeros(1, length(bin_width));
           N(:) = mean(conc(StartIndex:EndIndex, :), 1);
           N(:) = N(:) .* bin_loc(:).^(moment);
           N(:) = N(:) ./ bin_width(i);
           %Get graph bounds before adding epsilon
           %S(i, :) = N(i, :) + eps;          % Add machine epsilon due to fact that log(0) is undefined  
           stairs(bin_loc, N);
        end
        hold off;
    
    
        xlabel(handles.XLbl);
        ylabel(handles.YLbl);
        title(handles.Title);
        legend(handles.CurShortNames);
        
        set(gca, 'YLim', MainHandles.SDYLim, 'XLim', MainHandles.SDXLim);
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
        handles.CurMaxX = MainHandles.SDXLim(2);
    end    
        
        %N(:) = N(:) + eps;          % Add machine epsilon due to fact that log(0) is undefined 
    
    
    
    
    % Save backups in case of invalid entries
    handles.t0 = get(handles.StartTime, 'String');
    handles.t1 = get(handles.EndTime, 'String');
    handles.y0 = get(handles.YMin, 'String');
    handles.y1 = get(handles.YMax, 'String');
    
    
    
    handles.DefaultYs = YLims;
    
    guidata(hObject, handles);
    handles.output = hObject;
end

% Update handles structure
%guidata(hObject, handles);

% UIWAIT makes sdviewer wait for user response (see UIRESUME)
%uiwait(handles.sdviewer);

function SDAxes_ButtonDownFcn(hObject, eventdata, handles)


     

% --- Outputs from this function are returned to the command line.
function varargout = sdviewer_OutputFcn(hObject, eventdata, handles) 
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
%        str2double(get(hObject,'String')) returns contents of StartTime as
%        a double

time = handles.cdfhandle{'time'}(:);   

timevec = handles.cdfhandle{'timevec'}(:);


t0 = str2double(get(hObject, 'String'));
t1 = str2double(get(handles.EndTime, 'String'));
moment = str2double(get(handles.Moment, 'String'));
if(t1 < t0)
     errordlg('Ending time must occur after starting time!', 'Error');
else
     StartIndex = find(time == t0);
     EndIndex = find(time == t1);
     if(isempty(StartIndex) || isempty(EndIndex))
         error('Given parameters outside of data range!', 'Error');
         set(handles.StartTime, 'String', handles.t0);
     else
         cla(handles.SDAxes);
         hold all;
         for i = 1:handles.NumVars
             bin_loc = handles.cdfhandle{handles.CurBinLocs{i}}(:);
             if(get(handles.NDButton, 'Value') == 1.0)
                 bin_width = ones(1, length(bin_loc));
             else
                 if(get(handles.NDdD, 'Value') == 1.0)
                     bin_width = handles.cdfhandle{handles.CurBins{i}}(:);
                 else
                     bin_width = log(handles.cdfhandle{handles.CurBins{i}}(:));
                 end
             end
             bin_width = bin_width';
             N = zeros(1, length(bin_loc));
             conc = handles.cdfhandle{handles.curvar{i}}(:);
             N(:) = mean(conc(StartIndex:EndIndex, :), 1);
             N(:) = N(:) .* bin_loc(:).^(moment)
             N(:) = N(:) ./ bin_width(:)
             stairs(bin_loc, N);
         end    
         hold off;
         t = [0 0];
         t(1) = timevec(StartIndex);
         t(2) = timevec(EndIndex);
         y = [0 0];
         y(1) = str2double(get(handles.YMin, 'String'));
         y(2) = str2double(get(handles.YMax, 'String'));
         xlabel(handles.XLbl);
         ylabel(handles.YLbl);
         title([num2str(moment) 'th moment from time ' datestr(t(1), 'HH:MM:SS') ' to time ' datestr(t(2), 'HH:MM:SS') '.']);
         legend(handles.CurShortNames);
         set(handles.SDAxes, 'XScale', 'log', 'YLim', y, 'XLim', [str2num(get(handles.XMin, 'String')) handles.CurMaxX], 'ButtonDownFcn', {@SDAxes_ButtonDownFcn, handles});
         if(get(handles.LinearY, 'Value') == 0.0)
             set(handles.SDAxes, 'YScale', 'log');
         else
             set(handles.SDAxes, 'YScale', 'linear');
         end
         if(get(handles.LinearX, 'Value') == 0.0)
             set(handles.SDAxes, 'XScale', 'log');
         else
             set(handles.SDAxes, 'XScale', 'linear'); 
         end
         handles.Title = [num2str(moment) 'th moment from time ' datestr(t(1), 'HH:MM:SS') ' to time ' datestr(t(2), 'HH:MM:SS') '.'];
         handles.t1 = get(hObject, 'String');
         
         guidata(hObject, handles);
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



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ResetButton.
function ResetButton_Callback(hObject, eventdata, handles)
% hObject    handle to ResetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in XLabelButton.
function XLabelButton_Callback(hObject, eventdata, handles)
% hObject    handle to XLabelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = 'Enter X axis label:';
title = 'Edit X Axis label';
l = 1;
Answer = {handles.XLbl};
newTitle = inputdlg(prompt, title, l, Answer);
if(~isempty(newTitle))
    handles.XLbl = newTitle{1};
    set(get(handles.SDAxes, 'XLabel'), 'String', newTitle);
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
Answer = {handles.YLbl};
newTitle = inputdlg(prompt, title, l, Answer);
if(~isempty(newTitle))
    handles.YLbl = newTitle{1};
    set(get(handles.SDAxes, 'YLabel'), 'String', newTitle);
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
Answer = {handles.Title};
newTitle = inputdlg(prompt, title, l, Answer);
if(~isempty(newTitle))
    handles.Title = newTitle{1};
    set(get(handles.SDAxes, 'Title'), 'String', newTitle);
    guidata(hObject, handles);
end    


function YMin_Callback(hObject, eventdata, handles)
% hObject    handle to YMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YMin as text
%        str2double(get(hObject,'String')) returns contents of YMin as a double
y = [0 0];
y(1) = str2double(get(hObject, 'String'));
y(2) = str2double(get(handles.YMax, 'String'));
if(y(2) < y(1))
    errordlg('Minimum Y value must be less than or equal to maximum Y value!', 'Error');
    set(hObject, 'String', handles.y0);
else
    set(handles.SDAxes, 'YLim', y);
    handles.y0 = get(hObject, 'String');
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



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
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
time = handles.cdfhandle{'time'}(:);   

timevec = handles.cdfhandle{'timevec'}(:);


t0 = str2double(get(handles.StartTime, 'String'));
t1 = str2double(get(hObject, 'String'));
moment = str2double(get(handles.Moment, 'String'));
if(t1 < t0)
     errordlg('Ending time must occur after starting time!', 'Error');
else
     StartIndex = find(time == t0);
     EndIndex = find(time == t1);
     if(isempty(StartIndex) || isempty(EndIndex))
         error('Given parameters outside of data range!', 'Error');
         set(handles.StartTime, 'String', handles.t0);
     else
         cla(handles.SDAxes);
         hold all;
         for i = 1:handles.NumVars
             bin_loc = handles.cdfhandle{handles.CurBinLocs{i}};
             if(get(handles.NDButton, 'Value') == 1.0)
                 bin_width = ones(1, length(bin_loc));
             else
                 if(get(handles.NDdD, 'Value') == 1.0)
                     bin_width = handles.cdfhandle{handles.CurBins{i}}(:);
                 else
                     bin_width = log(handles.cdfhandle{handles.CurBins{i}}(:));
                 end
             end
             N = zeros(1, length(bin_width));
             conc = handles.cdfhandle{handles.curvar{i}}(:);
             N = mean(conc(StartIndex:EndIndex, :), 1);
             N(:) = N(:) .* bin_loc(:).^(moment)
             N(:) = N(:) ./ bin_width(:);
             stairs(bin_loc, N);
         end    
         hold off;
         t = [0 0];
         t(1) = timevec(StartIndex);
         t(2) = timevec(EndIndex);
         y = [0 0];
         y(1) = str2double(get(handles.YMin, 'String'));
         y(2) = str2double(get(handles.YMax, 'String'));
         xlabel(handles.XLbl);
         ylabel(handles.YLbl);
         title([num2str(moment) 'th moment from time ' datestr(t(1), 'HH:MM:SS') ' to time ' datestr(t(2), 'HH:MM:SS') '.']);
         legend(handles.CurShortNames);
         if(get(handles.LinearY, 'Value') == 0.0)
             set(handles.SDAxes, 'YScale', 'log');
         else
             set(handles.SDAxes, 'YScale', 'linear');
         end
         if(get(handles.LinearX, 'Value') == 0.0)
            set(handles.SDAxes, 'XScale', 'log');
         else
            set(handles.SDAxes, 'XScale', 'linear'); 
         end
         handles.Title = [num2str(moment) 'th moment from time ' datestr(t(1), 'HH:MM:SS') ' to time ' datestr(t(2), 'HH:MM:SS') '.'];
         handles.t1 = get(hObject, 'String');
         set(handles.SDAxes, 'ButtonDownFcn', {@SDAxes_ButtonDownFcn, handles});
         guidata(hObject, handles);
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



function YMax_Callback(hObject, eventdata, handles)
% hObject    handle to YMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YMax as text
%        str2double(get(hObject,'String')) returns contents of YMax as a double
y = [0 0];
y(1) = str2double(get(handles.YMin, 'String'));
y(2) = str2double(get(hObject, 'String'));
if(y(2) < y(1))
    errordlg('Minimum Y value must be less than or equal to maximum Y value!', 'Error');
    set(hObject, 'String', handles.y1);
else
    set(handles.SDAxes, 'YLim', y);
    handles.y1 = get(hObject, 'String');
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


% --- Executes on button press in JPEGPlot.
function JPEGPlot_Callback(hObject, eventdata, handles)
% hObject    handle to JPEGPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uiputfile({'*.jpg;', 'JPEG Images (*.jpg)'}, 'Select a destination JPEG file');
oldpath = pwd;

if ~isequal(file, 0)
    cd(path);
    figure;
    
    time = handles.cdfhandle{'time'}(:);
    % Get upper and lower time limits
    t0 = str2double(get(handles.StartTime, 'String'));
    t1 = str2double(get(handles.EndTime, 'String'));
    StartIndex = find(time == t0);
    EndIndex = find(time == t1);
    moment = str2double(get(handles.Moment, 'String'));

    hold all;
    % Plot each variable
    for i=1:handles.NumVars
       % Add the next variable to the graph
       conc = handles.cdfhandle{handles.curvar{i}}(:);
       bin_loc = handles.cdfhandle{handles.CurBinLocs{i}}(:);
       if(get(handles.NDButton, 'Value') == 1.0)
                 bin_width = ones(1, length(bin_loc));
       else
                 if(get(handles.NDdD, 'Value') == 1.0)
                     bin_width = handles.cdfhandle{handles.CurBins{i}}(:);
                 else
                     bin_width = log(handles.cdfhandle{handles.CurBins{i}}(:));
                 end
       end
       bin_width = bin_width';
       N = zeros(1, length(bin_width));
       N = mean(conc(StartIndex:EndIndex, :), 1);
       N(:) = N(:) .* bin_loc(:).^(moment)
       N(:) = N(:) ./ bin_width(i);
       %Get graph bounds before adding epsilon
       %S(i, :) = N(i, :) + eps;          % Add machine epsilon due to fact that log(0) is undefined  
       stairs(bin_loc, N);
    end
    hold off;
          
    
    xlabel(get(get(handles.SDAxes, 'XLabel'), 'String'));
    ylabel(get(get(handles.SDAxes, 'YLabel'), 'String'));
    title(get(get(handles.SDAxes, 'Title'), 'String'));
    legend(handles.CurShortNames);
    y = [0 0];
    y(1) = str2double(get(handles.YMin, 'String'));
    y(2) = str2double(get(handles.YMax, 'String'));
    x = [str2double(get(handles.XMin, 'String')) str2double(get(handles.XMax, 'String'))];
    set(gca, 'YLim', y, 'XLim', x);
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
    print(gcf, '-djpeg', file);
    cd(oldpath);
end    

%    --- Executes on button press in CloseButton.
function CloseButton_Callback(hObject, eventdata, handles)
% hObject    handle to CloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.sdviewer);


% --- Executes on button press in PrintButton.
function PrintButton_Callback(hObject, eventdata, handles)
% hObject    handle to PrintButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


figure;
    
    % Get upper and lower time limits
time = handles.cdfhandle{'time'}(:);
t0 = str2double(get(handles.StartTime, 'String'));
t1 = str2double(get(handles.EndTime, 'String'));
StartIndex = find(time == t0);
EndIndex = find(time == t1);
moment = str2double(get(handles.Moment, 'String'));

hold all;
% Plot each variable
for i=1:handles.NumVars
       % Add the next variable to the graph
       conc = handles.cdfhandle{handles.curvar{i}}(:);
       bin_loc = handles.cdfhandle{handles.CurBinLocs{i}}(:);
       if(get(handles.NDButton, 'Value') == 1.0)
                 bin_width = ones(1, length(bin_loc));
       else
                 if(get(handles.NDdD, 'Value') == 1.0)
                     bin_width = handles.cdfhandle{handles.CurBins{i}}(:);
                 else
                     bin_width = log(handles.cdfhandle{handles.CurBins{i}}(:));
                 end
       end
       bin_width = bin_width';
       N = zeros(1, length(bin_width));
       N(:) = mean(conc(StartIndex:EndIndex, :), 1);
       N(:) = N(:) .* bin_loc(:).^(moment);
       N(:) = N(:) ./ bin_width(i);
       %Get graph bounds before adding epsilon
       %S(i, :) = N(i, :) + eps;          % Add machine epsilon due to fact that log(0) is undefined  
       stairs(bin_loc, N);
end
hold off;
          
    
xlabel(get(get(handles.SDAxes, 'XLabel'), 'String'));
ylabel(get(get(handles.SDAxes, 'YLabel'), 'String'));
title(get(get(handles.SDAxes, 'Title'), 'String'));
legend(handles.CurShortNames);
y = [0 0];
y(1) = str2double(get(handles.YMin, 'String'));
y(2) = str2double(get(handles.YMax, 'String'));
x = [str2double(get(handles.XMin, 'String')) str2double(get(handles.XMax, 'String'))];
set(gca, 'YLim', y, 'XLim', x);
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
print(gcf);


% --------------------------------------------------------------------
function ChangeSD_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ChangeSDItem_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeSDItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[Selection, ok] = listdlg('ListString', handles.ConcBinShortNames, 'Name', 'Select a Probe', ... 
                          'SelectionMode', 'single', ...
                          'PromptString', 'List of Time Series Variables:');                          
% Replot the new graph
if(ok == 1)
     hold off;
     
     time = handles.cdfhandle{'time'}(:);   
     conc = handles.cdfhandle{handles.ConcVariables{Selection}}(:);
     
     
     timevec = handles.cdfhandle{'timevec'}(:);
     moment = str2double(get(handles.Moment, 'String'));
     bin_loc = handles.cdfhandle{handles.ConcBinLocNames{Selection}}(:);
     if(get(handles.NDButton, 'Value') == 1.0)
                 bin_width = ones(1, length(bin_loc));
     else
                 if(get(handles.NDdD, 'Value') == 1.0)
                     bin_width = handles.cdfhandle{handles.CurBins{i}}(:);
                 else
                     bin_width = log(handles.cdfhandle{handles.CurBins{i}}(:));
                 end
     end
     bin_width = bin_width';
     N = zeros(1, length(bin_width));
     
     t0 = str2double(get(handles.StartTime, 'String'));
     t1 = str2double(get(handles.EndTime, 'String'));
     StartIndex = find(time == t0);
     EndIndex = find(time == t1);
     handles.curvar = {};
     handles.CurBins = {};
     handles.curvar = {handles.ConcVariables{Selection}};
     handles.CurBins = {handles.ConcBinSizeNames{Selection}};
     handles.CurBinLocs = {};
     handles.CurBinLocs = {handles.ConcBinLocNames{Selection}};
     N = mean(conc(StartIndex:EndIndex, :), 1);
     N(:) = N(:) .* bin_loc(:).^(moment);
     N(:) = N(:) ./ bin_width(:);
     % Get graph bounds before adding epsilon
     YLims = get(handles.SDAxes, 'YLim');
     %N(:) = N(:) + eps;          % Add machine epsilon due to fact that log(0) is undefined  
     
     stairs(bin_loc, N);
     t = [timevec(StartIndex) timevec(EndIndex)];
     handles.XLbl = 'Diameter [\mum]';
     LongName = handles.cdfhandle{handles.ConcVariables{Selection}}.long_name(:);
     ShortName = handles.cdfhandle{handles.ConcVariables{Selection}}.short_name(:);
     handles.CurLongNames = {};
     handles.CurLongNames = {LongName};
     handles.CurShortNames = {};
     handles.CurShortNames = {ShortName};
     
     legend(ShortName);
     handles.YLbl = ['N ' handles.cdfhandle{handles.ConcVariables{Selection}}.units(:)];
     handles.Title = ['Mean ' LongName ' from time ' datestr(t(1), 'HH:MM:SS') ' to ' datestr(t(2), 'HH:MM:SS') '.'];
     xlabel('Diameter [\mum]');
     ylabel(['N ' handles.cdfhandle{handles.ConcVariables{Selection}}.units(:)]);
     title([num2str(moment) 'th moment from time ' datestr(t(1), 'HH:MM:SS') ' to ' datestr(t(2), 'HH:MM:SS') '.']);
     y = get(gca, 'YLim');
     x = get(gca, 'XLim');
     set(handles.XMin, 'String', num2str(x(1)));
     set(handles.XMax, 'String', num2str(x(2)));
     set(handles.YMin, 'String', num2str(y(1)));
     set(handles.YMax, 'String', num2str(y(2)));
     zoom reset;
     handles.NumVars = 1;
     
     if(get(handles.LinearY, 'Value') == 0.0)
         set(handles.SDAxes, 'YScale', 'log');
     else
         set(handles.SDAxes, 'YScale', 'linear');
     end
     if(get(handles.LinearX, 'Value') == 0.0)
        set(handles.SDAxes, 'XScale', 'log');
     else
        set(handles.SDAxes, 'XScale', 'linear'); 
     end
     y = get(handles.SDAxes, 'YLim');
     set(handles.YMin, 'String', num2str(y(1)));
     set(handles.YMax, 'String', num2str(y(2)));
     
     handles.DefaultYs = YLims;
     guidata(hObject, handles);
end


% --- Executes on button press in LinearY.
function LinearY_Callback(hObject, eventdata, handles)
% hObject    handle to LinearY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LinearY
if(get(hObject, 'Value') == 0.0)
    %ticks = logspace(floor(log(y(1))),ceil(log(y(2))), 30);
    set(handles.SDAxes, 'YScale', 'log')
else
    %ticks = linspace(y(1),y(2), 10);
    set(handles.SDAxes, 'YScale', 'linear')
end
XLims = get(gca, 'XLim');
YLims = get(gca, 'YLim');
set(handles.XMin, 'String', num2str(XLims(1)));
set(handles.XMax, 'String', num2str(XLims(2)));
set(handles.YMin, 'String', num2str(YLims(1)));
set(handles.YMax, 'String', num2str(YLims(2)));
% --- Executes on button press in DefaultsButton.
function DefaultsButton_Callback(hObject, eventdata, handles)
% hObject    handle to DefaultsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isequal(questdlg('Resetting values will result in loss of unsaved data. Are you sure?', 'Warning', 'Yes', 'No', 'No'), 'Yes'))

set(handles.SDAxes, 'YLim', handles.DefaultYs);
set(handles.YMin, 'String', num2str(handles.DefaultYs(1)));
set(handles.YMax, 'String', num2str(handles.DefaultYs(2)));

end


% --------------------------------------------------------------------
function AddSDVariable_Callback(hObject, eventdata, handles)
% hObject    handle to AddSDVariable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[Selection, ok] = listdlg('ListString', handles.ConcBinShortNames, 'Name', 'Select a Probe', ... 
                          'SelectionMode', 'single', ...
                          'PromptString', 'List of Time Series Variables:');                          
% Replot the new graph
if(ok == 1)
     time = handles.cdfhandle{'time'}(:);   
     
     
     timevec = handles.cdfhandle{'timevec'}(:);
     dims = size(handles.cdfhandle{handles.ConcVariables{Selection}});
     
     handles.NumVars = handles.NumVars + 1;
              
     t0 = str2double(get(handles.StartTime, 'String'));
     t1 = str2double(get(handles.EndTime, 'String'));
     StartIndex = find(time == t0);
     EndIndex = find(time == t1);
     handles.curvar = [handles.curvar handles.ConcVariables{Selection}];
     handles.CurBins = [handles.CurBins handles.ConcBinSizeNames{Selection}];
     handles.CurBinLocs = [handles.CurBinLocs handles.ConcBinLocNames{Selection}] 
     handles.CurLongNames = [handles.CurLongNames handles.ConcBinLongNames{Selection}];
     handles.CurShortNames = [handles.CurShortNames handles.ConcBinShortNames{Selection}];
     moment = str2double(get(handles.Moment, 'String'));
     
     % Set the minimum and maximum Y values to be changable on the
     % first iteration
         
     hold all;
         
         % Add the next variable to the graph
         conc = handles.cdfhandle{handles.ConcVariables{Selection}}(:);
         
        
         bin_loc = handles.cdfhandle{handles.ConcBinLocNames{Selection}}(:);
         if(get(handles.NDButton, 'Value') == 1.0)
                 bin_width = ones(1, length(bin_loc));
         else
                 if(get(handles.NDdD, 'Value') == 1.0)
                     bin_width = handles.cdfhandle{handles.ConcBinSizeNames{Selection}}(:);
                 else
                     bin_width = log(handles.cdfhandle{handles.ConcBinSizeNames{Selection}}(:));
                 end
         end
         bin_width = bin_width';
         S = ones(1, length(bin_loc));
         S(:) = mean(conc(StartIndex:EndIndex, :), 1);
         S(:) = S(:) .* bin_loc(:).^(moment);
         S(:) = S(:) ./ bin_width(:);
         %Get graph bounds before adding epsilon
         %S(i, :) = S(i, :) + eps;          % Add machine epsilon due to fact that log(0) is undefined  
         stairs(bin_loc, S);
     hold off;    
     
     t = [timevec(StartIndex) timevec(EndIndex)];
     handles.XLbl = 'Diameter [\mum]';
     handles.YLbl = ['N ' handles.cdfhandle{handles.ConcVariables{Selection}}.units(:)];
     handles.Title = [num2str(moment) 'th moment from time ' datestr(t(1), 'HH:MM:SS') ' to ' datestr(t(2), 'HH:MM:SS') '.'];
     xlabel('Diameter [\mum]');
     ylabel(['N ' handles.cdfhandle{handles.ConcVariables{Selection}}.units(:)]);
     title([num2str(moment) 'th moment from time ' datestr(t(1), 'HH:MM:SS') ' to ' datestr(t(2), 'HH:MM:SS') '.']);
     legend(handles.CurShortNames);
     y = [str2double(get(handles.YMin, 'String')) str2double(get(handles.YMax, 'String'))];
     x = get(gca, 'XLim');
     y = [min([y(1) min(S)]) max([y(2) max(S)])];
     x = [min([x(1) min(bin_loc)]) max([x(2) max(bin_loc)])];
     set(handles.SDAxes, 'YLim', y, 'XLim', x);
     zoom reset;
     set(handles.XMin, 'String', num2str(x(1)));
     set(handles.XMax, 'String', num2str(x(2)));
    % set(handles.YMin, 'String', num2str(y(1)));
    % set(handles.YMax, 'String', num2str(y(2)));

     
     
     % Check to see if we are using linear scales
     if(get(handles.LinearY, 'Value') == 0.0)
             set(handles.SDAxes, 'YScale', 'log');
     else
             set(handles.SDAxes, 'YScale', 'linear');
     end
     if(get(handles.LinearX, 'Value') == 0.0)
        set(handles.SDAxes, 'XScale', 'log');
     else
        set(handles.SDAxes, 'XScale', 'linear'); 
     end
     
     
     guidata(hObject, handles);
        
end


% --- Executes on button press in LinearX.
function LinearX_Callback(hObject, eventdata, handles)
% hObject    handle to LinearX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LinearX

if(get(hObject, 'Value') == 0.0)
    %ticks = logspace(floor(log(x(1))), ceil(log(x(2))), 30);
    set(handles.SDAxes, 'XScale', 'log');
else
    %ticks = linspace(x(1),x(2), 10);
    set(handles.SDAxes, 'XScale', 'linear');
end
XLims = get(gca, 'XLim');
YLims = get(gca, 'YLim');
set(handles.XMin, 'String', num2str(XLims(1)));
set(handles.XMax, 'String', num2str(XLims(2)));
set(handles.YMin, 'String', num2str(YLims(1)));
set(handles.YMax, 'String', num2str(YLims(2)));


% --- Executes on button press in ZoomX.
function ZoomX_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomX (see GCBO)
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
        set(handles.SDAxes, 'XLim', x);
        set(handles.XMin, 'String', num2str(x(1)));
        set(handles.XMax, 'String', num2str(x(2)));
end

function XMin_Callback(hObject, eventdata, handles)
% hObject    handle to XMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XMin as text
%        str2double(get(hObject,'String')) returns contents of XMin as a double
x = [0 0];
x(1) = str2double(get(hObject, 'String'));
x(2) = str2double(get(handles.XMax, 'String'));
if(x(2) < x(1))
    errordlg('Minimum X value must be less than or equal to maximum X value!', 'Error');
    xs = get(handles.SDAxes, 'XLim');
    set(hObject, 'String', num2str(xs(2)));
else
    set(handles.SDAxes, 'XLim', x);
    handles.y1 = get(hObject, 'String');
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
x = [0 0];
x(1) = str2double(get(handles.XMin, 'String'));
x(2) = str2double(get(hObject, 'String'));
if(x(2) < x(1))
    errordlg('Minimum X value must be less than or equal to maximum X value!', 'Error');
    xs = get(handles.SDAxes, 'XLim');
    set(hObject, 'String', num2str(xs(2)));
else
    set(handles.SDAxes, 'XLim', x);
    handles.y1 = get(hObject, 'String');
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


% --- Executes on button press in ZoomY.
function ZoomY_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomY (see GCBO)
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
        set(handles.SDAxes, 'YLim', y);
        set(handles.YMin, 'String', num2str(y(1)));
        set(handles.YMax, 'String', num2str(y(2)));
end


% --- Executes on button press in NDButton.
function NDButton_Callback(hObject, eventdata, handles)
% hObject    handle to NDButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NDButton

set(hObject, 'Value', 1.0);
set(handles.NDdD, 'Value', 0.0);
set(handles.NDdlogD, 'Value', 0.0);

time = handles.cdfhandle{'time'}(:);   
t0 = str2double(get(handles.StartTime, 'String'));
t1 = str2double(get(handles.EndTime, 'String'));
moment = str2double(get(handles.Moment, 'String'));
StartIndex = find(time == t0);
EndIndex = find(time == t1);
   
cla(handles.SDAxes);
hold all;
minX = inf;
maxX = -inf;
minY = inf;
maxY = -inf;
for i = 1:handles.NumVars
             bin_loc = handles.cdfhandle{handles.CurBinLocs{i}}(:)
             N = zeros(1, length(bin_loc));
             conc = handles.cdfhandle{handles.curvar{i}}(:);
             N = mean(conc(StartIndex:EndIndex, :), 1);
             N(:) = N(:) .* bin_loc(:).^(moment);
             stairs(bin_loc, N);
             minX = min([minX min(bin_loc)]);
             maxX = max([maxX max(bin_loc)]);
             minY = min([minY min(N)]);
             maxY = max([maxY max(N)]);
end    
hold off;
set(gca, 'XLim', [minX maxX]);
set(gca, 'YLim', [minY maxY]);
set(handles.XMin, 'String', num2str(minX));
set(handles.XMax, 'String', num2str(maxX));
set(handles.YMin, 'String', num2str(minY));
set(handles.YMax, 'String', num2str(maxY));
zoom reset;

xlabel(handles.XLbl);
ylabel('N(D) [{cm}^{-3}]');
handles.YLbl = 'N(D) [{cm}^{-3}{\mum}^-1]';
title(handles.Title);
legend(handles.CurShortNames);
if(get(handles.LinearY, 'Value') == 0.0)
             set(handles.SDAxes, 'YScale', 'log');
else
             set(handles.SDAxes, 'YScale', 'linear');
end
if(get(handles.LinearX, 'Value') == 0.0)
        set(handles.SDAxes, 'XScale', 'log');
else
        set(handles.SDAxes, 'XScale', 'linear'); 
end
         
% --- Executes on button press in NDdD.
function NDdD_Callback(hObject, eventdata, handles)
% hObject    handle to NDdD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'Value', 1.0);
set(handles.NDButton, 'Value', 0.0);
set(handles.NDdlogD, 'Value', 0.0);

time = handles.cdfhandle{'time'}(:);   
timevec = handles.cdfhandle{'timevec'}(:);
t0 = str2double(get(handles.StartTime, 'String'));
t1 = str2double(get(handles.EndTime, 'String'));
moment = str2double(get(handles.Moment, 'String'));
StartIndex = find(time == t0);
EndIndex = find(time == t1);
   
cla(handles.SDAxes);
hold all;
minX = inf;
maxX = -inf;
minY = inf;
maxY = -inf;
for i = 1:handles.NumVars
             bin_loc = handles.cdfhandle{handles.CurBinLocs{i}}(:);
             bin_width = handles.cdfhandle{handles.CurBins{i}}(:);
             N = zeros(1, length(bin_loc));
             conc = handles.cdfhandle{handles.curvar{i}}(:);
             N = mean(conc(StartIndex:EndIndex, :), 1);
             N(:) = N(:) .* bin_loc(:).^(moment);
             N(:) = N(:) ./ bin_width(:);
             stairs(bin_loc, N);
             minX = min([minX min(bin_loc)]);
             maxX = max([maxX max(bin_loc)]);
             minY = min([minY min(N)]);
             maxY = max([maxY max(N)]);
end    
hold off;
set(gca, 'XLim', [minX maxX]);
set(gca, 'YLim', [minY maxY]);
set(handles.XMin, 'String', num2str(minX));
set(handles.XMax, 'String', num2str(maxX));
set(handles.YMin, 'String', num2str(minY));
set(handles.YMax, 'String', num2str(maxY));
zoom reset;
xlabel(handles.XLbl);
ylabel('N(D) [{cm}^{-3}{\mum}^-1]');
handles.YLbl = 'N(D) [{cm}^{-3}{\mum}^-1]';
title(handles.Title);
legend(handles.CurShortNames);
if(get(handles.LinearY, 'Value') == 0.0)
             set(handles.SDAxes, 'YScale', 'log');
else
             set(handles.SDAxes, 'YScale', 'linear');
end
if(get(handles.LinearX, 'Value') == 0.0)
        set(handles.SDAxes, 'XScale', 'log');
else
        set(handles.SDAxes, 'XScale', 'linear'); 
end
% Hint: get(hObject,'Value') returns toggle state of NDdD


% --- Executes on button press in NDdlogD.
function NDdlogD_Callback(hObject, eventdata, handles)
% hObject    handle to NDdlogD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NDdlogD

set(hObject, 'Value', 1.0);
set(handles.NDButton, 'Value', 0.0);
set(handles.NDdD, 'Value', 0.0);

time = handles.cdfhandle{'time'}(:);   
t0 = str2double(get(handles.StartTime, 'String'));
t1 = str2double(get(handles.EndTime, 'String'));
moment = str2double(get(handles.Moment, 'String'));
StartIndex = find(time == t0);
EndIndex = find(time == t1);
   
cla(handles.SDAxes);
hold all;
minX = inf;
maxX = -inf;
minY = inf;
maxY = -inf;
for i = 1:handles.NumVars
             bin_loc = handles.cdfhandle{handles.CurBinLocs{i}}(:);
             bin_width = log(handles.cdfhandle{handles.CurBins{i}}(:));
             N = zeros(1, length(bin_loc));
             conc = handles.cdfhandle{handles.curvar{i}}(:);
             N = mean(conc(StartIndex:EndIndex, :), 1);
             N(:) = N(:) .* bin_loc(:).^(moment);
             N(:) = N(:) ./ bin_width(:);
             stairs(bin_loc, N);
             minX = min([minX min(bin_loc)]);
             maxX = max([maxX max(bin_loc)]);
             minY = min([minY min(N)]);
             maxY = max([maxY max(N)]);
end    
hold off;
set(gca, 'XLim', [minX maxX]);
set(gca, 'YLim', [minY maxY]);
set(handles.XMin, 'String', num2str(minX));
set(handles.XMax, 'String', num2str(maxX));
YLims = get(gca, 'YLim');
set(handles.YMin, 'String', num2str(YLims(1)));
set(handles.YMax, 'String', num2str(YLims(2)));
zoom reset;

xlabel(handles.XLbl);
ylabel('N(D) [{cm}^{-3}{\mum}^-1]');
handles.YLbl = 'N(D) [{cm}^{-3}{\mum}^-1]';
title(handles.Title);
legend(handles.CurShortNames);
if(get(handles.LinearY, 'Value') == 0.0)
             set(handles.SDAxes, 'YScale', 'log');
else
             set(handles.SDAxes, 'YScale', 'linear');
end
if(get(handles.LinearX, 'Value') == 0.0)
        set(handles.SDAxes, 'XScale', 'log');
else
        set(handles.SDAxes, 'XScale', 'linear'); 
end



function Moment_Callback(hObject, eventdata, handles)
% hObject    handle to Moment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    struc`ture with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Moment as text
%        str2double(get(hObject,'String')) returns contents of Moment as a double

time = handles.cdfhandle{'time'}(:);   

timevec = handles.cdfhandle{'timevec'}(:);


t0 = str2double(get(handles.StartTime, 'String'));
t1 = str2double(get(handles.EndTime, 'String'));
moment = str2double(get(handles.Moment, 'String'));
StartIndex = find(time == t0);
EndIndex = find(time == t1);
     
cla(handles.SDAxes);
hold all;
minX = inf;
maxX = -inf;
minY = inf;
maxY = -inf;
for i = 1:handles.NumVars
             bin_loc = handles.cdfhandle{handles.CurBinLocs{i}}(:);
             if(get(handles.NDButton, 'Value') == 1.0)
                 bin_width = ones(1, length(bin_loc));
             else
                 if(get(handles.NDdD, 'Value') == 1.0)
                     bin_width = handles.cdfhandle{handles.CurBins{i}}(:);
                 else
                     bin_width = log(handles.cdfhandle{handles.CurBins{i}}(:));
                 end
             end
             bin_width = bin_width';
             N = zeros(1, length(bin_loc));
             conc = handles.cdfhandle{handles.curvar{i}}(:);
             N(:) = mean(conc(StartIndex:EndIndex, :), 1);
             N(:) = N(:) .* bin_loc(:).^(moment)
             N(:) = N(:) ./ bin_width(:);
             stairs(bin_loc, N);
             minX = min([minX min(bin_loc)]);
             maxX = max([maxX max(bin_loc)]);
             minY = min([minY min(N)]);
             maxY = max([maxY max(N)]);
end    
hold off;
set(gca, 'XLim', [minX maxX]);
set(gca, 'YLim', [minY maxY]);
t = [timevec(StartIndex) timevec(EndIndex)];

set(handles.XMin, 'String', num2str(minX));
set(handles.XMax, 'String', num2str(maxX));
set(handles.YMin, 'String', num2str(minY));
set(handles.YMax, 'String', num2str(maxY));
zoom reset;

xlabel(handles.XLbl);
ylabel(handles.YLbl);
title([num2str(moment) 'th moment from time ' datestr(t(1), 'HH:MM:SS') ' to time ' datestr(t(2), 'HH:MM:SS') '.']);
handles.Title = [num2str(moment) 'th moment from time ' datestr(t(1), 'HH:MM:SS') ' to time ' datestr(t(2), 'HH:MM:SS') '.'];
legend(handles.CurShortNames);

if(get(handles.LinearY, 'Value') == 0.0)
       set(handles.SDAxes, 'YScale', 'log');
       %ticks = logspace(floor(log(y(1))), floor(log(y(2))), 30);
       %set(handles.SDAxes, 'YTick', ticks);
else
       set(handles.SDAxes, 'YScale', 'linear');
       %ticks = linspace(y(1), y(2), 10);
       %set(handles.SDAxes, 'YTick', ticks);
end
if(get(handles.LinearX, 'Value') == 0.0)
       set(handles.SDAxes, 'XScale', 'log');
else
       set(handles.SDAxes, 'XScale', 'linear'); 
end
guidata(hObject, handles);
    
% --- Executes during object creation, after setting all properties.
function Moment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Moment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PlotSeries.
function PlotSeries_Callback(hObject, eventdata, handles)
% hObject    handle to PlotSeries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = 'Enter interval of graphs in seconds:';
title = 'Enter interval';
l = 1;
Answer = {'10'};
interval = str2double(inputdlg(prompt, title, l, Answer));
moment = str2double(get(handles.Moment, 'String'));
if(interval > 0)
    time = handles.cdfhandle{'time'}(:);
    timevec = handles.cdfhandle{'timevec'}(:);
    StartIndex = find(str2double(get(handles.StartTime, 'String')) == time);
    EndIndex = find(str2double(get(handles.EndTime, 'String')) == time);
    NoIntervals = ceil((EndIndex - StartIndex)/interval);
    directory_name = uigetdir('.', 'Pick A Directory To Save the SD JPEGs');
    if(~isequal(directory_name,''))
        lasttime = EndIndex;
        x0 = StartIndex;
        
        olddir = pwd;
        
        fig = figure;
        figaxes = gca;
        for j = 1:NoIntervals
            cla(figaxes);
            hold all;
            for i = 1:handles.NumVars         
                 bin_loc = handles.cdfhandle{handles.CurBinLocs{i}}(:);
                 if(get(handles.NDButton, 'Value') == 1.0)
                     bin_width = ones(1, length(bin_loc));
                     Ylabel = 'N(D) {cm}^-3';
                 else
                     if(get(handles.NDdD, 'Value') == 1.0)
                         bin_width = handles.cdfhandle{handles.CurBins{i}}(:);
                     else
                         bin_width = log(handles.cdfhandle{handles.CurBins{i}}(:));
                     end
                     Ylabel = 'N(D) {\mum}^-1 {cm}^-3';
                 end
                 bin_width = bin_width';
                 N = zeros(1, length(bin_loc));
                 conc = handles.cdfhandle{handles.curvar{i}}(:);
                 N(:) = mean(conc(x0:min([x0+interval-1 lasttime]), :), 1);
                 N(:) = N(:) .* bin_loc(:).^(moment);
                 N(:) = N(:) ./ bin_width(:);
                 stairs(figaxes, bin_loc, N);
            end
            hold off;
            xlim(get(handles.SDAxes, 'XLim'));
            ylim(get(handles.SDAxes, 'YLim'));
            if(get(handles.LinearY, 'Value') == 0.0)
               set(figaxes, 'YScale', 'log');
            else
               set(figaxes, 'YScale', 'linear');
            end
            if(get(handles.LinearX, 'Value') == 0.0)
                   set(figaxes, 'XScale', 'log');
            else
                   set(figaxes, 'XScale', 'linear'); 
            end
            xlabel('Bin diameter (cm)');
            ylabel(Ylabel);
            set(get(figaxes, 'Title'), 'String', [num2str(moment) 'th moment from time ' datestr(timevec(x0), 'HH:MM:SS') ' to time ' datestr(timevec(min([x0+interval-1 lasttime])), 'HH:MM:SS')]); 
            handles.Title = [num2str(moment) 'th moment from time ' datestr(timevec(x0), 'HH:MM:SS') ' to time ' datestr(timevec(x0+interval), 'HH:MM:SS')];
            legend(handles.CurShortNames, 'Location', 'NorthWest');
            cd(directory_name)
            saveas(fig, ['SD' num2str(time(x0)) 'to' num2str(time(x0+interval)) '.jpg'], 'jpeg');    
            x0 = x0 + interval;
            cd(olddir);
        end
        hold off;
        cd(olddir);
    end  
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


% --- Executes on mouse motion over figure - except title and menu.
function sdviewer_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to sdviewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AutofitYButton.
function AutofitYButton_Callback(hObject, eventdata, handles)
% hObject    handle to AutofitYButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
time = handles.cdfhandle{'time'}(:);   

timevec = handles.cdfhandle{'timevec'}(:);


t0 = str2double(get(handles.StartTime, 'String'));
t1 = str2double(get(handles.EndTime, 'String'));
moment = str2double(get(handles.Moment, 'String'));
StartIndex = find(time == t0);
EndIndex = find(time == t1);
     
cla(handles.SDAxes);
hold all;
minX = inf;
maxX = -inf;
minY = inf;
maxY = -inf;
for i = 1:handles.NumVars
             bin_loc = handles.cdfhandle{handles.CurBinLocs{i}}(:);
             if(get(handles.NDButton, 'Value') == 1.0)
                 bin_width = ones(1, length(bin_loc));
             else
                 if(get(handles.NDdD, 'Value') == 1.0)
                     bin_width = handles.cdfhandle{handles.CurBins{i}}(:);
                 else
                     bin_width = log(handles.cdfhandle{handles.CurBins{i}}(:));
                 end
             end
             bin_width = bin_width';
             N = zeros(1, length(bin_loc));
             conc = handles.cdfhandle{handles.curvar{i}}(:);
             N(:) = mean(conc(StartIndex:EndIndex, :), 1);
             N(:) = N(:) .* bin_loc(:).^(moment)
             N(:) = N(:) ./ bin_width(:);
             stairs(bin_loc, N);
             minX = min([minX min(bin_loc)]);
             maxX = max([maxX max(bin_loc)]);
             minY = min([minY min(N)]);
             maxY = max([maxY max(N)]);
end    

set(gca, 'YLim', [minY maxY]);
set(handles.YMin, 'String', num2str(curMin));
set(handles.YMax, 'String', num2str(curMax));


