classdef modelCellAnalyzer < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Data;
        CellData;
        AppState;
        hController;
    end
    
    methods
        
        function obj =  modelCellAnalyzer()
            obj.Data.FileName = [];
            obj.Data.PathName = [];
            obj.Data.FileNameStimu = [];
            obj.Data.PathNameStimu = [];
            obj.Data.FramesOrigin = [];
            obj.Data.StimuFrames = [];
            obj.Data.FrameSize = [];
            obj.Data.NoFrames = [];
            obj.Data.CurrentFrame = [];
            obj.Data.FPS = [];
            obj.Data.BitDepth = [];
            obj.Data.VideoLength = [];
            obj.Data.CurVideoLength = [];
            obj.Data.ROI = [];
            obj.Data.RefROI = []; %Background of Frames
            obj.Data.HandleFrameROI = []; 
            
            obj.CellData.NoCells = [];
            obj.CellData.Mask = [];
            obj.CellData.RefMask = []; %Background
            obj.CellData.Labels = [];
            obj.CellData.Boundaries = [];
            obj.CellData.Handle2Boundaries = [];
            obj.CellData.CurrentFrame = 1;
            obj.CellData.CurVideoLength = [];
            obj.CellData.Stats = [];
            obj.CellData.Intensities = [];
            obj.CellData.StimulationSignal = [];
            obj.CellData.BackgroundSignal = [];
            obj.CellData.HandleFrameAnalyzed = [];
            obj.CellData.TableCellOptions = {};
            obj.CellData.ColorOrder = [      0    0.4470    0.7410;...
                                        0.8500    0.3250    0.0980;...
                                        0.9290    0.6940    0.1250;...
                                        0.4940    0.1840    0.5560;...
                                        0.4660    0.6740    0.1880;...
                                        0.3010    0.7450    0.9330;...
                                        0.6350    0.0780    0.1840];
            
            obj.AppState.Timer = [];
            obj.AppState.ActivePanel = 1;
            
        end
        
        function openFile(obj,src,evnt)
            obj.clearAllData()
            %Open bioformat file
            data = bfopen([obj.Data.PathName obj.Data.FileName]);
            reader = bfGetReader([obj.Data.PathName obj.Data.FileName]);
            
            %Number of Series in file
            seriesCount = size(data, 1);
            series1 = data{1, 1};
            series1_planeCount = size(series1, 1);
            series1_label1 = series1{1, 2};
            %get meta Data
            metadata = data{1, 2};
            %The OME metadata is always stored the same way, regardless of input file format.
            omeMeta = data{1, 4};
            
            metadata = data{1, 2};
            subject = metadata.get('Subject');
            title = metadata.get('Title');
            
            metadataKeys = metadata.keySet().iterator();
            for i=1:metadata.size()
                key = metadataKeys.nextElement();
                value = metadata.get(key);
                MetaData{i,1}=sprintf('%s', key);
                MetaData{i,2}=sprintf('%s', value);
            end
            Parameters = {MetaData{:,1}};
            Parameters = regexprep(Parameters, '\W', '');
            Values = {MetaData{:,2}};
            MetaData = cell2struct(MetaData, Parameters, 1);
            
            obj.Data.FramesOrigin = {series1{:,1}};
            obj.Data.FrameSize = size(obj.Data.FramesOrigin{1});
            obj.Data.NoFrames = size(obj.Data.FramesOrigin,2);
            obj.Data.CurrentFrame = 1;
            try
                obj.Data.FPS = str2num(MetaData(2).GlobalstateacqframeRate);
            catch
                obj.Data.FPS = 1;
            end
            
            try
                obj.Data.BitDepth = str2num(MetaData(2).GlobalstateacqinputBitDepth);
            catch
                obj.Data.BitDepth = 12;
            end
            
            VideoLength = (obj.Data.NoFrames-1)/obj.Data.FPS;
            [hh, mm, ss] = secs2hms(VideoLength);
            obj.Data.VideoLength = [hh ':' mm ':' ss];
            
            VideoLength = (obj.Data.CurrentFrame-1)/obj.Data.FPS;
            [hh, mm, ss] = secs2hms(VideoLength);
            obj.Data.CurVideoLength = [hh ':' mm ':' ss];
            obj.CellData.CurVideoLength = [hh ':' mm ':' ss];
            
