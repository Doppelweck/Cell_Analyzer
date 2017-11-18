% main file CellAnalyzer Application
%controllerEdit   Controller of the edit-MVC (Model-View-Controller).
%Controls the communication and data exchange between the view
%instance and the model instance. Connected to the analyze
%controller to communicate with the analyze MVC and to exchange data 
%between them.
%
%
%======================================================================
%
% AUTHOR:           - Sebastian Friedrich,
%                     s.friedrich@hochschule-trier.de
%                     Trier University of Applied Sciences, Germany
%
% SUPERVISOR:       - Dipl. Ing. Michael Schweigmann
%                     Trier University of Applied Sciences, Germany
%
% FIRST VERSION:    16.10.2017 (V1.0)
%
% REVISION:         none
%
%======================================================================
%

try %Try to run the application
    %Load all needed files
    addpath(genpath('Functions and Toolboxes'));
    
    cl; %Clear all existing classes, objects and figures
    
    %Create main figure
    mainFig = figure('Units','normalized','Position',[0.01 0.05 0.98 0.85],...
        'Name','Muscle-Fiber-Classification-Tool','DockControls','off',...
        'doublebuffer', 'off','Menubar','figure','Visible','on',...
        'WindowStyle','normal','NumberTitle','off',...
        'PaperPositionMode','auto',...
        'InvertHardcopy','off');
    
    % hide needless ToogleTool objects in the main figure 
    set( findall(mainFig,'ToolTipString','Edit Plot') ,'Visible','Off');
    set( findall(mainFig,'ToolTipString','Insert Colorbar') ,'Visible','Off');
    set( findall(mainFig,'ToolTipString','Insert Legend') ,'Visible','Off');
    set( findall(mainFig,'ToolTipString','Hide Plot Tools') ,'Visible','Off');
    set( findall(mainFig,'ToolTipString','New Figure') ,'Visible','Off');
    set( findall(mainFig,'ToolTipString','Show Plot Tools') ,'Visible','Off');
    set( findall(mainFig,'ToolTipString','Brush/Select Data') ,'Visible','Off');
    set( findall(mainFig,'ToolTipString','Show Plot Tools and Dock Figure') ,'Visible','Off');
    set( findall(mainFig,'ToolTipString','Link Plot') ,'Visible','Off');
    set( findall(mainFig,'ToolTipString','Save Figure') ,'Visible','Off');
    set( findall(mainFig,'ToolTipString','Open File') ,'Visible','Off');
    
    % Init View Classes
    viewHandle = viewCellAnalyzer(mainFig);
    
    % Init Model Classes
    modelHandle = modelCellAnalyzer();
    
    % Init Controller Classes
    controllerHandle = controllerCellAnalyzer(mainFig, viewHandle, modelHandle);
    
    modelHandle.hController = controllerHandle;
    
    
catch %Show Error Message if starting the application fails
    ErrorInfo = lasterror;
    Text = [];
    Text{1,1} = ErrorInfo.message;
    Text{2,1} = '';
    
    if any(strcmp('stack',fieldnames(ErrorInfo)))
        
        for i=1:size(ErrorInfo.stack,1)
            
            Text{end+1,1} = [ErrorInfo.stack(i).file];
            Text{end+1,1} = [ErrorInfo.stack(i).name];
            Text{end+1,1} = ['Line: ' num2str(ErrorInfo.stack(i).line)];
            Text{end+1,1} = '------------------------------------------';
            
        end
        
    end
    
    mode = struct('WindowStyle','modal','Interpreter','tex');
    
    uiwait(errordlg(Text,'ERROR: Application',mode));
    
end