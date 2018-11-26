classdef controllerCellAnalyzer < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hFigure;
        hView;
        hModel;
    end
    
    methods
        function obj = controllerCellAnalyzer(hFigure,hView,hModel)
            obj.hFigure = hFigure;
            obj.hView = hView;
            obj.hModel = hModel;
            
            obj.addCallbacks();
        end
        
        function addCallbacks(obj)
            set(obj.hView.hButton.NewFile ,'Callback',@obj.newFileEvent);
            set(obj.hView.hButton.AddROI ,'Callback',@obj.addROIEvent);
            set(obj.hView.hButton.AddRefROI ,'Callback',@obj.addRefROIEvent);
            set(obj.hView.hButton.Analyze ,'Callback',@obj.startAnalyzeEvent);
            set(obj.hView.hButton.DeleteROI ,'Callback',@obj.deleteAllROIs);
            
            set(obj.hView.hButton.playFrameROI ,'Callback',@obj.playVideoEvent);
            set(obj.hView.hButton.playFrameAnalyze ,'Callback',@obj.playVideoEvent);
            
            set(obj.hView.hButton.SmoothingMethod,'Callback',@obj.smoothDataEvent);
            set(obj.hView.hButton.SmoothingSpan,'Callback',@obj.smoothDataEvent);
            
            
            addlistener(obj.hView.hButton.sliderFrameROI, 'ContinuousValueChange',@obj.sliderVideoEvent);
            addlistener(obj.hView.hButton.sliderFrameAnalyze, 'ContinuousValueChange',@obj.sliderVideoEvent);
            
            
            set(obj.hView.hButton.Back ,'Callback',@obj.backEvent);
        end
        
        function newFileEvent(obj,src,evnt)
            tempFileNames = [];
            tempPathNames = [];
            tempFileNamesStimu = [];
            tempPathNamesStimu = [];
            
            [tempFileNames,tempPathNames] = uigetfile({'*.*'},'Select new Frame file','MultiSelect', 'off');
            
            if ~isnumeric(tempFileNames)
                
                %If new File was selected the user can add a second file
                %containing the stimulation signal.
                [tempFileNamesStimu,tempPathNamesStimu] = uigetfile({'*.*'},'Select Stimulation Signal file','MultiSelect', 'off',tempPathNames);
                
                %Save File and Paht Names in Model
                obj.hModel.Data.FileName = tempFileNames;
                obj.hModel.Data.PathName = tempPathNames;
                
                if isnumeric(tempFileNamesStimu)
                    %Cancle Butten was selected. No file slelcted
                    obj.hModel.Data.FileNameStimu = [];
                    obj.hModel.Data.PathNameStimu = [];
                else
                    obj.hModel.Data.FileNameStimu = tempFileNamesStimu;
                    obj.hModel.Data.PathNameStimu = tempPathNamesStimu;
                end
                
                obj.hModel.openFile();
                
                %Set First Frame in GUI
                
                axes(obj.hView.hAxes.videoFrameROI)
                obj.hModel.Data.HandleFrameROI = imshow(obj.hModel.Data.FramesStable{1},[0 2^obj.hModel.Data.BitDepth]);
                axis on
                colorbar(obj.hView.hAxes.videoFrameROI);
                
                %Set Values for Button objects in GUI
                set(obj.hView.hButton.sliderFrameROI, 'Min', 1);
                set(obj.hView.hButton.sliderFrameROI, 'Max',  obj.hModel.Data.NoFrames);
                set(obj.hView.hButton.sliderFrameROI, 'Value', 1);
                set(obj.hView.hButton.sliderFrameROI, 'SliderStep', [1/(obj.hModel.Data.NoFrames-1) , 1/(obj.hModel.Data.NoFrames-1) ]);
                
                set(obj.hView.hButton.sliderFrameAnalyze, 'Min', 1);
                set(obj.hView.hButton.sliderFrameAnalyze, 'Max',  obj.hModel.Data.NoFrames);
                set(obj.hView.hButton.sliderFrameAnalyze, 'Value', 1);
                set(obj.hView.hButton.sliderFrameAnalyze, 'SliderStep', [1/(obj.hModel.Data.NoFrames-1) , 1/(obj.hModel.Data.NoFrames-1) ]);
                
                set(obj.hView.hButton.FPS,'String',num2str(obj.hModel.Data.FPS));
                set(obj.hView.hButton.FPSAnalyze,'String',num2str(obj.hModel.Data.FPS));
                
                set(obj.hView.hButton.FrameLineText,'String',[num2str(obj.hModel.Data.CurrentFrame) '/' num2str(obj.hModel.Data.NoFrames)]);
                set(obj.hView.hButton.TimeLineText,'String',[obj.hModel.Data.CurVideoLength '/' obj.hModel.Data.VideoLength]);
                
                set(obj.hView.hButton.FrameLineTextAnalyze,'String',[num2str(obj.hModel.Data.CurrentFrame) '/' num2str(obj.hModel.Data.NoFrames)]);
                set(obj.hView.hButton.TimeLineTextAnalyze,'String',[obj.hModel.Data.CurVideoLength '/' obj.hModel.Data.VideoLength]);
                
                set(obj.hView.hButton.FileNameText,'String',obj.hModel.Data.FileName );
                set(obj.hView.hButton.FrameText,'String',obj.hModel.Data.NoFrames);
                set(obj.hView.hButton.FPSinfoText,'String',obj.hModel.Data.FPS );
                set(obj.hView.hButton.BitDepthText,'String',obj.hModel.Data.BitDepth );
                set(obj.hView.hButton.FrameSizeText,'String',obj.hModel.Data.FrameSize );
                
            else
                %Cancle Butten was selected. No file slelcted
                obj.hModel.Data.FileName = [];
                obj.hModel.Data.PathName = [];
            end
        end
        
        function playVideoEvent(obj,src,event)
          
            switch obj.hModel.AppState.ActivePanel
                
                case 1 %Player for ROI slection
                    PlayFPS = str2num(obj.hView.hButton.FPS.String);
                    PlaySpeed = 1/(PlayFPS);
                    PlaySpeed = round(PlaySpeed*1000)/1000; % Round to ms
                    
                    if strcmp( obj.hModel.AppState.Timer.Running,'off')
                        obj.hModel.AppState.Timer.Period = PlaySpeed;
                        obj.hModel.AppState.Timer.TimerFcn = @obj.playVideo;
                        start(obj.hModel.AppState.Timer)
                        set(obj.hView.hButton.playFrameROI,'String','Pause')
                    else
                        stop(obj.hModel.AppState.Timer)
                        set(obj.hView.hButton.playFrameROI,'String','Play')
                    end
                    
                    obj.updatePlayerInfo();
                    
                case 2 %Player for Cell Activity measurment
                    
                    PlayFPS = str2num(obj.hView.hButton.FPSAnalyze.String);
                    PlaySpeed = 1/(PlayFPS);
                    PlaySpeed = round(PlaySpeed*1000)/1000; % Round to ms
                    
                    if strcmp( obj.hModel.AppState.Timer.Running,'off')
                        obj.hModel.AppState.Timer.Period = PlaySpeed;
                        obj.hModel.AppState.Timer.TimerFcn = @obj.playVideo;
                        start(obj.hModel.AppState.Timer)
                        set(obj.hView.hButton.playFrameAnalyze,'String','Pause')
                    else
                        stop(obj.hModel.AppState.Timer)
                        set(obj.hView.hButton.playFrameAnalyze,'String','Play')
                    end
                    
            end
        end
        
        function playVideo(obj,src,evnt)
            
            switch obj.hModel.AppState.ActivePanel
                
                case 1 %Player for ROI slection
                    NoFrames = obj.hModel.Data.NoFrames;
                    CurFrame = obj.hModel.Data.CurrentFrame;
                    
                    if CurFrame < NoFrames
                        obj.hModel.Data.HandleFrameROI.CData = obj.hModel.Data.FramesStable{CurFrame};
                        obj.hModel.Data.CurrentFrame = obj.hModel.Data.CurrentFrame + 1;
                        set(obj.hView.hButton.sliderFrameROI,'Value',obj.hModel.Data.CurrentFrame);
                        obj.updatePlayerInfo();
                    else
                        obj.updatePlayerInfo();
                        obj.hModel.Data.CurrentFrame = 1;
                        stop(obj.hModel.AppState.Timer)
                        set(obj.hView.hButton.playFrameROI,'String','Play')
                        %               delete(obj.hModel.Data.Timer)
                    end
                    
                case 2 %Player for Cell Activity measurment
                    NoFrames = obj.hModel.Data.NoFrames;
                    CurFrame = obj.hModel.CellData.CurrentFrame;
                    
                    if CurFrame < NoFrames
                        obj.hModel.CellData.HandleFrameAnalyzed.CData = obj.hModel.Data.FramesStable{CurFrame};
                        obj.hModel.CellData.CurrentFrame = obj.hModel.CellData.CurrentFrame + 1;
                        set(obj.hView.hButton.sliderFrameAnalyze,'Value',obj.hModel.CellData.CurrentFrame);
                        obj.updatePlayerInfo();
                    else
                        obj.updatePlayerInfo();
                        obj.hModel.CellData.CurrentFrame = 1;
                        stop(obj.hModel.AppState.Timer)
                        set(obj.hView.hButton.playFrameAnalyze,'String','Play')
                        %               delete(obj.hModel.Data.Timer)
                    end
                    
            end
            
        end
        
        function sliderVideoEvent(obj,src,evnt)
            
            switch obj.hModel.AppState.ActivePanel
                case 1
                    stop(obj.hModel.AppState.Timer)
                    %             delete(obj.hModel.Data.Timer)
                    set(obj.hView.hButton.playFrameROI,'String','Play')
                    set(obj.hView.hButton.playFrameAnalyze,'String','Play')
                    obj.hModel.Data.CurrentFrame = round(src.Value);
                    CurFrame = obj.hModel.Data.CurrentFrame;
                    set(obj.hView.hButton.sliderFrameROI, 'Value', CurFrame);
                    obj.hModel.Data.HandleFrameROI.CData = obj.hModel.Data.FramesOrigin{CurFrame};
                case 2
                    stop(obj.hModel.AppState.Timer)
                    %             delete(obj.hModel.Data.Timer)
                    set(obj.hView.hButton.playFrameROI,'String','Play')
                    set(obj.hView.hButton.playFrameAnalyze,'String','Play')
                    obj.hModel.CellData.CurrentFrame = round(src.Value);
                    CurFrame = obj.hModel.CellData.CurrentFrame;
                    set(obj.hView.hButton.sliderFrameAnalyze, 'Value', CurFrame);
                    obj.hModel.CellData.HandleFrameAnalyzed.CData = obj.hModel.Data.FramesOrigin{CurFrame};
                    
            end
            obj.updatePlayerInfo();
        end
        
        function addROIEvent(obj,src,evnt)
            switch obj.hView.hButton.ROISelect.Value
                case 1
                    h = imfreehand(obj.hView.hAxes.videoFrameROI,'closed',1);
                case 2
                    h = imellipse(obj.hView.hAxes.videoFrameROI);
                case 3
                    h = impoly(obj.hView.hAxes.videoFrameROI);
                case 4
                    h = imrect(obj.hView.hAxes.videoFrameROI);
            end
            
            if size(h,1) ~= 0
                obj.hModel.Data.ROI{end+1} = h;
            end
        end
        
        function addRefROIEvent(obj,src,evnt)
            switch obj.hView.hButton.ROISelect.Value
                case 1
                    h = imfreehand(obj.hView.hAxes.videoFrameROI,'closed',1);
                    setColor(h,'red');
                case 2
                    h = imellipse(obj.hView.hAxes.videoFrameROI);
                    setColor(h,'red');
                case 3
                    h = impoly(obj.hView.hAxes.videoFrameROI);
                    setColor(h,'red');
                case 4
                    h = imrect(obj.hView.hAxes.videoFrameROI);
                    setColor(h,'red');
            end
            
            if size(h,1) ~= 0
                obj.hModel.Data.RefROI{end+1} = h;
            end
        end
        
        function deleteAllROIs(obj,src,evnt)
            
            if size(obj.hModel.Data.ROI,2)>0
                for i=1:size(obj.hModel.Data.ROI,2)
                    delete(obj.hModel.Data.ROI{1,i});
                end
                obj.hModel.Data.ROI=[];
            end
            
            if size(obj.hModel.Data.RefROI,2)>0
                for i=1:size(obj.hModel.Data.RefROI,2)
                    delete(obj.hModel.Data.RefROI{1,i});
                end
                obj.hModel.Data.RefROI=[];
            end
        end
        
        function startAnalyzeEvent(obj,src,evnt)
            
            if ~isempty(obj.hModel.Data.ROI)
                %ROIs are definde. Switch to Analyze Mode
                stop(obj.hModel.AppState.Timer)
                obj.hView.mainCard.Selection = 2;
                obj.hModel.AppState.ActivePanel = 2;
                
                % Calculate mean Intensity of all Cells in each Frame
                obj.hModel.startAnalyze();
                
                
                obj.updateCellOptionsTable();
                
                %Display video Frame with ROIs
                obj.updateROIbounds();
                
                obj.smoothDataEvent();
                
                obj.updateIntensPlot();
