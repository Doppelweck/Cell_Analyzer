classdef viewCellAnalyzer < handle
    
    properties(SetObservable)
        mainCard = [];
        mainCardPanels = {};
        panelData = {};
        panelControl = {};
        hAxes; % Axes that shows the Video Frame for selecting ROIs
        hButton; %Handles to all Button and Text UI Elements
    end
    
    methods
        function obj = viewCellAnalyzer(mainFig)
            
            % Create Card Panel Object
            obj.mainCard = uix.CardPanel('Parent', mainFig,'Selection',0);
            % First Card Panel. To load files and select ROIs
            mainCardPanels{1} = uix.HBox( 'Parent', obj.mainCard, 'Spacing',5,'Padding',5);
            % Second Card Panel. To analyze the selected ROIs
            mainCardPanels{2} = uix.HBox( 'Parent', obj.mainCard, 'Spacing',5,'Padding',5);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Create GUI objects for the 1st Card Panel (ROI)
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.mainCard.Selection = 1;
            obj.panelData{1} = uix.Panel('Parent', mainCardPanels{1},'Title', 'filename', 'FontUnits','normalized','Fontsize',0.03,'Padding',5);
            obj.panelControl{1} = uix.Panel('Parent', mainCardPanels{1},'Title', 'Control Panel' ,'FontUnits','normalized','Fontsize',0.03,'Padding',5);
            set(mainCardPanels{1}, 'MinimumWidths', [1 320] );
            set(mainCardPanels{1}, 'Widths', [-4 -1] );
            
            % 1st Card Panel. Data Panel (left) %%%%%%%%%%%%%%%%%%%%%%%%%%
            panelDataVBox = uix.VBox('Parent',obj.panelData{1},'Spacing', 5,'Padding',5);
            obj.hAxes.videoFrameROI = axes('Parent',uicontainer('Parent', panelDataVBox),'FontUnits','normalized','Fontsize',0.015);
            axis image
            axis on
            set(obj.hAxes.videoFrameROI, 'LooseInset', [0,0,0,0]);
            
            videoInfoBox = uix.HBox('Parent', panelDataVBox,'Spacing', 5);
            uicontrol( 'Parent', videoInfoBox,'Style','text','FontUnits','normalized','Fontsize',0.5, 'String', 'Play Speed in FPS :' ,'Enable','on');
            obj.hButton.FPS = uicontrol( 'Parent', videoInfoBox,'Style','edit','FontUnits','normalized','Fontsize',0.5, 'String', '--' ,'Enable','on');
            uix.Empty( 'Parent', videoInfoBox );
            uicontrol( 'Parent', videoInfoBox,'Style','text','FontUnits','normalized','Fontsize',0.5, 'String', 'Frame :' ,'Enable','on');
            obj.hButton.FrameLineText = uicontrol( 'Parent', videoInfoBox,'Style','text','FontUnits','normalized','Fontsize',0.5, 'String', '--/--' ,'Enable','on');
            uix.Empty( 'Parent', videoInfoBox );
            uicontrol( 'Parent', videoInfoBox,'Style','text','FontUnits','normalized','Fontsize',0.5, 'String', 'Time :' ,'Enable','on');
            obj.hButton.TimeLineText = uicontrol( 'Parent', videoInfoBox,'Style','text','FontUnits','normalized','Fontsize',0.5, 'String', '--:--:--/--:--:--' ,'Enable','on');
            set(videoInfoBox, 'Widths', [-2 -1 -1 -1 -2 -1 -1 -2] );
            
            videoControlBox = uix.HBox('Parent', panelDataVBox,'Spacing', 5,'Padding',5);
            obj.hButton.playFrameROI = uicontrol( 'Parent', videoControlBox,'FontUnits','normalized','Fontsize',0.5, 'String', 'Play' ,'Enable','on');
            obj.hButton.sliderFrameROI = uicontrol( 'Parent', videoControlBox,'Style','slider','FontUnits','normalized','Fontsize',0.6, 'String', 'Thresh','Tag','sliderThreshold' ,'Enable','on');
            uix.Empty( 'Parent', videoControlBox );
            set(videoControlBox, 'Widths', [-1 -10 -1] );
            
            set( panelDataVBox, 'Heights', [-25 -1 -1], 'Spacing', 1 );
            
            % 1st Card Panel. Control Panel (right) %%%%%%%%%%%%%%%%%%%%%%%
            
            mainVBoxControl1 = uix.VBox('Parent',obj.panelControl{1},'Spacing', 5,'Padding',5);
            PanelControl1 = uix.Panel('Parent',mainVBoxControl1,'Title','Main controls','FontUnits','normalized','Fontsize',0.06,'Padding',2);
            InfoControl1 = uix.Panel('Parent',mainVBoxControl1,'Title','Data','FontUnits','normalized','Fontsize',0.06,'Padding',2);
            
            %%% Control Elements
            VBoxControlElements = uix.VButtonBox('Parent', PanelControl1,'ButtonSize',[600 600],'Spacing', 0 );
            tempBBox = uix.HButtonBox('Parent', VBoxControlElements,'ButtonSize',[600 60], 'Spacing',0);
            obj.hButton.NewFile = uicontrol( 'Parent', tempBBox,'FontUnits','normalized','Fontsize',0.4, 'String', sprintf('\x2633 New file') );
