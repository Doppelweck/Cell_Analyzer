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
            obj.CellData.Masks = [];
            obj.CellData.RefMask = []; %Background
            obj.CellData.Labels = [];
            obj.CellData.Boundaries = [];
            obj.CellData.Handle2Boundaries = [];
            obj.CellData.CurrentFrame = 1;
            obj.CellData.CurVideoLength = [];
            obj.CellData.Stats = [];
            obj.CellData.Intensities = [];
            obj.CellData.IntensitiesSmoothed = [];
            obj.CellData.StimulationSignal = [];
            obj.CellData.BackgroundSignal = [];
            obj.CellData.BackgroundSignalSmoothed = [];
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
            
            obj.frameStabilisation(false);
            
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
            %Create i-Masks for i-ROIs
            
                obj.CellData.NoCells = [];
                obj.CellData.Masks = [];
                obj.CellData.Labels = [];
                obj.CellData.Boundaries = [];
                obj.CellData.Handle2Boundaries = [];
                
                idxOK=[];
                idxNotOK=[];
                
                for i=1:size(obj.Data.ROI,2)
                idxOK(end+1)=0;
                idxOK(end) = find(isvalid(obj.Data.ROI{1,i}))*i;
                
                idxNotOK(end+1)=0;
                if isempty(find(~isvalid(obj.Data.ROI{1,i}))*i)
                    idxNotOK(end) = [];
                end
                end
                obj.Data.ROI(idxNotOK) = [];
                
                
                
            if ~isempty(idxOK)
                
                NoROI = size(obj.Data.ROI,2);
                
                Mask = logical(zeros(size(obj.Data.FramesStable{1,1})));
                
                for i=1:1:NoROI
                    %%tempMask = createMask(obj.Data.ROI{1,i});
                    %%Mask(tempMask)=1;
                    
                    %Save ervery Mask from ROI
                    obj.CellData.Masks{i} = createMask(obj.Data.ROI{1,i});
                    
                    %Create Label and Boundarie Mats
                    [Bounds Label] = bwboundaries(obj.CellData.Masks{i},8,'noholes');
                    obj.CellData.Boundaries{i} = Bounds;
                    obj.CellData.Label = i;
                end
                
                obj.CellData.NoCells = NoROI;
                
            else %No ROIs selected
            end
            
            %Create Mask for Referece Background. One mask for every
            %Background ROI
            if ~isempty(obj.Data.RefROI)
                
                idxOK=[];
                idxNotOK=[];
                
                for i=1:size(obj.Data.RefROI,2)
                idxOK(end+1)=0;
                idxOK(end) = find(isvalid(obj.Data.RefROI{1,i}))*i;
                
                idxNotOK(end+1)=0;
                if isempty(find(~isvalid(obj.Data.RefROI{1,i}))*i)
                    idxNotOK(end) = [];
                end
                end
                obj.Data.ROI(idxNotOK) = [];
                
%                 idxOK = find(isvalid([obj.Data.RefROI{:}]));
%                 idxNotOK = find(~isvalid([obj.Data.RefROI{:}]));

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
        
        function smoothData(obj,method,span)
            switch method
                case 'no smoothing'
                    obj.CellData.IntensitiesSmoothed = obj.CellData.Intensities;
                    obj.CellData.BackgroundSignalSmoothed = obj.CellData.BackgroundSignal;
                case 'moving average'
                for i=1:size(obj.CellData.IntensitiesSmoothed,1)
%                     obj.CellData.IntensitiesSmoothed(i,:)= smooth(obj.CellData.Intensities(i,:),method,span);
                   obj.CellData.IntensitiesSmoothed(i,:)= conv(obj.CellData.Intensities(i,:), ones(round(span),1)/round(span), 'same');
                end
                for i=1:size(obj.CellData.BackgroundSignalSmoothed,1)