% %             obj.frameStabilisation();
            
            %Open File for Stimulation Signal
            if ~isempty(obj.Data.FileNameStimu)
            data = bfopen([obj.Data.PathNameStimu obj.Data.FileNameStimu]);
            reader = bfGetReader([obj.Data.PathNameStimu obj.Data.FileNameStimu]);
            
            %Number of Series in file
            seriesCount = size(data, 1);
            series1 = data{1, 1};
            series1_planeCount = size(series1, 1);
            series1_label1 = series1{1, 2};
            %get meta Data
            metadata = data{1, 2};
            %The OME metadata is always stored the same way, regardless of input file format.
            omeMeta = data{1, 4};
            
            
            obj.Data.StimuFrames = {series1{:,1}};
            else 
                obj.Data.StimuFrames = cell(1,obj.Data.NoFrames);
                [obj.Data.StimuFrames{:}] = deal(zeros(size(obj.Data.FramesOrigin{1})));
            end
            

            obj.AppState.Timer = timer('Period',1/obj.Data.FPS,... %period
                  'ExecutionMode','fixedRate',... %{singleShot,fixedRate,fixedSpacing,fixedDelay}
                  'BusyMode','drop',... %{drop, error, queue}
                  'TasksToExecute',inf,...
                  'StartDelay',0,...
                  'TimerFcn',{},...
                  'StartFcn',[],...
                  'StopFcn',[],...
                  'ErrorFcn',[]);
        end
        
        function startAnalyze(obj)
            
            % Create Binary Mask and Label Matrix
            obj.createMaskFromROIs();
            
            % Calculate mean Intesities for all Cells and Frames
            obj.getCellProperties();

        end
        
        function createMaskFromROIs(obj)
            
                obj.CellData.NoCells = [];
                obj.CellData.Mask = [];
                obj.CellData.Labels = [];
                obj.CellData.Boundaries = [];
                obj.CellData.Handle2Boundaries = [];
            
                idxOK = find(isvalid([obj.Data.ROI{:}]));
                idxNotOK = find(~isvalid([obj.Data.ROI{:}]));
                obj.Data.ROI(idxNotOK) = [];
                
            if ~isempty(idxOK)
                
                NoROI = size(obj.Data.ROI,2);
                
                Mask = logical(zeros(size(obj.Data.FramesOrigin{1,1})));
                
                for i=1:1:NoROI
                    tempMask = createMask(obj.Data.ROI{1,i});
                    Mask(tempMask)=1;
                end
                
                %Create Label and Boundarie Mat
                [Bounds Label] = bwboundaries(Mask,8,'noholes');
                
                obj.CellData.NoCells = NoROI;
                obj.CellData.Mask = Mask;
                obj.CellData.Labels = Label;
                obj.CellData.Boundaries = Bounds;
                
                
            else %No ROIs selected
            end
            
            %Create Mask for Referece Background
            if ~isempty(obj.Data.RefROI)
                idxOK = find(isvalid([obj.Data.RefROI{:}]));
                idxNotOK = find(~isvalid([obj.Data.RefROI{:}]));

            obj.Data.RefROI(idxNotOK) = [];
            
            NoROI = size(obj.Data.RefROI,2);
                
                Mask = logical( zeros(size(obj.Data.FramesOrigin{1,1})));
                if ~isempty(NoROI)
                    for i=1:1:NoROI
                        tempMask = createMask(obj.Data.RefROI{1,i});
                        Mask(tempMask)=1;
                    end
                    obj.CellData.RefMask = Mask; 
                else
                    obj.CellData.RefMask = [];
                end
            else
                 obj.CellData.RefMask = [];
            end
               
        end
        
        function getCellProperties(obj)
            
            
            for i=1:1:obj.Data.NoFrames
                %Get Stimulation Signal
                obj.CellData.StimulationSignal(i) = max(max(obj.Data.StimuFrames{i}));
                
                %Get Background Signal
                if ~isempty(obj.CellData.RefMask)
                    obj.CellData.BackgroundSignal(i) = mean(obj.Data.FramesOrigin{i}(obj.CellData.RefMask==1));
                else
                    obj.CellData.BackgroundSignal = [];
                end
                
                %Get Cell Signal
                tempStruct = regionprops('struct',obj.CellData.Labels,obj.Data.FramesOrigin{i},'MeanIntensity','Centroid');
                tempMat(:,i) = [tempStruct.MeanIntensity];
                %                 [obj.CellData.Stats(:).meanIntensity] = deal(meanIntens.MeanIntensity);
            end
            obj.CellData.Intensities = tempMat;
            obj.CellData.Stats = tempStruct;
            
        end
        
        function frameStabilisation(obj)
            obj.Data.FramesStable = [];
            obj.Data.FramesStable{1} = obj.Data.FramesOrigin{1};
            for i=2:1:obj.Data.NoFrames
                percent =   (i)/obj.Data.NoFrames;
                workbar(percent,'Please Wait...stabilization of video frames','Frame Stabilization',obj.hController.hFigure);
                
                NoOfMatches = 0; %Numer of Mathcing Points between two frames
                ptThresh = 0.01;
                Search = true;
                Searchiteration = 0;
                while(NoOfMatches < 1 && Search)
                    
                    pointsA = detectBRISKFeatures(obj.Data.FramesOrigin{i-1},'MinContrast',0.1);
                    pointsB = detectBRISKFeatures(obj.Data.FramesOrigin{i},'MinContrast',0.1);
                    
                    figure; showMatchedFeatures(obj.Data.FramesOrigin{i-1}, obj.Data.FramesOrigin{i}, pointsA, pointsB);
                    legend('A', 'B');
                    %             figure; imshow(modelHandle.Data.FramesOrigin{1},[]); hold on;
                    %             plot(pointsA);
                    %             title('Corners in A');
                    
                    %             figure; imshow(modelHandle.Data.FramesOrigin{2},[]); hold on;
                    %             plot(pointsB);
                    %             title('Corners in B');
                    
                    % Extract FREAK descriptors for the corners
                    [featuresA, pointsA] = extractFeatures(obj.Data.FramesOrigin{i-1}, pointsA);
                    [featuresB, pointsB] = extractFeatures(obj.Data.FramesOrigin{i}, pointsB);
                    
                    indexPairs = matchFeatures(featuresA, featuresB);
                    
                    pointsA = pointsA(indexPairs(:, 1), :);
                    pointsB = pointsB(indexPairs(:, 2), :);


                    %Numer of Mathcing Points between two frames. Must be
                    %greater or equal to 3
                    NoOfMatches = size(indexPairs,1);
                    ptThresh = ptThresh/2;
                    
                     Searchiteration = Searchiteration+1;
                     