%             tempBBox = uix.HButtonBox('Parent', VBoxControlElements,'ButtonSize',[600 60], 'Spacing',0);
%             obj.hButton.New = uicontrol( 'Parent', tempBBox,'FontUnits','normalized','Fontsize',0.4, 'String', sprintf('\x2633 New file') );
            tempBBox = uix.HButtonBox('Parent', VBoxControlElements,'ButtonSize',[600 60], 'Spacing',0);
            tempBox = uix.HButtonBox('Parent', tempBBox,'ButtonSize',[600 40],'Padding', 1 );
            uicontrol( 'Parent', tempBox,'Style','text','FontUnits','normalized','Fontsize',0.6, 'HorizontalAlignment','left', 'String', 'Type of ROI:' );
            tempBox = uix.HButtonBox('Parent', tempBBox,'ButtonSize',[600 40],'Padding', 1 );
            obj.hButton.ROISelect = uicontrol( 'Parent', tempBox,'Style','popupmenu','FontUnits','normalized','Fontsize',0.6, 'String', {'Freehand' , 'Circular','Ploygon','Rectangle'} ,'Enable','on');
            
            tempBBox = uix.HButtonBox('Parent', VBoxControlElements,'ButtonSize',[600 60], 'Spacing',0);
            obj.hButton.AddROI = uicontrol( 'Parent', tempBBox,'FontUnits','normalized','Fontsize',0.4, 'String', sprintf('Add ROI') );
            tempBBox = uix.HButtonBox('Parent', VBoxControlElements,'ButtonSize',[600 60], 'Spacing',0);
            obj.hButton.AddRefROI = uicontrol( 'Parent', tempBBox,'FontUnits','normalized','Fontsize',0.4, 'String', sprintf('Add Ref. Region') );
            tempBBox = uix.HButtonBox('Parent', VBoxControlElements,'ButtonSize',[600 60], 'Spacing',0);
            obj.hButton.DeleteROI = uicontrol( 'Parent', tempBBox,'FontUnits','normalized','Fontsize',0.4, 'String', sprintf('Delete all Regions') );
            tempBBox = uix.HButtonBox('Parent', VBoxControlElements,'ButtonSize',[600 60], 'Spacing',0);
            obj.hButton.Analyze = uicontrol( 'Parent', tempBBox,'FontUnits','normalized','Fontsize',0.4, 'String', sprintf('Analyze ROIs') );
            
            
            %%% Meta Data Infos
            VBoxControlInfo1 = uix.VButtonBox('Parent', InfoControl1,'ButtonSize',[600 20],'Spacing', 5 );
            tempBBox = uix.HBox('Parent', VBoxControlInfo1, 'Spacing',5);
            uicontrol( 'Parent', tempBBox,'Style','text','FontUnits','normalized','Fontsize',0.9, 'String', 'Name :' ,'Enable','on');
            obj.hButton.FileNameText = uicontrol( 'Parent', tempBBox,'Style','text','FontUnits','normalized','Fontsize',0.9, 'String', '--' );
            set(tempBBox, 'Widths', [-1 -2] );
            tempBBox = uix.HBox('Parent', VBoxControlInfo1, 'Spacing',0);
            uicontrol( 'Parent', tempBBox,'Style','text','FontUnits','normalized','Fontsize',0.9, 'String', 'Frames :' ,'Enable','on');
            obj.hButton.FrameText = uicontrol( 'Parent', tempBBox,'Style','text','FontUnits','normalized','Fontsize',0.9, 'String', '--' );
            set(tempBBox, 'Widths', [-1 -2] );
            tempBBox = uix.HBox('Parent', VBoxControlInfo1, 'Spacing',0);
            uicontrol( 'Parent', tempBBox,'Style','text','FontUnits','normalized','Fontsize',0.9, 'String', 'FPS :' ,'Enable','on');
            obj.hButton.FPSinfoText = uicontrol( 'Parent', tempBBox,'Style','text','FontUnits','normalized','Fontsize',0.9, 'String', '--' );
            set(tempBBox, 'Widths', [-1 -2] );
            tempBBox = uix.HBox('Parent', VBoxControlInfo1, 'Spacing',0);
            uicontrol( 'Parent', tempBBox,'Style','text','FontUnits','normalized','Fontsize',0.9, 'String', 'Bit Depth :' ,'Enable','on');
            obj.hButton.BitDepthText = uicontrol( 'Parent', tempBBox,'Style','text','FontUnits','normalized','Fontsize',0.9, 'String', '--' );
            set(tempBBox, 'Widths', [-1 -2] );
            tempBBox = uix.HBox('Parent', VBoxControlInfo1, 'Spacing',0);
            uicontrol( 'Parent', tempBBox,'Style','text','FontUnits','normalized','Fontsize',0.9, 'String', 'Frame Size :' ,'Enable','on');
            obj.hButton.FrameSizeText = uicontrol( 'Parent', tempBBox,'Style','text','FontUnits','normalized','Fontsize',0.9, 'String', '--' );
            set(tempBBox, 'Widths', [-1 -2] );
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Create GUI objects for the 2st Card Panel (Analyzer)
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj.panelData{2} = uix.Panel('Parent', mainCardPanels{2},'Title', 'filename', 'FontUnits','normalized','Fontsize',0.03,'Padding',5);
            obj.panelControl{2} = uix.Panel('Parent', mainCardPanels{2},'Title', 'Control Panel' ,'FontUnits','normalized','Fontsize',0.03,'Padding',5);
            set(mainCardPanels{2}, 'MinimumWidths', [1 320] );
            set(mainCardPanels{2}, 'Widths', [-4 -1] );
            
            % 1st Card Panel. Data Panel (left) %%%%%%%%%%%%%%%%%%%%%%%%%%
            panelDataVBox = uix.VBox('Parent',obj.panelData{2},'Spacing', 5,'Padding',5);
            obj.hAxes.videoFrameAnalyze = axes('Parent',uicontainer('Parent', panelDataVBox),'FontUnits','normalized','Fontsize',0.03);
            axis image
            set(obj.hAxes.videoFrameAnalyze, 'LooseInset', [0,0,0,0]);
            
            videoInfoBox = uix.HBox('Parent', panelDataVBox,'Spacing', 5);
            uicontrol( 'Parent', videoInfoBox,'Style','text','FontUnits','normalized','Fontsize',0.5, 'String', 'Play Speed in FPS :' ,'Enable','on');
            obj.hButton.FPSAnalyze = uicontrol( 'Parent', videoInfoBox,'Style','edit','FontUnits','normalized','Fontsize',0.5, 'String', '--' ,'Enable','on');
            uix.Empty( 'Parent', videoInfoBox );
            uicontrol( 'Parent', videoInfoBox,'Style','text','FontUnits','normalized','Fontsize',0.5, 'String', 'Frame :' ,'Enable','on');
            obj.hButton.FrameLineTextAnalyze = uicontrol( 'Parent', videoInfoBox,'Style','text','FontUnits','normalized','Fontsize',0.5, 'String', '--/--' ,'Enable','on');
            uix.Empty( 'Parent', videoInfoBox );
            uicontrol( 'Parent', videoInfoBox,'Style','text','FontUnits','normalized','Fontsize',0.5, 'String', 'Time :' ,'Enable','on');
            obj.hButton.TimeLineTextAnalyze = uicontrol( 'Parent', videoInfoBox,'Style','text','FontUnits','normalized','Fontsize',0.5, 'String', '--:--:--/--:--:--' ,'Enable','on');
            set(videoInfoBox, 'Widths', [-2 -1 -1 -1 -2 -1 -1 -2] );
            
            videoControlBox = uix.HBox('Parent', panelDataVBox,'Spacing', 5,'Padding',5);
            obj.hButton.playFrameAnalyze = uicontrol( 'Parent', videoControlBox,'FontUnits','normalized','Fontsize',0.5, 'String', 'Play' ,'Enable','on');
            obj.hButton.sliderFrameAnalyze = uicontrol( 'Parent', videoControlBox,'Style','slider','FontUnits','normalized','Fontsize',0.6, 'String', 'Thresh','Tag','sliderThreshold' ,'Enable','on');
            uix.Empty( 'Parent', videoControlBox );
            set(videoControlBox, 'Widths', [-1 -10 -1] );
            
            obj.hAxes.cellActivity = axes('Parent',uicontainer('Parent', panelDataVBox),'FontUnits','normalized','Fontsize',0.03);
            axis on
            set(obj.hAxes.videoFrameAnalyze, 'LooseInset', [0,0,0,0]);
            
            
            set( panelDataVBox, 'Heights', [-12 -1 -1 -12], 'Spacing', 1 );
            
            % 1st Card Panel. Control Panel (right) %%%%%%%%%%%%%%%%%%%%%%%
            
            mainVBoxControl1 = uix.VBox('Parent',obj.panelControl{2},'Spacing', 5,'Padding',5);
            PanelControl1 = uix.Panel('Parent',mainVBoxControl1,'Title','Main controls','FontUnits','normalized','Fontsize',0.06,'Padding',2);
            InfoControl1 = uix.Panel('Parent',mainVBoxControl1,'Title','Data','FontUnits','normalized','Fontsize',0.06,'Padding',2);
            
            %%% Control Elements
            VBoxControlElements = uix.VButtonBox('Parent', PanelControl1,'ButtonSize',[600 600],'Spacing', 0 );
            tempBBox = uix.HButtonBox('Parent', VBoxControlElements,'ButtonSize',[600 60], 'Spacing',0);
            obj.hButton.Back = uicontrol( 'Parent', tempBBox,'FontUnits','normalized','Fontsize',0.4, 'String', sprintf('Back Edit') );
            tempBBox = uix.HButtonBox('Parent', VBoxControlElements,'ButtonSize',[600 60], 'Spacing',0);
            obj.hButton.Save = uicontrol( 'Parent', tempBBox,'FontUnits','normalized','Fontsize',0.4, 'String', sprintf('Save') );
            
            tempBBox = uix.HButtonBox('Parent', VBoxControlElements,'ButtonSize',[600 60], 'Spacing',0);
            tempBox = uix.HButtonBox('Parent', tempBBox,'ButtonSize',[600 40],'Padding', 1 );
            uicontrol( 'Parent', tempBox,'Style','text','FontUnits','normalized','Fontsize',0.5, 'HorizontalAlignment','left', 'String', 'Smoothing Method' );
            tempBox = uix.HButtonBox('Parent', tempBBox,'ButtonSize',[600 40],'Padding', 1 );
            obj.hButton.SmoothingMethod = uicontrol( 'Parent', tempBox,'Style','popupmenu','FontUnits','normalized','Fontsize',0.6, 'String', {'no smoothing','moving average'} ,'Enable','on');
            
            tempBBox = uix.HButtonBox('Parent', VBoxControlElements,'ButtonSize',[600 60], 'Spacing',0);
            tempBox = uix.HButtonBox('Parent', tempBBox,'ButtonSize',[600 40],'Padding', 1 );
            uicontrol( 'Parent', tempBox,'Style','text','FontUnits','normalized','Fontsize',0.5, 'HorizontalAlignment','left', 'String', 'Smoothing Span' );
            tempBox = uix.HButtonBox('Parent', tempBBox,'ButtonSize',[600 40],'Padding', 1 );
            obj.hButton.SmoothingSpan = uicontrol( 'Parent', tempBox,'Style','edit','FontUnits','normalized','Fontsize',0.5, 'String', '2','Enable','on');
            
            
%             tempBBox = uix.HButtonBox('Parent', VBoxControlElements,'ButtonSize',[600 60], 'Spacing',0);
%             obj.hButton.AddROI = uicontrol( 'Parent', tempBBox,'FontUnits','normalized','Fontsize',0.4, 'String', sprintf('Add ROI') );
%             tempBBox = uix.HButtonBox('Parent', VBoxControlElements,'ButtonSize',[600 60], 'Spacing',0);
%             obj.hButton.DeleteROI = uicontrol( 'Parent', tempBBox,'FontUnits','normalized','Fontsize',0.4, 'String', sprintf('Delete all ROIs') );
%             tempBBox = uix.HButtonBox('Parent', VBoxControlElements,'ButtonSize',[600 60], 'Spacing',0);
%             obj.hButton.Analyze = uicontrol( 'Parent', tempBBox,'FontUnits','normalized','Fontsize',0.4, 'String', sprintf('Analyze ROIs') );

            obj.hButton.TableCellSelect = uitable('Parent',InfoControl1);
            obj.hButton.TableCellSelect.Units = 'normalized';
            obj.hButton.TableCellSelect.Position =[0 0 1 1];
        end
    end
    
    
end