%                 set(jtable,'CellEditCallback',@obj.tableValueEvent);
%                 set(jtable,'CellSelectionCallback',@obj.tableValueEvent);
%                 jtable.repaint;
%                 figure
%                 data = {true,'a','22,34,145';...
%                         0,'d','200,0,0'}
%                     cols = {'Type','Dish','Color'}; 
%                 mtable = uitable(gcf,'Data',data,'ColumnName',cols); 
%                 mtable.ColumnEditable = true(1,2);
% %                 cr = java.swing.table.DefaultCellRenderer;
%                 path = [pwd '/Functions and Toolboxes/ColorCell'];
%                 javaaddpath(path);
%                 jscroll = findjobj(mtable);
%                 jtable = jscroll.getViewport.getView;
%                 jtable.setModel(javax.swing.table.DefaultTableModel(data,cols));
%                 jtable.getColumnModel.getColumn(2).setCellRenderer(ColorCellRenderer);
%                 jtable.getColumnModel.getColumn(2).setCellEditor(ColorCellEditor);
%                 jtable.repaint;
% %                 set(jtable,'CellEditCallback','disp(''DataChanged'')');
%                 set(jtable.getModel,'TableChangedCallback','disp(''DataChanged'')');
%                 
%                 %Get Value at Row Column
% %                 jColor = jtable.getModel().getValueAt(2, 2);
% %                   matlabData = jColor.getColorComponents([]);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Plot Data in Axes
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               
                
            else
                
            end
               
        end
        
        function backEvent(obj,src,evnt)
            %stop video player
            stop(obj.hModel.AppState.Timer);
            
            obj.hView.mainCard.Selection = 1;
            obj.hModel.AppState.ActivePanel = 1;
            