%                      disp(Searchiteration/50)
                     if Searchiteration > 1
                         Search = false;
                     end
                    
                    figure(); imshow(obj.Data.FramesOrigin{i-1},[]); hold on;
                    plot(pointsA);
                    title('Corners in A');
                    
                    figure; imshow(obj.Data.FramesOrigin{i},[]); hold on;
                    plot(pointsB);
                    title('Corners in B');
                end
                
                if Search
                pointsA = pointsA(indexPairs(:, 1), :);
                pointsB = pointsB(indexPairs(:, 2), :);
                
                %             figure; showMatchedFeatures(modelHandle.Data.FramesOrigin{1}, modelHandle.Data.FramesOrigin{2}, pointsA, pointsB);
                %             legend('A', 'B');
                
                try
                [tform, pointsBm, pointsAm] = estimateGeometricTransform(pointsA, pointsB, 'affine');
                imgBp = imwarp(obj.Data.FramesOrigin{i}, tform, 'OutputView', imref2d(size(obj.Data.FramesOrigin{i})));
%                 pointsBmp = transformPointsForward(tform, pointsBm.Location);
                obj.Data.FramesStable{i} = imgBp;
                catch
                    disp('jo')
                end
                obj.Data.FramesStable{i} = obj.Data.FramesOrigin{i};
                %             figure;
                %             showMatchedFeatures(modelHandle.Data.FramesOrigin{1}, imgBp, pointsAm, pointsBmp);
                %             legend('A', 'B'); 
                end
                
            end
        end
        
        function clearAllData(obj)
            %Clears all Data except the FIle and path names
            
            obj.Data.FramesOrigin = [];
            obj.Data.StimuFrames = [];
            obj.Data.FrameSize = [];
            obj.Data.NoFrames = [];
            obj.Data.CurrentFrame = [];
            obj.Data.FPS = [];
            obj.Data.BitDepth = [];
            obj.Data.VideoLength = [];
            obj.Data.CurVideoLength = [];
            obj.Data.ROI = []; 
            obj.Data.HandleFrameROI = []; 
            
            obj.CellData.NoCells = [];
            obj.CellData.Mask = [];
            obj.CellData.RefMask = [];
            obj.CellData.Labels = [];
            obj.CellData.Boundaries = [];
            obj.CellData.Handle2Boundaries = [];
            obj.CellData.CurrentFrame = 1;
            obj.CellData.CurVideoLength = [];
            obj.CellData.Stats = [];
            obj.CellData.Intensities = [];
            obj.CellData.StimulationSignal = [];
            obj.CellData.BackgroundSignal = [];
            obj.CellData.HandleFrameAnalyzed = [];
            obj.CellData.TableCellOptions = {};
            obj.CellData.ColorOrder = [      0    0.4470    0.7410;...
                                        0.8500    0.3250    0.0980;...
                                        0.9290    0.6940    0.1250;...
                                        0.4940    0.1840    0.5560;...
                                        0.4660    0.6740    0.1880;...
                                        0.3010    0.7450    0.9330;...
                                        0.6350    0.0780    0.1840];
            
            obj.AppState.Timer = [];
            obj.AppState.ActivePanel = 1;
        end
    end
    
end