%                     obj.CellData.IntensitiesSmoothed(i,:)= smooth(obj.CellData.Intensities(i,:),method,span);
                   obj.CellData.BackgroundSignalSmoothed(i,:)= conv(obj.CellData.BackgroundSignal(i,:), ones(round(span),1)/round(span), 'same');
                end
            end
        end
        
        function getCellProperties(obj)
            
            
            for i=1:1:obj.Data.NoFrames
                %Get Stimulation Signal
                obj.CellData.StimulationSignal(i) = max(max(obj.Data.StimuFrames{i}));
                
                %Get Background Signal
                if ~isempty(obj.CellData.RefMask)
                    obj.CellData.BackgroundSignal(i) = mean(obj.Data.FramesStable{i}(obj.CellData.RefMask==1));
                else
                    obj.CellData.BackgroundSignal = [];
                end
                 obj.CellData.BackgroundSignalSmoothed = obj.CellData.BackgroundSignal;
                
                %Get Cell Signal
                
                for j=1:1:obj.CellData.NoCells
                    frame = i;
                    cell = j;
                    
                    tempStruct = regionprops('struct',obj.CellData.Masks{j},obj.Data.FramesStable{i},'MeanIntensity','Centroid');
                    tempMat(cell,frame) = [tempStruct.MeanIntensity];
                    %                 [obj.CellData.Stats(:).meanIntensity] = deal(meanIntens.MeanIntensity);
                    
                    obj.CellData.Stats(j).Centroid = tempStruct.Centroid;
                end
                
                workbar(i/obj.Data.NoFrames, 'get Cell Data', 'Calculating Cell Data',obj.hController.hFigure);
            end
            obj.CellData.Intensities = tempMat;
            obj.CellData.IntensitiesSmoothed = tempMat;
            
            meanCells = mean(tempMat,1);
            %[y,yfit] = bf(meanCells.','confirm','linear');
            
%             % Filter parameters
%             fc = 0.5;     % fc : cut-off frequency (cycles/sample)
%             d = 2;          % d : filter order parameter (d = 1 or 2)
%             
%             % Positivity bias (peaks are positive)
%             r = 6;          % r : asymmetry parameter
%             
%             % Regularization parameters
%             amp = 0.4;
%             lam0 = 0.5*amp;
%             lam1 = 5*amp;
%             lam2 = 4*amp;
%             
%             ylim1 = [0 max(meanCells)];
%             xlim1 = [0 length(meanCells)];
%             N = length(meanCells);
%             meanCells = meanCells.';
%             
%             [x1, f1, cost] = beads(meanCells, d, fc, r, lam0, lam1, lam2);
%             %%obj.CellData.Stats = tempStruct;
%             figure(100)
%             clf
%             
%             subplot(4, 1, 1)
%             plot(meanCells)
%             title('Data')
%             xlim(xlim1)
%             ylim(ylim1)
%             set(gca,'ytick', ylim1)
%             
%             subplot(4, 1, 2)
%             plot(meanCells,'color', [1 1 1]*0.7)
%             line(1:N, f1, 'LineWidth', 1)
%             legend('Data', 'Baseline')
%             legend boxoff
%             title(['Baseline, as estimated by BEADS', ' (r = ', num2str(r), ', fc = ', num2str(fc), ', d = ', num2str(d),')'])
%             xlim(xlim1)
%             ylim(ylim1)
%             set(gca,'ytick', ylim1)
%             
%             subplot(4, 1, 3)
%             plot(x1)
%             title('Baseline-corrected data')
%             xlim(xlim1)
%             ylim(ylim1)
%             set(gca,'ytick', ylim1)
%             
%             
%             subplot(4, 1, 4)
%             plot(meanCells - x1 - f1)
%             title('Residual')
%             xlim(xlim1)
%             ylim(ylim1)
%             set(gca,'ytick', ylim1)
%             
%             orient tall
%             print -dpdf example
            
        end
        
        function frameStabilisation(obj,active)
            
            if active
            
            % Set alignment parameters
            alignIteration = 20; % number of iterationsS
            init_warp_value = 5;  %initialization of shift for correlation
            NoL = 1;  % number of pyramid-levels %it's not working --> set to 1
            transform = 'translation'; % Method of transformation --> only translation is working
            

            obj.Data.FramesStable = [];
            obj.Data.FramesStable{1} = double(obj.Data.FramesOrigin{1});
            
            %Assignment of first image as template
            template_image=double(obj.Data.FramesOrigin{1});
            imageCellaligned{1} = double(obj.Data.FramesOrigin{1});
            
            init_warp = [init_warp_value;init_warp_value];
            NoI = 2*alignIteration;
            
            for i=2:1:obj.Data.NoFrames
                percent =   (i)/obj.Data.NoFrames;
                workbar(percent,'Please Wait...stabilization of video frames','Frame Stabilization',obj.hController.hFigure);
                
                image_to_align=double(obj.Data.FramesOrigin{i});
                [A,B,C]=size(image_to_align);
                
                % Convert image in grayscale and to type double
                if C==3
                    image_to_align=rgb2gray(image_to_align);
                end
                
                do_align = 1;
                while do_align > 0
                    % Follwing function calculates the aligned image
                    [results,  vec_final_warp(1:2,i), warped_image]=...
                        ecc(image_to_align, template_image,NoL, NoI, transform, init_warp);
                    % is there a high image shift two subsequent images the
                    % number of correlation steps will be increased and image new
                    % aligned
                    if max(abs(vec_final_warp(:,i)-vec_final_warp(:,i-1))) > 2.5....
                            && do_align < 2
                        do_align = do_align+1;
                        NoI = 2*alignIteration;
                    else
                        do_align = 0;
                        NoI = alignIteration;
                    end
                end
                init_warp = vec_final_warp(1:2,i);  % new start values for next alignment
                obj.Data.FramesStable{i} = warped_image; % aligned image in cell
            end
            
            else %Frame Stabilisation is NOT active
                
                obj.Data.FramesStable = obj.Data.FramesOrigin;
                
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
            obj.CellData.Masks = [];
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