%             cla(obj.hView.hAxes.videoFrameAnalyze);
            
%             obj.hView.hButton.TableCellSelect.Data = '';
        end
        
        function updatePlayerInfo(obj)
            switch obj.hModel.AppState.ActivePanel
                
                case 1
                    %Update Video Player information
                    VideoLength = (obj.hModel.Data.CurrentFrame-1)/obj.hModel.Data.FPS;
                    [hh, mm, ss] = secs2hms(VideoLength);
                    obj.hModel.Data.CurVideoLength = [hh ':' mm ':' ss];
                    set(obj.hView.hButton.FrameLineText,'String',[num2str(obj.hModel.Data.CurrentFrame) '/' num2str(obj.hModel.Data.NoFrames)]);
                    set(obj.hView.hButton.TimeLineText,'String',[obj.hModel.Data.CurVideoLength '/' obj.hModel.Data.VideoLength]);
                    
                case 2
                    
                    VideoLength = (obj.hModel.CellData.CurrentFrame-1)/obj.hModel.Data.FPS;
                    [hh, mm, ss] = secs2hms(VideoLength);
                    obj.hModel.CellData.CurVideoLength = [hh ':' mm ':' ss];
                    set(obj.hView.hButton.FrameLineTextAnalyze,'String',[num2str(obj.hModel.CellData.CurrentFrame) '/' num2str(obj.hModel.Data.NoFrames)]);
                    set(obj.hView.hButton.TimeLineTextAnalyze,'String',[obj.hModel.CellData.CurVideoLength '/' obj.hModel.Data.VideoLength]);
                    
                    h = findobj('Tag','CellPlotCurrentFrameLine');
                    h.XData = [obj.hModel.CellData.CurrentFrame obj.hModel.CellData.CurrentFrame];
            end
        end
        
        function tableValueEvent(obj,src,evnt)

            Col = src.TableChangedCallbackData.getColumn;
            Row = src.TableChangedCallbackData.getFirstRow;
            
            switch Col
                case 1 %Togle Active button has changed
                    
                case 2 %Color has Changed
                    
                jscroll = findjobj(obj.hView.hButton.TableCellSelect);
                jtable = jscroll.getViewport.getView;
                jColor = jtable.getModel().getValueAt(Row, Col);
                matlabColor = [jColor.getRed jColor.getGreen jColor.getBlue]/255;
                
                hBound = findobj('Tag',['boundLabel ' num2str(Row-1)]);
                hText = findobj('Tag',['boundText ' num2str(Row-1)]);
                
                set(hBound,'Color',matlabColor);
                set(hText,'Color',matlabColor);
                
                
                case 3 %---
                
                otherwise
                
            end
            
            obj.updateIntensPlot();
            
            
        end
        
        function smoothDataEvent(obj,src,evnt)
            method=obj.hView.hButton.SmoothingMethod.Value;
            spanStr = obj.hView.hButton.SmoothingSpan.String;
            span = str2double(spanStr);
            
            methodString =obj.hView.hButton.SmoothingMethod.String{method};

            obj.hModel.smoothData(methodString,span);
            
            obj.updateIntensPlot();
        end
        
        function updateCellOptionsTable(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Create Tabel for ROI selection
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                NoColor = size(obj.hModel.CellData.ColorOrder,1);
                ColOrd = obj.hModel.CellData.ColorOrder*255;
                
                cols = {'Object','Active','Color'};
                j=1;
                
%                 if size(obj.hModel.CellData.TableCellOptions,1) == 0 || ...
%                         size(obj.hModel.CellData.TableCellOptions,1) > obj.hModel.CellData.NoCells
                    %No ROIs in Table or Table is greater than number of
                    %ROIs. Create new Table
                    obj.hModel.CellData.TableCellOptions = {}; %Clear Table
                    
                    %add Stimulation and Refernce Signal
                    obj.hModel.CellData.TableCellOptions{1,1} = ['Stimulation'];
                    obj.hModel.CellData.TableCellOptions{1,2} = true;
                    JavCol = java.awt.Color(ColOrd(j,1)/255,ColOrd(j,2)/255,ColOrd(j,3)/255);
                    obj.hModel.CellData.TableCellOptions{1,3} = JavCol;
                    
                    j=2;
                    
                    obj.hModel.CellData.TableCellOptions{2,1} = ['Background'];
                    obj.hModel.CellData.TableCellOptions{2,2} = true;
                    JavCol = java.awt.Color(ColOrd(j,1)/255,ColOrd(j,2)/255,ColOrd(j,3)/255);
                    obj.hModel.CellData.TableCellOptions{2,3} = JavCol;
                    
                    j=3;
                    for i=1:1:obj.hModel.CellData.NoCells
                        if j ==  NoColor
                            j=1;
                        end
                            obj.hModel.CellData.TableCellOptions{i+2,1} = ['Cell ' num2str(i)];
                            obj.hModel.CellData.TableCellOptions{i+2,2} = true;
                            
                            %COnvert RGB to Java Color
                            JavCol = java.awt.Color(ColOrd(j,1)/255,ColOrd(j,2)/255,ColOrd(j,3)/255);
                            %                     data{i,2} = [num2str(ColOrd(j,1)) ',' num2str(ColOrd(j,2)) ',' num2str(ColOrd(j,3))];
                            obj.hModel.CellData.TableCellOptions{i+2,3} = JavCol;
                            j=j+1;
                      
                    end
                    
%                 elseif size(obj.hModel.CellData.TableCellOptions,1) < obj.hModel.CellData.NoCells
%                     %Add new RIOs at the End of the Table
%                     for i=size(obj.hModel.CellData.TableCellOptions,1):1:obj.hModel.CellData.NoCells
%                         if j ==  NoColor
%                             j=1;
%                         end
%                         
%                         obj.hModel.CellData.TableCellOptions{i,1} = true;
%                         
%                         %COnvert RGB to Java Color
%                         JavCol = java.awt.Color(ColOrd(j,1)/255,ColOrd(j,2)/255,ColOrd(j,3)/255);
%                         %                     data{i,2} = [num2str(ColOrd(j,1)) ',' num2str(ColOrd(j,2)) ',' num2str(ColOrd(j,3))];
%                         obj.hModel.CellData.TableCellOptions{i,2} = JavCol;
%                         j=j+1;
%                     end
%                 end
                
%                 obj.hView.hButton.TableCellSelect.Data = data;
                obj.hView.hButton.TableCellSelect.ColumnName = cols;
                obj.hView.hButton.TableCellSelect.ColumnEditable = true;
                obj.hView.hButton.TableCellSelect.ColumnFormat = {'char','logical',''};
                
                path = [pwd '/Functions and Toolboxes/ColorCell'];
                javaaddpath(path);
                jscroll = findjobj(obj.hView.hButton.TableCellSelect);
                jtable = jscroll.getViewport.getView;
                jtable.setModel(javax.swing.table.DefaultTableModel(obj.hModel.CellData.TableCellOptions,cols));
                jtable.getColumnModel.getColumn(2).setCellRenderer(ColorCellRenderer);
                jtable.getColumnModel.getColumn(2).setCellEditor(ColorCellEditor);
                jtable.repaint;
%                 set(handle(jtable.getSelectionModel,'CallbackProperties'), 'ValueChangedCallback', {@obj.tableValueEvent, jtable});
%                 set(obj.hView.hButton.TableCellSelect,'CellSelectionCallback',{@obj.tableValueEvent,jtable});
%                 set(jscroll,'MouseClickedCallback',@obj.tableValueEvent);
%                 set(jtable,'MouseClickedCallback',@obj.tableValueEvent);

                %Set Java Callback of Table 
                set(jtable.getModel,'TableChangedCallback',@obj.tableValueEvent);
        end
        
        function updateROIbounds(obj)
            axes(obj.hView.hAxes.videoFrameAnalyze)
            obj.hModel.CellData.HandleFrameAnalyzed = imshow(obj.hModel.Data.FramesOrigin{obj.hModel.CellData.CurrentFrame},[0 2^obj.hModel.Data.BitDepth]);
            %             axis image
            axis on
            colorbar(obj.hView.hAxes.videoFrameAnalyze);
            hold on
            

            %Plot Cell Bounds
            for i=1:1:size(obj.hModel.Data.ROI,2) %Number of ROI
                hold on
                %Get Color from Table
                jscroll = findjobj(obj.hView.hButton.TableCellSelect);
                jtable = jscroll.getViewport.getView;
                jColor = jtable.getModel().getValueAt(i+1, 2);
                Color = [jColor.getRed jColor.getGreen jColor.getBlue]/255;
                
                %                     obj.hModel.CellData.Handle2Boundaries{i} = visboundaries(obj.hModel.CellData.Boundaries{1,1});
                c = obj.hModel.CellData.Stats(i).Centroid;
                axes(obj.hView.hAxes.videoFrameAnalyze);
                htemp = line(obj.hModel.CellData.Boundaries{1,i}{1,1}(:,2),obj.hModel.CellData.Boundaries{1,i}{1,1}(:,1),'Color',Color,'LineWidth',1.5);
                htext = text(c(1),c(2),num2str(i),'Color',Color,'FontSize',16);
                set(htemp,'Tag',['boundLabel ' num2str(i)]);
                set(htemp,'HitTest','off');
                set(htext,'Tag',['boundText ' num2str(i)]);
                set(htext,'HitTest','off');
                obj.hModel.CellData.Handle2Boundaries{i} = htemp;
                
            end
        end
        
        function updateIntensPlot(obj)
             ActivatePlayer = false;
            if strcmp( obj.hModel.AppState.Timer.Running,'on')
                ActivatePlayer = true;
                stop(obj.hModel.AppState.Timer);
            end
            
            axes(obj.hView.hAxes.cellActivity)
            cla(obj.hView.hAxes.cellActivity)
            Intesities =  obj.hModel.CellData.IntensitiesSmoothed;
            Stimu = obj.hModel.CellData.StimulationSignal;
            Background = obj.hModel.CellData.BackgroundSignal;
            
%             %Plot Stimu and Background Ref Signal
%             Active = jtable.getModel().getValueAt(0, 1);
%             if Active
%                 h = plot(Intesities(i,:),'Color',matlabData);
%                 set(h,'Tag',['CellLinePlot ' num2str(i)]);
%                 set(h,'HitTest','on');
%             end
%             hold on
            
            offSet = 2; %For Ref and Stimu Signal
            
            for i=(1):(obj.hModel.CellData.NoCells+offSet)
                %Get current Cell Color from Table
                jscroll = findjobj(obj.hView.hButton.TableCellSelect);
                jtable = jscroll.getViewport.getView;
                jColor = jtable.getModel().getValueAt(i-1, 2);
                Active = jtable.getModel().getValueAt(i-1, 1);
                matlabData = jColor.getColorComponents([]);
                
                if Active && i<= offSet %Plot Stimu and Background Signal
                    switch i
                        case 1 %Stimu
                            h = plot(Stimu,'Color',matlabData);
                            set(h,'Tag',['Stimulation']);
                            set(h,'HitTest','on');
                        case 2 %Background
                            if ~isempty(Background)
                                h = plot(Background,'Color',matlabData);
                                set(h,'Tag',['Background']);
                                set(h,'HitTest','on')
                            end
                    end
 
                elseif Active %Plot Cell Signal
                    h = plot(Intesities(i-offSet,:),'Color',matlabData);
                    set(h,'Tag',['CellLinePlot ' num2str(i-offSet)]);
                    set(h,'HitTest','on');
                end
                hold on
                
            end
            cf = obj.hModel.CellData.CurrentFrame;
            maxValue = max(max(Intesities));
            h = plot([cf cf],[0 maxValue*20],'--r'); %senkrechte gerade
            set(h,'Tag',['CellPlotCurrentFrameLine']);
            set(h,'HitTest','on');
            ylim([0 ceil(maxValue/100)*100])
            
            grid on
            
            if ActivatePlayer
                start(obj.hModel.AppState.Timer);
            end
        end
        
    end
    
end

